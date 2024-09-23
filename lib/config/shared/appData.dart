import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  UserProfile _userProfile = UserProfile();
  String fullname = '';
  String email = '';
  String password = '';
  String phone = '';
  String date = '';
  String estate = '';
  String registration = '';
  String type = '';
  double? latitude; // เก็บ latitude เป็น double?
  double? longitude; // เก็บ longitude เป็น double?
}

class UserProfile {
  int idx = 0;
  String fullname = '';
}
