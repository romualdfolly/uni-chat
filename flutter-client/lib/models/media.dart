import 'package:objectbox/objectbox.dart';
import 'package:unichat_flutter/models/message.dart';

@Entity()
class Media {
  @Id()
  int id;

  final String type;
  final String path;
  final String aesKey;

  final ToOne<Message> message = ToOne<Message>();

  Media({
    this.id = 0,
    required this.type,
    required this.path,
    required this.aesKey
  });
}
