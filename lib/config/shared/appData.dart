import 'dart:async';

import 'package:flutter/material.dart';

class AppData with ChangeNotifier {
  OrderUser order = OrderUser();
  deliveryLocation delivery = deliveryLocation();
  pickupLocation pickup = pickupLocation();
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
  StreamSubscription? listener;
  StreamSubscription? ordersSubscription;
  StreamSubscription? riderSubscription;
}

class OrderUser {
  String orderId = '';
  String senderId = '';
  String receiverId = '';
}

class deliveryLocation {
  double? latitude; // เก็บ latitude เป็น double?
  double? longitude; // เก็บ longitude เป็น double?
}

class pickupLocation {
  double? latitude; // เก็บ latitude เป็น double?
  double? longitude; // เก็บ longitude เป็น double?
}
