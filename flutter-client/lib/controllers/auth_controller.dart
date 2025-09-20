import 'dart:convert';

import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/message_controller.dart';
import 'package:unichat_flutter/controllers/secure_pin_controller.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/online_message_format.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:unichat_flutter/services/message_service.dart';
import 'package:unichat_flutter/services/pusher_service.dart';

import 'package:unichat_flutter/utils/http_response_handler.dart';
import 'package:unichat_flutter/views/widgets/auth/secure_pin_code_screen.dart';
import 'package:unichat_flutter/views/widgets/auth/verify_code_screen.dart';

import 'package:unichat_flutter/objectbox.g.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;

  final AuthService authService = AuthService();

  // login
  Future<void> login(String identifier, String password) async {
    isLoading.value = true; // loading state

    try {
      http.Response response = await authService.login(identifier, password);
      handleResponse(response);

      // update user infos
      final jsonResponse = jsonDecode(response.body);
      final userData = jsonResponse['data'];

      // loggedin user infos
      final newUser = User(
        user_id: userData['id'],
        username: userData['username'],
        name: userData['name'],
        email: userData['email'],
        authToken: jsonResponse['token'],
        createdAt: DateTime.parse(userData['created_at']),
        updatedAt: DateTime.parse(userData['updated_at']),
        emailVerifiedAt: DateTime.parse(userData['email_verified_at']),
        lastConnectionAt: DateTime.parse(userData['last_connection_at']),
      );

      // DatabaseController::userBox
      final userBox = Get.find<DatabaseController>().userBox;

      User currentUser;

      // check if user Exists
      final existingUser =
          userBox
              .query(User_.user_id.equals(newUser.user_id))
              .build()
              .find()
              .firstOrNull;

      if (existingUser == null) {
        // save user infos into database
        final id = userBox.put(newUser);
        currentUser = newUser..id = id;
      } else {
        // update infos in database
        existingUser
          ..username = newUser.username
          ..name = newUser.name
          ..email = newUser.email
          ..authToken = newUser.authToken
          ..createdAt = newUser.createdAt
          ..updatedAt = newUser.updatedAt
          ..emailVerifiedAt = newUser.emailVerifiedAt
          ..lastConnectionAt = newUser.lastConnectionAt;

        // Save updated user data
        userBox.put(existingUser);
        currentUser = existingUser;
      }

      // Get from database after save/update
      Get.put(currentUser, tag: 'currentUser');

      if (response.statusCode == 200) {
        Get.to(SecurityPinCodeScreen());
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }

  // register
  Future<void> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    isLoading.value = true; // Set loading to true when registration starts
    try {
      // Call registration API
      final response = await authService.register(
        name,
        userName,
        email,
        password,
        passwordConfirmation,
      );

      // Handle API response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Show response in Snackbar
        handleResponse(response);

        // Check if user data is available in the response
        if (jsonResponse.containsKey('data')) {
          final userData = jsonResponse['data'];

          // we remove all potential databases to void data leakages
          Get.find<DatabaseController>().deleteAllTables();
          // we remove all secure keys
          Get.find<SecurePinController>().deletePinData();

          // Save user in database
          final userBox = Get.find<DatabaseController>().userBox;

          // If there are existing users, remove them
          if (!userBox.isEmpty()) {
            userBox.removeAll();
          }

          // Creating current user
          final currentUser = User(
            user_id: userData['id'],
            username: userData['username'],
            name: userData['name'],
            email: userData['email'],
            authToken: jsonResponse['token'],
            createdAt: DateTime.parse(userData['created_at']),
            updatedAt: DateTime.parse(userData['updated_at']),
          );

          // save
          userBox.put(currentUser);

          // Add current user to Get
          Get.put(currentUser, tag: 'currentUser');

          // Navigate to the next screen
          Get.to(VerifyCodeScreen(code: jsonResponse['verification-code']));
        } else {
          // If 'data' is missing, handle the error (Optional)
          Get.snackbar("Error", "User data is missing in response.");
        }
      } else {
        // Handle other response status codes
        handleResponse(
          response,
          duration: 5,
        ); // Show error for non-200 response
      }
    } catch (e) {
      // Handle error
      print("[Error]: $e"); // Optionally log the error for debugging
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value =
          false; // Set loading to false after the request is complete
    }
  }

  // verify address
  Future<void> verifyAddress(int code) async {
    isLoading.value = true;
    try {
      final userBox = Get.find<DatabaseController>().userBox;
      final currentUser = Get.find<User>(tag: 'currentUser');

      final response = await authService.verifyAddress(
        currentUser.user_id,
        code,
        currentUser.authToken,
      );

      // Handle API response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);

        // Show response in Snackbar
        handleResponse(response);

        // Check if user data is available in the response
        if (jsonResponse.containsKey('data')) {
          final data = jsonResponse['data'];

          // Update user infos
          currentUser.emailVerifiedAt = DateTime.parse(data['date_time']);
          currentUser.lastConnectionAt = DateTime.parse(data['date_time']);

          // saving updates
          userBox.put(currentUser);

          // Navigate PIN setup Screen
          Get.to(SecurityPinCodeScreen());
        } else {
          // If 'data' is missing, handle the error (Optional)
          Get.snackbar("Error", "User data is missing in response.");
        }
      } else {
        // Handle other response status codes
        handleResponse(response, duration: 5);
      }
    } catch (e) {
      // Handle error
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> checkAuthStatus() async {
    // check if PIN Code exists
    final databaseController = Get.find<DatabaseController>();
    final securePinController = Get.find<SecurePinController>();
    final chatController = Get.find<ChatController>();

    final userBox = databaseController.userBox;

    //userBox.removeAll();
    // databaseController.chatBox.removeAll();
    // databaseController.messageBox.removeAll();
    // await securePinController.deletePinData();
    // databaseController.deleteAllTables();

    // if no user in database, Go to register
    if (userBox.isEmpty()) {
      return '/register';
    }

    // read users data
    final user = userBox.getAll().first;
    Get.put(user, tag: 'currentUser');

    // check token existence
    if (user.authToken.isEmpty) {
      return '/login';
    }

    // if last connection was at least 30 Days ago
    if (user.lastConnectionAt!
        .add(Duration(days: 30))
        .isBefore(DateTime.now())) {
      return '/login';
    }

    // if PIN is not SET
    if (!await securePinController.hasSaltAndHash()) {
      return '/login';
    }

    // loading local chats and messages in background while doing other operations
    Future.microtask(() => chatController.loadLocalChatsAndMessages());

    // Everything is Ok. Load data and Go to chats
    final messageController = MessageController();

    try {
      // put infos in Get memory
      Get.put(
        (await databaseController.getValidKeyPairs())!,
        tag: 'currentValidKeypairs',
      );

      // Me as contact
      if (!Get.isRegistered<Contact>(tag: 'meAsContact')) {
        final meAsContact =
            databaseController.contactBox
                .query(Contact_.userId.equals(user.user_id))
                .build()
                .findFirst();
        Get.put<Contact>(meAsContact!, tag: 'meAsContact');
      }
    } catch (e) {
      print("[!] An error occured");
    }

    final puserService = PusherService();
    final messageService = MessageService();
    //
    puserService.initPusher(
      userId: user.user_id,
      token: user.authToken,
      onNewMessage: (OnlineMessageFormat onlineMessage) async {
        // we save the message locally and we update the UI
        await messageController.saveMessageLocallyAndUpdateUI(
          onlineMessage: onlineMessage,
        );

        // update is_read proprety server-side
        try {
          final response = await messageService
              .updateMessagesReadingStateOnServer(
                messagesIdsList: [onlineMessage.id],
                token: user.authToken,
              );

          print(response.body);
        } catch (e) {
          print("[-] >>> $e");
        }
      },
    );

    return '/pincode';
  }
}
