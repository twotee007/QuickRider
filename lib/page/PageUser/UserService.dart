import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  var user = {}.obs;

  Future<void> loadUserData() async {
    String userid = box.read('Userid');

    if (userid == null || userid.isEmpty) {
      print('User ID is null or empty.');
      return;
    }

    try {
      var docSnapshot = await db.collection('Users').doc(userid).get();

      if (docSnapshot.exists) {
        user.value = docSnapshot.data() as Map<String, dynamic>;
      } else {
        print('No document found for user ID: $userid');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // ฟังก์ชันอัปเดตข้อมูลผู้ใช้ใน Firestore
  Future<void> updateUserData({
    required String fullname,
    required String email,
    required String phone,
    required String date,
    required String address,
    required String password,
    String imgUrl = '', // Optional image URL
  }) async {
    String userid = box.read('Userid');

    if (userid == null || userid.isEmpty) {
      print('User ID is null or empty.');
      return;
    }

    try {
      // Create a map of updated user data
      Map<String, dynamic> updatedData = {
        'fullname': fullname,
        'email': email,
        'phone': phone,
        'date': date,
        'address': address,
        'password': password,
      };

      // If imgUrl is provided, add it to the map
      if (imgUrl.isNotEmpty) {
        updatedData['img'] = imgUrl; // Update the image URL if it exists
      }

      // อัปเดตข้อมูลใน Firestore
      await db.collection('Users').doc(userid).update(updatedData);

      // อัปเดตข้อมูลใน local `user`
      user.updateAll((key, value) {
        if (key == 'fullname') return fullname;
        if (key == 'email') return email;
        if (key == 'phone') return phone;
        if (key == 'date') return date;
        if (key == 'address') return address;
        if (key == 'password') return password;
        if (key == 'img') return imgUrl; // Update the image URL if it exists
        return value;
      });

      print('User data updated successfully in Firestore');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  String get name => user['fullname'] ?? 'ไม่มีชื่อ';
  String get url => user['img'] ?? '';
  String get email => user['email'] ?? '';
  String get phone => user['phone'] ?? '';
  String get date => user['date'] ?? '';
  String get address => user['address'] ?? '';
  String get password => user['password'] ?? '';
}
