import 'package:objectbox/objectbox.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/media.dart';

@Entity()
class Message {
  @Id()
  int id;

  String content; // base64(cipherText) of the AES-GCM encrypted message
  String aesMac; // base64(mac.bytes) of the encrypted message
  String aesNonce; // base64(nonce) used for message encryption

  String aesKey; // base64(cipherText) of the AES key encrypted with AES-GCM
  String aesKeyMac; // base64(mac.bytes) of the encrypted AES key
  String aesKeyNonce; // base64(nonce) used for AES key encryption

  bool isReaded; // true if the message was read
  bool isDeleted; // true if the message was deleted
  bool isSent; // true if the message was sent by the local user

  int remoteRef;

  @Property(type: PropertyType.date)
  DateTime timestamp; // message timestamp (sent or received)

  final ToOne<Chat> chat = ToOne<Chat>(); // related chat conversation
  final ToOne<Contact> sender = ToOne<Contact>(); // message sender
  final ToOne<Contact> receiver = ToOne<Contact>(); // message receiver

  @Backlink()
  final media = ToMany<Media>(); // attached media (images, files...)

  Message({
    this.id = 0,
    required this.content,
    required this.aesMac,
    required this.aesNonce,
    required this.aesKey,
    required this.aesKeyMac,
    required this.aesKeyNonce,
    this.isReaded = false,
    this.isDeleted = false,
    required this.remoteRef,
    required this.isSent,
    required this.timestamp,
  });

  //
  void printMessage() {
    print(
      "[$id] - [$remoteRef] > $content | $timestamp | ${chat.target?.id ?? "No Chat"} | ${sender.target?.name ?? "No Sender"} - ${receiver.target?.name ?? "No Receiver"}",
    );
  }
}
