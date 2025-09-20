import 'package:objectbox/objectbox.dart';

@Entity()
class KeyPairEntity {
  @Id()
  int id = 0;

  String edPubKey;

  String edPrivCipher;
  String edPrivNonce;
  String edPrivMac;

  String xPubKey;

  String xPrivCipher;
  String xPrivNonce;
  String xPrivMac;

  bool isActive;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime validUntil;

  KeyPairEntity({
    required this.edPubKey,
    required this.edPrivCipher,
    required this.edPrivNonce,
    required this.edPrivMac,

    required this.xPubKey,
    required this.xPrivCipher,
    required this.xPrivNonce,
    required this.xPrivMac,

    required this.createdAt,
    required this.validUntil,
    this.isActive = true,
  });

  // checks if key is valid
  bool get isExpired {
    return DateTime.now().isAfter(validUntil);
  }
}
