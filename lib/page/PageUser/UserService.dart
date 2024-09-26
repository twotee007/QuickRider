import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserService extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // สร้างตัวแปรเก็บข้อมูลผู้ใช้แบบ Observable
  var user = {}.obs;

  // ฟังก์ชันโหลดข้อมูลผู้ใช้เพียงครั้งเดียวหลังจากเข้าสู่ระบบ
  Future<void> loadUserData() async {
    String userid = box.read('Userid');
    try {
      var docSnapshot = await db.collection('Users').doc(userid).get();
      if (docSnapshot.exists) {
        user.value = docSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  String get name => user['fullname'] ?? 'ไม่มีชื่อ';
  String get url => user['img'] ?? '';
}
