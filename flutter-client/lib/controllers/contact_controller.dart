import 'dart:convert';

import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/chat_controller.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/objectbox.g.dart';
import 'package:unichat_flutter/services/contact_service.dart';
import 'package:unichat_flutter/utils/http_response_handler.dart';
import 'package:unichat_flutter/views/pages/chat/chat_content.dart';

class ContactController extends GetxController {
  //
  RxBool isLoading = false.obs;
  RxBool isAddingContact = false.obs;
  var contactData = Rxn<Contact>();

  final _currentUser = Get.find<User>(tag: 'currentUser');
  final ContactService _contactService = ContactService();
  final _dataBaseController = Get.find<DatabaseController>();
  final _chatController = Get.find<ChatController>();

  Future<void> checkIfContactAccountExists(String identifier) async {
    isLoading.value = true;

    /*
    final contacts = _dataBaseController.contactBox.getAll();
    for (final c in contacts) {
      c.describe();
      if (c.email == "jane@doe.org") {
        _dataBaseController.contactBox.remove(c.id);
      }
    }
    // */

    // Check if Contact is already added locally
    var contact = checkIfContactExistsLocaly(identifier);

    if (contact != null) {
      // Check if chat exists or create it
      navigateToChat(contact);
    } else {
      // Fetch the contact from the server if not found locally
      if (!isAddingContact.value) {
        try {
          final response = await _contactService.checkContact(
            identifier,
            _currentUser.authToken,
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            final jsonResponse = jsonDecode(response.body);
            contactData.value = Contact.fromJson(jsonResponse['data']);
            isAddingContact.value = true;
          } else {
            handleResponse(response);
          }
        } catch (e) {
          Get.snackbar("Error", "An error occurred: ${e.toString()}");
        } finally {
          isLoading.value = false;
        }
      } else {
        // update name (to match, in case of change)
        contactData.value!.name = identifier;
        // Save the contact and create chat
        await _saveContactAndNavigate();
      }
    }
  }

  Future<Contact?> getContactInfosByIdFromServer(int contactId) async {
    try {
      final response = await _contactService.getCOntactInfosById(
        contactId,
        _currentUser.authToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final contact = Contact.fromJson(jsonResponse['data']);

        return contact;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveContactAndNavigate() async {
    final contactBox = _dataBaseController.contactBox;

    // saving in local database
    contactBox.put(contactData.value!);

    // Check if chat exists or create it
    navigateToChat(contactData.value!);
  }

  void navigateToChat(Contact contact) async {
    final chat = await _chatController.checkOrCreateChatWith(contact);

    if (chat != null) {
      isLoading.value = false;
      Get.to(ChatContentScreen(chat: chat));
    } else {
      Get.snackbar('Error', "An error occurred while creating the chat");
    }
  }

  Contact? checkIfContactExistsLocaly(String identidier) {
    //
    final contactBox = _dataBaseController.contactBox;
    final contacts =
        contactBox
            .query(
              Contact_.email
                  .equals(identidier.trim())
                  .or(Contact_.username.equals(identidier.trim())),
            )
            .build()
            .find();

    return contacts.isNotEmpty ? contacts.first : null;
  }

  Contact? checkIfContactExistsLocalyByUserId(int userId) {
    //
    final contactBox = _dataBaseController.contactBox;
    final contacts =
        contactBox.query(Contact_.userId.equals(userId)).build().find();

    return contacts.isNotEmpty ? contacts.first : null;
  }

  static Future<void> saveContactIfNotExists(Contact contact) async {
    final contactBox = Get.find<DatabaseController>().contactBox;

    final existing =
        contactBox
            .query(
              Contact_.userId
                  .equals(contact.userId)
                  .or(Contact_.email.equals(contact.email))
                  .or(Contact_.username.equals(contact.username)),
            )
            .build()
            .findFirst();

    if (existing == null) {
      contactBox.put(contact);
    }
  }
}
