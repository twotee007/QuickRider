import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/PageUser/HistoryUser.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';
import 'package:quickrider/page/PageUser/ProfileUser.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex; // ค่า index ปัจจุบัน

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required void Function(int index) onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // สีพื้นหลังสำหรับ navigation bar
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(30)), // โค้งที่ด้านบน
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // สีของเงา
            blurRadius: 8.0, // ขอบเบลอของเงา
            offset: Offset(0, -4), // ตำแหน่งของเงา
          ),
        ],
      ),
      child: ClipRRect(
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
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.shifting,
          onTap: (index) {
            _onItemTapped(context, index);
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

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Get.to(() => const HomeUserpage());
        break;
      case 1:
        // เปลี่ยนหน้าไป HistoryPage
        Get.to(() => const HistoryPageUser());
        break;
      case 2:
        // เปลี่ยนหน้าไป ProfilePage
        Get.to(() => const ProfilePageUser());
        break;
    }
  }
}
