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
    required String imgUrl, // Optional image URL
  }) async {
    try {
      // อัปเดตข้อมูลใน local `user`
      user.updateAll((key, value) {
        if (key == 'fullname') return fullname;
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
}
