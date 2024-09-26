import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/Login.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:get_storage/get_storage.dart'; // นำเข้า GetStorage

class ProfilePageUser extends StatefulWidget {
  const ProfilePageUser({super.key});

  @override
  State<ProfilePageUser> createState() => _ProfilePageUserState();
}

class _ProfilePageUserState extends State<ProfilePageUser> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    final box = GetStorage();
    box.remove('isLoggedIn'); // ลบสถานะการล็อกอิน
    box.remove('Userid'); // ลบ User ID หากมี
    box.remove('Riderid'); // ลบ Rider ID หากมี
    // คุณสามารถเพิ่มการนำทางไปยังหน้า Login หรือหน้าหลักได้ที่นี่
    Get.off(() => const Login()); // เปลี่ยนไปที่หน้า Login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: cycletop('จูเนียร์',
                'https://pbs.twimg.com/profile_images/1679205589803495428/W-FssaOO_200x200.jpg'),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // ปุ่มล็อกเอาต์
                          ElevatedButton(
                            onPressed: _logout,
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.red, // เปลี่ยนสีปุ่ม
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'ล็อกเอาต์',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
