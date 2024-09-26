import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:quickrider/page/Login.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';

class ScreenPage extends StatefulWidget {
  const ScreenPage({super.key});

  @override
  State<ScreenPage> createState() => _ScreenPageState();
}

class _ScreenPageState extends State<ScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    // เช็คสถานะการล็อกอิน
    bool isLoggedIn = box.read('isLoggedIn') ?? false;
    String? userid = box.read('Userid');
    String? riderid = box.read('Riderid');
    // ค่าเริ่มต้นเป็น false ถ้ายังไม่เคยล็อกอิน
    Future.delayed(Duration(seconds: 2), () {
      if (isLoggedIn) {
        if (riderid != null) {
          // ถ้าเคยล็อกอินแล้ว และ riderid มีค่า
          Get.off(() => const HomeRiderPage());
        } else if (userid != null) {
          // ถ้าเคยล็อกอินแล้ว และ userid มีค่า
          Get.off(() => const HomeUserpage());
        } else {
          // ถ้าไม่มี riderid หรือ userid
          Get.off(() => const Login());
        }
      } else {
        // ถ้าไม่ได้ล็อกอิน
        Get.off(() => const Login());
      }
    });
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF412160),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // โลโก้ (คุณสามารถแทนด้วย AssetImage หรือ NetworkImage ได้ตามต้องการ)
              Image.asset(
                'assets/img/logo.png', // ระบุเส้นทางของรูปโลโก้ใน assets
                width: 350,
              ),
              const SizedBox(height: 20), // ระยะห่างระหว่างโลโก้กับข้อความ
            ],
          ),
        ),
      ),
    );
  }
}
