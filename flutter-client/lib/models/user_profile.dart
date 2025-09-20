import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/objectbox.g.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class User {
  @Id()
  int id; // Identifiant unique

  // ignore: non_constant_identifier_names
  int user_id;
  String username;
  String name;
  String email;
  String authToken;

  @Property(type: PropertyType.date)
  DateTime? emailVerifiedAt;

  @Property(type: PropertyType.date)
  DateTime? lastConnectionAt;

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  // Constructor
  User({
    this.id = 0,
    // ignore: non_constant_identifier_names
    required this.user_id,
    required this.username,
    required this.name,
    required this.email,
    required this.authToken,
    this.emailVerifiedAt,
    this.lastConnectionAt,
    required this.createdAt,
    required this.updatedAt,
  });
}

extension UserContactExtension on User {
  Contact? getContacts() {
    final contactBox = Get.find<DatabaseController>().contactBox;

    return contactBox
        .query(Contact_.userId.equals(user_id))
        .build()
        .findFirst();
  }
}
