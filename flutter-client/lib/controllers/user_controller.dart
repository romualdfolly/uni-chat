//

import 'package:get/get.dart';
import 'package:unichat_flutter/controllers/database_controller.dart';
import 'package:unichat_flutter/models/user_profile.dart';

class UserController {
  //
  final _databaseController = Get.find<DatabaseController>();

  Future<User> getUser() async {
    return _databaseController.userBox.getAll().first;
  }


  Future<void> updateUser(User user) async {
    _databaseController.userBox.put(user);
  }
}
