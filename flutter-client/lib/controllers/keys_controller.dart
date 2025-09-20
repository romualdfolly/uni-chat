// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/controllers/secure_keys_controller.dart';
import 'package:unichat_flutter/models/key_pair.dart';
import 'package:unichat_flutter/objectbox.g.dart';


class KeysController extends GetxController {
  //
  static final int nBits = 32;
  static final int nonceSize = 12;
  static final Duration keysValidity = Duration(days: 30);
  final _databaseController = DatabaseController();

  /// checks if it exists Active and Valid Keys
  Future<bool> hasValidKeys() async {
    //
    final keyPairsBox = _databaseController.keyPairsBox;
    final now = DateTime.now();
    //
    final query =
        keyPairsBox
            .query(
              KeyPairEntity_.isActive
                  .equals(true)
                  .and(
                    KeyPairEntity_.validUntil.greaterThan(
                      now.millisecondsSinceEpoch,
                    ),
                  ),
            )
            .build();

    final hasResult = query.findFirst() != null;

    query.close();

    return hasResult;
  }

  // Creates KeyPairInsatnace
  static Future<SimpleKeyPair> createKeyPairFromKeys({
    required List<int> privateKeyBytes,
    required List<int> publicKeyBytes,
    required KeyPairType keyPairType,
  }) async {
    if (privateKeyBytes.length != 32 || publicKeyBytes.length != 32) {
      throw Exception('Invalid key length: Ed25519 keys must be 32 bytes');
    }

    final publicKey = SimplePublicKey(publicKeyBytes, type: keyPairType);

    return SimpleKeyPairData(
      privateKeyBytes,
      publicKey: publicKey,
      type: keyPairType,
    );
  }

  /// returns keys given id
  Future<KeyPairEntity> getKeysById(int keyID) async {
    //
    final keyPairsBox = Get.find<DatabaseController>().keyPairsBox;
    final keyData =
        keyPairsBox.query(KeyPairEntity_.id.equals(keyID)).build().find().first;

    return keyData;
  }

  static List<int> _generateNonce(int nBits) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(nBits, (_) => random.nextInt(256)),
    );
  }

  static Future<(SecretKey, SecretBox)> encryptWithAesGcm({
    List<int>? aesKey,
    required List<int> data
  }) async {
    //
    final algorithm = AesGcm.with256bits();

    // the secret key
    late final SecretKey secretKey;
    if (aesKey != null) {
      secretKey = SecretKey(aesKey);
    } else {
      secretKey = await algorithm.newSecretKey();
    }

    // Generate nonce if it is not provided
    List<int> nonce = _generateNonce(nonceSize);

    // encryption
    final secretBox = await algorithm.encrypt(
      data,
      secretKey: secretKey,
      nonce: nonce,
    );

    return (secretKey, secretBox);
  }

  //
  static Future<List<int>> decryptWithAesGcm({
    required List<int> aesKey,
    required List<int> nonce,
    required List<int> mac,
    required List<int> cipherText,
  }) async {
    //
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKey(aesKey);

    // decryption : throws exception if failed
    final decrypted = await algorithm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
      secretKey: secretKey,
    );

    return decrypted;
  }

  /// Derives and saves the AES key in secure storage
  static Future<void> deriveAndSaveAESDerivedKey(
    String pin,
    String salt,
  ) async {
    final secureStorage = FlutterSecureStorage();
    final secureKeysController = Get.find<SecureKeysController>();

    try {
      final derivedAes = await secureKeysController.deriveAesFromPIN(pin, salt);
      await secureStorage.write(
        key: 'derivedAES',
        value: base64Encode(derivedAes),
      );
    } catch (e) {
      print('[!] Error deriving or saving AES key: $e');
      throw Exception('Failed to derive or save AES key');
    }
  }

  /// Loads AES key
  static Future<String> loadDerivedAES() async {
    final secureStorage = FlutterSecureStorage();
    final aEsKey = await secureStorage.read(key: 'derivedAES');
    return aEsKey!;
  }

  /// Saved Derived key
  static Future<void> deleteAESDerivedKey() async {
    final secureStorage = FlutterSecureStorage();
    secureStorage.delete(key: 'derivedAES');
  }

  /// Encrypts the AES key with X25519 using HKDF.
  static Future<(SecretBox, List<int>)> encryptAesKeyWithX25519({
    required List<int> aesSecretKeyBytes,
    required SimpleKeyPair myXKeyPair,
    required List<int> receiverXPublicKey,
  }) async {
    try {
      // the algo
      final x25519Algorithm = X25519();

      // receiver's public key
      final receiverPublicKey = SimplePublicKey(
        receiverXPublicKey,
        type: KeyPairType.x25519,
      );

      // the shared secret
      final sharedSecret = await x25519Algorithm.sharedSecretKey(
        keyPair: myXKeyPair,
        remotePublicKey: receiverPublicKey,
      );
      final sharedSecretBytes = await sharedSecret.extractBytes();

      // Derivation of a secure key with HKDF
      final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: nBits);
      final hkdfNonce = _generateNonce(nonceSize);

      final derivedKey = await hkdf.deriveKey(
        secretKey: SecretKey(sharedSecretBytes),
        info: utf8.encode('AES key security'),
        nonce: hkdfNonce,
      );
      final derivedKeyBytes = await derivedKey.extractBytes();

      // Encrypt the AES key with AES-GCM
      final aesGcmAlgorithm = AesGcm.with256bits();
      final aesGcmNonce = _generateNonce(nBits);

      final aesKeyEncryption = await aesGcmAlgorithm.encrypt(
        aesSecretKeyBytes,
        secretKey: SecretKey(derivedKeyBytes),
        nonce: aesGcmNonce,
      );

      return (aesKeyEncryption, hkdfNonce);
    } catch (e) {
      print('Error encrypting AES key with X25519: $e');
      throw Exception('Failed to encrypt AES key');
    }
  }

  /// Signs the message
  static Future<(List<int>, List<int>)> signMessage({
    required List<int> message,
    required SimpleKeyPair myEdKeyPair,
  }) async {
    final algorithm = Ed25519();
    final hashAlgorithm = Sha512();

    // Hash computation
    final hash = await hashAlgorithm.hash(message);
    final hashBytes = hash.bytes;

    // Signature du hash
    final signature = await algorithm.sign(hashBytes, keyPair: myEdKeyPair);

    return (hashBytes, signature.bytes);
  }

  /// verify signature
  static Future<bool> verifySignature({
    required String messageHashBase64,
    required String signatureBase64,
    required String senderEdPublickeyBase64,
  }) async {
    try {
      // decode
      final publicKeyBytes = base64Decode(senderEdPublickeyBase64);
      final signatureBytes = base64Decode(signatureBase64);

      // Convert publicKeyBytes to a PublicKey
      final publicKey = SimplePublicKey(
        publicKeyBytes,
        type: KeyPairType.ed25519,
      );

      // EdAlgo
      final algorithm = Ed25519();
      final signature = Signature(signatureBytes, publicKey: publicKey);

      // Vérifier la signature
      final isVerified = await algorithm.verify(
        base64Decode(messageHashBase64),
        signature: signature,
      );

      return isVerified;
    } catch (e) {
      print("Erreur lors de la vérification de la signature : $e");
      return false;
    }
  }

  /// Generates an AES-GCM key, encrypts a message, and encrypts the AES key with X25519 for the server.
  /// ServerBox, AesBox, Hash, Signature
  static Future<(SecretBox, SecretBox, List<int>, List<int>, List<int>)>
  generateAndEncryptAesGcmKeyAndMessageAndSignForServer({
    required String message,
    required SimpleKeyPair myXKeyPair,
    required SimpleKeyPair myEdKeyPair,
    required List<int> receiverXPublicKey,
  }) async {
    try {
      // convert message to List<int>
      Uint8List messageBytes = utf8.encode(message);

      // Encrypt the message with AES-GCM
      final (
        SecretKey aesSecretKey,
        SecretBox secretBox,
      ) = await encryptWithAesGcm(data: messageBytes);

      // Get generated AES GCM Key bytes
      final aesSecretKeyBytes = await aesSecretKey.extractBytes();

      // Encrypt the AES key with X25519
      final (aesKeyEncryption, hkdfNonce) = await encryptAesKeyWithX25519(
        aesSecretKeyBytes: aesSecretKeyBytes,
        myXKeyPair: myXKeyPair,
        receiverXPublicKey: receiverXPublicKey,
      );

      // signature
      final (hashBytes, signature) = await signMessage(
        message: messageBytes,
        myEdKeyPair: myEdKeyPair,
      );

      // Return the encrypted data
      return (secretBox, aesKeyEncryption, hkdfNonce, hashBytes, signature);
    } catch (e) {
      print('Error generating and encrypting message: $e');
      throw Exception('Failed to generate and encrypt message');
    }
  }

  // Decrypts Aes key sent from server
  static Future<List<int>> decryptServerAesKey({
    required String aesKeyFromServerBase64,
    required String senderXPublicKeyBase64,
    required SimpleKeyPair myXKeyPair,
    required String hkdfNonceBase64,
    required String aesNonceBase64,
    required String aesMacBase64,
  }) async {
    //
    final algorithm = X25519();
    //

    // Convert senderPublicKeyBytes to a PublicKey
    final senderPublicKeyBytes = base64Decode(senderXPublicKeyBase64);
    final senderXPublicKey = SimplePublicKey(
      senderPublicKeyBytes,
      type: KeyPairType.x25519,
    );

    // Compute the shared secret
    final sharedSecret = await algorithm.sharedSecretKey(
      keyPair: myXKeyPair,
      remotePublicKey: senderXPublicKey,
    );

    // check if it is empty
    final sharedSecretBytes = await sharedSecret.extractBytes();

    if (sharedSecretBytes.isEmpty) {
      throw Exception('Shared secret is empty');
    }

    // Derivation of a secure key with HKDF
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: nBits);
    final derivedKey = await hkdf.deriveKey(
      secretKey: sharedSecret,
      info: utf8.encode('AES key security'),
      nonce: base64Decode(hkdfNonceBase64),
    );

    // derive key and check content
    final derivedKeyBytes = await derivedKey.extractBytes();
    if (derivedKeyBytes.isEmpty) {
      throw Exception('Derived key is empty');
    }

    // Decrypt the AES key using AES-GCM
    final aesGcmAlgorithm = AesGcm.with256bits();
    final cipherText = base64Decode(aesKeyFromServerBase64);
    final nonce = base64Decode(aesNonceBase64);
    final mac = base64Decode(aesMacBase64);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(mac));

    final decryptedAesKey = await aesGcmAlgorithm.decrypt(
      secretBox,
      secretKey: SecretKey(derivedKeyBytes),
    );

    if (decryptedAesKey.isEmpty) {
      throw Exception('Decrypted AES key is empty');
    }

    return decryptedAesKey;
  }
}
