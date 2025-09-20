import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/keys_controller.dart';
import 'package:unichat_flutter/controllers/secure_keys_controller.dart';
import 'package:unichat_flutter/models/pin_data.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/utils/app_data.dart';
import 'package:unichat_flutter/utils/http_response_handler.dart';
import 'package:unichat_flutter/views/widgets/loading_screen.dart';

class SecurePinController extends GetxController {
  final _storage = const FlutterSecureStorage();
  static const int nBytesForPin = 32;
  var trialsLeft = AppData.PinNumberMaxTrials.obs;
  var isPinConfirmation = false.obs;
  var _oldPinCode = '';
  var pinCode = ''.obs;
  RxBool isLoading = false.obs;

  Future<bool> hasSaltAndHash() async {
    final pinData = await _storage.readAll();
    return pinData.containsKey('pinHash') && pinData.containsKey('pinSalt');
  }

  Future<void> savePinData(PinData pinData) async {
    for (final entry in pinData.toMap().entries) {
      await _storage.write(key: entry.key, value: entry.value);
    }
  }

  Future<PinData> loadPinData() async {
    final Map<String, String> pinData = await _storage.readAll();
    return PinData.fromMap(pinData);
  }

  Future<void> deletePinData() async {
    for (final dataKey in ['pinSalt', 'pinHash']) {
      await _storage.delete(key: dataKey);
    }
  }

  // this function generates a salt
  Future<Map<String, String>> generateHashAndSalt(
    String pin, {
    int nBytes = nBytesForPin,
    int iters = 100000,
  }) async {
    //
    final pbksf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iters,
      bits: nBytes * 8,
    );

    // salt generation
    final random = Random.secure();
    final salt = Uint8List.fromList(
      List<int>.generate(nBytes, (_) => random.nextInt(256)),
    );

    // key derivation
    final secretKey = await pbksf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    // the hash
    final hash = await secretKey.extractBytes();

    return {
      'pinHash': base64Encode(hash),
      'pinSalt': base64Encode(salt),
      'validUntil':
          DateTime.now()
              .add(Duration(days: AppData.validSecurPinDurationInDays))
              .toString(),
    };
  }

  // verify PIN
  Future<bool> verifyPin(
    String pin,
    String base64Hash,
    String base64Salt, {
    int nBytes = nBytesForPin,
    int iters = 100000,
  }) async {
    //
    final pbksf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iters,
      bits: nBytes * 8,
    );

    final salt = base64Decode(base64Salt);
    final expectedHash = base64Decode(base64Hash);

    final derivedKey = await pbksf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );

    final actualHash = await derivedKey.extractBytes();

    // Compare hashes securely
    if (actualHash.length != expectedHash.length) return false;

    var isEqual = true;
    for (var i = 0; i < actualHash.length; i++) {
      isEqual &= actualHash[i] == expectedHash[i];
    }

    return isEqual;
  }

  // set PIN Code
  Future<void> pinCodeManager() async {
    //
    final secureKeysController = Get.find<SecureKeysController>();
    isLoading.value = true;

    try {
      // check if hash & salt exists
      if (await hasSaltAndHash()) {
        // verify PIN
        final PinData pinData = await loadPinData();
        if (await verifyPin(pinCode.value, pinData.pinHash, pinData.pinSalt)) {
          // All is OK. Check if everything is Good with keys

          // derive and save AES key
          KeysController.deriveAndSaveAESDerivedKey(
            pinCode.value,
            pinData.pinSalt,
          );

          // reset trial
          trialsLeft.value = AppData.PinNumberMaxTrials;

          // Go to Loading Screen or Chats Screen
          await goToLoadingScreenOrChats();
        } else {
          // reset trial
          trialsLeft.value -= 1;

          // trials control
          if (trialsLeft.value == 0) {
            // show message
            showCustomSnackbar(
              'Security Alert',
              'Too many incorrect PIN attempts. You have been logged out.',
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              duration: 3,
            );

            // we clear the token
            final currentUser = Get.find<User>(tag: 'currentUser');
            currentUser.authToken = '';

            // save in database
            final databaseController = Get.find<DatabaseController>();
            databaseController.userBox.put(currentUser);

            // redirect to login
            Get.offAllNamed('/login');
          } else {
            // PIN is incorrect, clear the input and show an error message
            pinCode.value = '';
            showCustomSnackbar(
              'PIN ERROR',
              'The PIN you entered is incorrect. ${trialsLeft.value} trial${trialsLeft.value != 1 ? 's' : ''} left',
              backgroundColor: Colors.red,
              textColor: Colors.white,
              duration: 3,
            );
          }
        }
      } else {
        // No PIN set, ask the user to create and confirm a new PIN
        if (_oldPinCode.isEmpty) {
          // First time PIN entry
          _oldPinCode = pinCode.value;
          pinCode.value = '';
          isPinConfirmation.value = true; // Ask for confirmation PIN
        } else if (_oldPinCode != pinCode.value) {
          _oldPinCode = '';
          pinCode.value = '';
          isPinConfirmation.value = false;

          showCustomSnackbar(
            'PIN Mismatch',
            'The confirmation PIN does not match the original',
            backgroundColor: Colors.red,
            textColor: Colors.white,
            duration: 3,
          );
        } else {
          // Successfully confirmed PIN, generate hash and salt
          final Map<String, String> hashAndSalt = await generateHashAndSalt(
            pinCode.value,
          );

          final PinData pinData = PinData.fromMap(hashAndSalt);

          // derive and save AES key
          KeysController.deriveAndSaveAESDerivedKey(
            pinCode.value,
            pinData.pinSalt,
          );

          // saving
          await savePinData(pinData);

          // empty variables
          isPinConfirmation.value = false;
          _oldPinCode = '';

          // Lauch Loading screen : in background, keys will be created and sent to server
          Get.to(
            LoadingScreen(
              checkKeysTask: secureKeysController.generateAndPushKeys,
            ),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Goes to Loading screen or to Chats screen
  Future<void> goToLoadingScreenOrChats() async {
    final secureKeysController = Get.find<SecureKeysController>();
    if (await secureKeysController.checksIfValidKeyExists()) {
      Get.toNamed('/chats');
    } else {
      Get.to(
        LoadingScreen(checkKeysTask: secureKeysController.generateAndPushKeys),
      );
    }
  }
}
