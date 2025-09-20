class OnlineMessageFormat {
  final int id;
  final int senderId;
  final int receiverId;
  final String ciphertext;
  final String cNonce;
  final String cMac;
  final String aesKeyEncrypted;
  final String keyNonce;
  final String keyMac;
  final int kref;
  final String hash;
  final String digitalSignature;
  final String senderEdpk;
  final String senderXpk;
  final String hkdfNonce;
  final bool isRead;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  OnlineMessageFormat({
    this.id = -1,
    required this.senderId,
    required this.receiverId,
    required this.ciphertext,
    required this.cNonce,
    required this.cMac,
    required this.aesKeyEncrypted,
    required this.keyNonce,
    required this.keyMac,
    required this.kref,
    required this.hash,
    required this.digitalSignature,
    required this.senderEdpk,
    required this.senderXpk,
    required this.hkdfNonce,
    required this.isRead,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OnlineMessageFormat.fromJson(Map<String, dynamic> json) {
    return OnlineMessageFormat(
      id: json['id'] as int? ?? 0,
      senderId: json['sender_id'] as int? ?? 0,
      receiverId: json['receiver_id'] as int? ?? 0,
      ciphertext: json['ciphertext'] as String? ?? '',
      cNonce: json['c_nonce'] as String? ?? '',
      cMac: json['c_mac'] as String? ?? '',
      aesKeyEncrypted: json['aes_key_encrypted'] as String? ?? '',
      keyNonce: json['key_nonce'] as String? ?? '',
      keyMac: json['key_mac'] as String? ?? '',
      kref: json['kref'] as int? ?? 0,
      hash: json['hash'] as String? ?? '',
      digitalSignature: json['digital_signature'] as String? ?? '',
      senderEdpk: json['sender_edpk'] as String? ?? '',
      senderXpk: json['sender_xpk'] as String? ?? '',
      hkdfNonce: json['hkdf_nonce'] as String? ?? '',
      isRead: _toBool(json['is_read']),
      isDeleted: _toBool(json['is_deleted']),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? '1970-01-01T00:00:00Z',
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? '1970-01-01T00:00:00Z',
      ),
    );
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    return value == 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'ciphertext': ciphertext,
      'c_nonce': cNonce,
      'c_mac': cMac,
      'aes_key_encrypted': aesKeyEncrypted,
      'key_nonce': keyNonce,
      'key_mac': keyMac,
      'kref': kref,
      'hash': hash,
      'digital_signature': digitalSignature,
      'sender_edpk': senderEdpk,
      'sender_xpk': senderXpk,
      'hkdf_nonce': hkdfNonce,
      'is_read': isRead,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  void printInfos() {
    print('Message ID: $id');
    print('Sender ID: $senderId');
    print('Receiver ID: $receiverId');
    print('Ciphertext: $ciphertext');
    print('Nonce: $cNonce');
    print('MAC: $cMac');
    print('Encrypted AES Key: $aesKeyEncrypted');
    print('Key Nonce: $keyNonce');
    print('Key MAC: $keyMac');
    print('Key Reference (kref): $kref');
    print('Hash: $hash');
    print('Digital Signature: $digitalSignature');
    print('Sender Ed25519 Public Key: $senderEdpk');
    print('Sender X25519 Public Key: $senderXpk');
    print('HKDF Nonce: $hkdfNonce');
    print('Is Read: $isRead');
    print('Is Deleted: $isDeleted');
    print('Created At: $createdAt');
    print('Updated At: $updatedAt');
  }
}
