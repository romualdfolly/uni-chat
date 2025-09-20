import 'package:get/get.dart';
import 'package:unichat_flutter/models/chat.dart';
import 'package:unichat_flutter/models/contact.dart';
import 'package:unichat_flutter/models/key_pair.dart';
import 'package:unichat_flutter/models/media.dart';
import 'package:unichat_flutter/models/message.dart';
import 'package:unichat_flutter/models/user_profile.dart';
import '../objectbox.g.dart';

class DatabaseController extends GetxController {
  late final Store _store;
  late final Box<Contact> contactBox;
  late final Box<Chat> chatBox;
  late final Box<Message> messageBox; 
  late final Box<Media> mediaBox;
  late final Box<User> userBox;
  late final Box<KeyPairEntity> keyPairsBox;

  // Initialization of the database and boxes
  Future<void> init() async {
    try {
      _store = await openStore();
      contactBox = _store.box<Contact>();
      chatBox = _store.box<Chat>();
      messageBox = _store.box<Message>();
      mediaBox = _store.box<Media>();
      userBox = _store.box<User>();
      keyPairsBox = _store.box<KeyPairEntity>();
    } catch (e) {
      print("Error initializing the database: $e");
    }
  }

  // Closing the database
  Future<void> close() async {
    _store.close();
  }

  // Generic CRUD methods

  // Save a generic object in any box
  Future<void> save<T>(Box<T> box, T object) async {
    box.put(object);
  }

  // Retrieve all objects from a box
  List<T> getAll<T>(Box<T> box) {
    return box.getAll();
  }

  // Retrieve the first object from a box (if any)
  T? getFirst<T>(Box<T> box) {
    final objects = box.getAll();
    return objects.isNotEmpty ? objects.first : null;
  }

  // Retrieve an object by its ID
  T? getById<T>(Box<T> box, int id) {
    return box.get(id);
  }

  // Retrieve an object by its ID
  List<Message> getMessagesByChat(int chatId) {
    return messageBox.query(Message_.chat.equals(chatId)).build().find();
  }

  // Delete an object by its ID
  Future<void> deleteById<T>(Box<T> box, int id) async {
    box.remove(id);
  }

  // Delete an object by its ID
  Future<void> deleteAll<T>(Box<T> box) async {
    box.removeAll();
  }

  // Delete all tables
  Future<void> deleteAllTables() async {
    for (var box in [contactBox, chatBox, messageBox, mediaBox, userBox]) {
      box.removeAll();
    }
  }

  Future<KeyPairEntity?> getValidKeyPairs() async {
    //
    final box = _store.box<KeyPairEntity>();
    try {
      final keyData =
          box.query(
                KeyPairEntity_.isActive
                    .equals(true)
                    .and(
                      KeyPairEntity_.validUntil.greaterOrEqual(
                        DateTime.now().millisecondsSinceEpoch,
                      ),
                    ),
              )
              .build()
              .findFirst();

      return keyData;
    } catch (e) {
      print('Error fetching valid key pairs: $e');
      return null;
    }
  }
}
