import 'dart:convert';
import 'package:get/get.dart';
import 'package:cryptography/cryptography.dart';
import 'package:unichat_flutter/controllers/contact_controller.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/keys_controller.dart';
import 'package:unichat_flutter/controllers/secure_pin_controller.dart';
import 'package:unichat_flutter/controllers/user_controller.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/key_pair.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import 'package:unichat_flutter/objectbox.g.dart';
import 'package:unichat_flutter/services/keys_service.dart';

class SecureKeysController extends GetxController {
  //
  // keys service & database controller
  final KeysService keysService = KeysService(); 
  final userController = UserController();

  /// Generates private and public keys : for encryption and signature
  Future<Map<String, dynamic>> _generateKeyPairs() async {
    final edAlgo = Ed25519();
    final xAlgo = X25519();

    final edKeyPair = await edAlgo.newKeyPair();
    final xKeyPair = await xAlgo.newKeyPair();

    return {
      'edPub': await edKeyPair.extractPublicKey(),
      'xPub': await xKeyPair.extractPublicKey(),
      'edPrivBytes': await edKeyPair.extractPrivateKeyBytes(),
      'xPrivBytes': await xKeyPair.extractPrivateKeyBytes(),
    };
  }

  /// Derives AES from PIN
  Future<List<int>> deriveAesFromPIN(
    String pin,
    String salt, {
    int nBytes = SecurePinController.nBytesForPin,
  }) async {
    final pbkdf2 = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: nBytes * 8,
    );

    // Decode the salt
    final decodedSalt = base64Decode(salt);

    // AES Key derivation
    final secretKey = await pbkdf2.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: decodedSalt,
    );

    // AES key extraction
    final aesKey = await secretKey.extractBytes();

    return aesKey;
  }

  /// Hashes privkeys, stores them and sends pubkeys to server
  Future<void> generateAndPushKeys(String pin, String salt) async {
    // Get keys and AES
    final generatedKeys = await _generateKeyPairs();
    final derivedAes = await deriveAesFromPIN(pin, salt);

    //
    final edPub = generatedKeys['edPub'];
    final edPriv = generatedKeys['edPrivBytes'];
    final xPub = generatedKeys['xPub'];
    final xPriv = generatedKeys['xPrivBytes'];

    
    // encryption of edPriv Key
    final (_, edAesBox) = await KeysController.encryptWithAesGcm(
      aesKey: derivedAes,
      data: edPriv
    );

    
    final edPrivCipher = edAesBox.cipherText;
    final edNonce = edAesBox.nonce;
    final edMac = edAesBox.mac.bytes;

    
    // encryption of xPriv Key
    final (_, xAesBox) = await KeysController.encryptWithAesGcm(
      aesKey: derivedAes,
      data: xPriv
    );
    
    final xPrivCipher = xAesBox.cipherText;
    final xNonce = xAesBox.nonce;
    final xMac = xAesBox.mac.bytes;

    // KeyPairEntity object
    final kpe = KeyPairEntity(
      edPubKey: base64Encode(edPub.bytes),
      edPrivCipher: base64Encode(edPrivCipher),
      edPrivNonce: base64Encode(edNonce),
      edPrivMac: base64Encode(edMac),
      xPubKey: base64Encode(xPub.bytes),
      xPrivCipher: base64Encode(xPrivCipher),
      xPrivNonce: base64Encode(xNonce),
      xPrivMac: base64Encode(xMac),
      createdAt: DateTime.now(),
      validUntil: DateTime.now().add(KeysController.keysValidity),
    );

    // Make sure other optential Active keys are deactivated
    final keyPairsBox = Get.find<DatabaseController>().keyPairsBox;
    final validKeys =
        keyPairsBox.query(KeyPairEntity_.isActive.equals(true)).build().find();
    
    for (var key in validKeys) {
      key.isActive = false; // Mark existing keys as inactive
      keyPairsBox.put(key); // Save the update to the database
    }
    // save in local database
    final keyId = keyPairsBox.put(kpe);

    // save as user local contact
    final currentUser = Get.find<User>(tag: 'currentUser');
    final contact = Contact(
      userId: currentUser.user_id,
      email: currentUser.email,
      username: currentUser.username,
      name: currentUser.name,
      edPublicKey: kpe.edPubKey,
      keyId: keyId,
      xPublicKey: kpe.xPubKey,
      picture: '',
    );

    // save
    ContactController.saveContactIfNotExists(contact); // save
    

    // send public keys to server
    try {
      final response = await keysService.storeKeys(
        userId: currentUser.user_id,
        keyPairEntity: kpe,
        token: currentUser.authToken,
      );

      // Handle API response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        // Show response in Snackbar
        print(jsonResponse);
      } else {
        // Handle other response status codes
        print(response.body);
      }
    } catch (e) {
      // Handle error
      Get.snackbar("Error", "An error occurred: $e");
    }
  }

  ///
  Future<bool> checksIfValidKeyExists() async {
    //
    final keyPairsBox = Get.find<DatabaseController>().keyPairsBox;
    final validKeys =
        keyPairsBox.query(KeyPairEntity_.isActive.equals(true)).build().find();

    return validKeys.isNotEmpty;
  }
}
