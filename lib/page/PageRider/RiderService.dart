import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RiderService extends GetxController {
  final box = GetStorage();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // สร้างตัวแปรเก็บข้อมูลผู้ใช้แบบ Observable
  var rider = {}.obs;

  // ฟังก์ชันโหลดข้อมูลผู้ใช้เพียงครั้งเดียวหลังจากเข้าสู่ระบบ
  Future<void> loadUserData() async {
    // อ่าน riderid จาก GetStorage
    String riderid = box.read('Riderid');
    print('Rider ID: $riderid'); // ตรวจสอบค่า riderid

    if (riderid.isEmpty) {
      print('Rider ID is null or empty.');
      return;
    }

    try {
      // ดึงข้อมูลจาก Firestore
      var docSnapshot = await db.collection('Users').doc(riderid).get();

      if (docSnapshot.exists) {
        // พิมพ์ข้อมูลจาก Firestore เพื่อตรวจสอบ
        print('Rider data from Firestore: ${docSnapshot.data()}');
        rider.value = docSnapshot.data() as Map<String, dynamic>;
      } else {
        print('No document found for rider ID: $riderid');
      }
    } catch (e) {
      print('Error fetching rider data: $e');
    }
  }

  String get name => rider['fullname'] ?? 'ไม่มีชื่อ';
  String get url => rider['img'] ?? '';
  String get email => rider['email'] ?? '';
  String get phone => rider['phone'] ?? '';
  String get date => rider['date'] ?? '';
  // String get addresscurrentJob => rider['currentJob'] ?? '';
  String get password => rider['password'] ?? '';
  String get registration => rider['registration'] ?? '';
}
