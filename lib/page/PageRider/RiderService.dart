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

  Future<void> updateRiderData({
    required String fullname,
    required String imgUrl, // Optional image URL
  }) async {
    try {
      // อัปเดตข้อมูลใน local `user`
      rider.updateAll((key, value) {
        if (key == 'fullname') return fullname;
        if (key == 'img') return imgUrl; // Update the image URL if it exists
        return value;
      });

      print('User data updated successfully in Firestore');
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  String get name => rider['fullname'] ?? 'ไม่มีชื่อ';
  String get url => rider['img'] ?? '';
  Map<String, double> get gpsLocation => {
        'latitude': rider['gpsLocation']?['latitude'] ?? 0.0,
        'longitude': rider['gpsLocation']?['longitude'] ?? 0.0,
      };
}
