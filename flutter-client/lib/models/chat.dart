import 'package:objectbox/objectbox.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/message.dart';

@Entity()
class Chat {
  @Id()
  int id;

  bool isGroup; // pour distinguer privé/groupe

  final ToMany<Contact> participants = ToMany<Contact>();
  final ToOne<Message> lastMessage = ToOne<Message>();

  Chat({
    this.id = 0,
    this.isGroup = false,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Chat) return false;

    final otherChat = other;

    // we check the size
    if (participants.length != otherChat.participants.length) return false;

    // Set of ID comparizon
    final thisIds = participants.map((c) => c.userId).toSet();
    final otherIds = otherChat.participants.map((c) => c.userId).toSet();

    return thisIds.containsAll(otherIds);
  }

  @override
  int get hashCode {
    final ids = participants.map((c) => c.userId).toList()..sort();
    return ids.fold(0, (acc, id) => acc ^ id.hashCode);
  }


  bool containsSameParticipants(List<Contact> otherParticipants) {
    final currentIds = participants.map((c) => c.userId).toSet();
    final otherIds = otherParticipants.map((c) => c.userId).toSet();
    return currentIds.length == otherIds.length && currentIds.containsAll(otherIds);
  }
}
