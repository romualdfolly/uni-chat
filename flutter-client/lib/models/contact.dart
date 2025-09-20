import 'package:objectbox/objectbox.dart';
import 'package:unichat_flutter/models/chat.dart';

@Entity()
class Contact {
  @Id()
  int id; // auto-increment

  int userId;
  String email;
  String username;
  String name;
  String edPublicKey;
  String xPublicKey;
  String picture;
  int keyId;

  final ToMany<Chat> chats = ToMany<Chat>();

  Contact({
    this.id = 0,
    required this.userId,
    required this.email,
    required this.username,
    required this.name,
    required this.edPublicKey,
    required this.xPublicKey,
    required this.keyId,
    required this.picture,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'] ?? 0,
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      name: json['name'],
      edPublicKey: json['ePublicKey'],
      xPublicKey: json['xPublicKey'],
      keyId: json['keyId'],
      picture: json['picture'],
    );
  }

  void describe() {
    print("[+++] > id: $id, userId: $userId, Name: $name, $username, $email");
  }
}
