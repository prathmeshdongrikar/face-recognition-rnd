import 'package:hive_flutter/hive_flutter.dart';

import 'user_dto.dart';

class FaceAuthDB {
  static const authBoxName = "authBox";
  static const usersKey = "users";
  static const loggedInUserKey = 'loggedInUser';

  static initialize() async {
    await Hive.openBox(authBoxName);
  }

  static clearAllBox() async {
    final authBox = await Hive.openBox(authBoxName);
    await authBox.clear();
  }

  static Future<List<UserDto>> getUsersData() async {
    try {
      final box = await Hive.openBox(authBoxName);

      List<dynamic> existingData = await box.get(usersKey, defaultValue: []);
      List<UserDto> data = [];
      for (UserDto user in existingData) {
        data.add(user);
      }

      return data;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> addNewUser({required UserDto newUser}) async {
    try {
      final box = await Hive.openBox(authBoxName);

      List<dynamic> lsOfUserData = await getUsersData();
      List<UserDto> existingUsers = [];
      for (UserDto user in lsOfUserData) {
        existingUsers.add(user);
      }
      List<UserDto> updatedData = [...existingUsers];

      updatedData.insert(0, newUser);
      await box.put(usersKey, updatedData);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setLoggedInUser({required UserDto user}) async {
    try {
      final box = await Hive.openBox(authBoxName);

      await box.put(loggedInUserKey, user);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<UserDto?> getLoggedInUser() async {
    final box = await Hive.openBox(authBoxName);

    final user = await box.get(loggedInUserKey);

    return user;
  }
}
