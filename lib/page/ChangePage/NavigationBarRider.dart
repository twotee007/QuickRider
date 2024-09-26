import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/PageRider/HistoryRider.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageRider/ProfileRider.dart';

class CustomBottomNavigationBarRider extends StatelessWidget {
  final int currentIndex; // ค่า index ปัจจุบัน
  final ValueChanged<int> onTap; // เพิ่ม callback สำหรับการคลิก

  const CustomBottomNavigationBarRider({
    Key? key,
    required this.currentIndex,
    required this.onTap, // รับฟังก์ชัน onTap จาก parent widget
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // สีพื้นหลังสำหรับ navigation bar
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // สีของเงา
            blurRadius: 8.0, // ขอบเบลอของเงา
            offset: Offset(0, -4), // ตำแหน่งของเงา
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)), // โค้งที่ด้านบน
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'หน้าแรก',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'ประวัติ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'บัญชี',
            ),
          ],
          currentIndex: currentIndex,
          selectedItemColor: Color.fromARGB(255, 89, 61, 117),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed, // ใช้ shifting เพื่อความสมูท
          onTap: (index) {
            onTap(index); // เรียกใช้งานฟังก์ชัน onTap
            _onItemTapped(index); // ร่วมกับการเปลี่ยนหน้า
          },
          iconSize: 30,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    // ใช้ Get.off เพื่อปิดหน้าปัจจุบันและเปิดหน้าใหม่โดยไม่มี transition
    switch (index) {
      case 0:
        Get.to(() => const HomeRiderPage(),
            transition: Transition.noTransition,
            duration: const Duration(milliseconds: 300));
        break;
      case 1:
        Get.to(() => const HistoryPageRider(),
            transition: Transition.noTransition,
            duration: const Duration(milliseconds: 300));
        break;
      case 2:
        Get.to(() => const ProfilePageRider(),
            transition: Transition.noTransition,
            duration: const Duration(milliseconds: 300));
        break;
    }
  }
}
