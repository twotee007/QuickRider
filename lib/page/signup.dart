import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/DriverSignUp.dart';
import 'package:quickrider/page/UserSignUp.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF412160), // สีพื้นหลังม่วง
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // ไอคอนลูกศรสีขาว
              onPressed: () {
                Navigator.pop(context); // กดปุ่มเพื่อกลับไปหน้าก่อนหน้านี้
              },
            ),
            Text(
              'Quick Ride',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 80),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold, // ตัวหนา (ถ้าต้องการ)
              ),
            ),
            SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                // เมื่อกดปุ่มนี้จะไปยังหน้า DriverSignup
                Get.to(() => const DriverSignup());
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10),
              ),
              child: Text(
                'SignUp for Driver',
                style: TextStyle(
                  fontSize: 18, // ปรับขนาดตัวหนังสือ
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // เมื่อกดปุ่มนี้จะไปยังหน้า DriverSignup
                Get.to(() => const UserSignup());
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 85, vertical: 10),
              ),
              child: Text(
                'SignUp for User',
                style: TextStyle(
                  fontSize: 18, // ปรับขนาดตัวหนังสือ
                  // ตัวหนา (ถ้าต้องการ)
                ),
              ),
            ),
            SizedBox(height: 30),
            Image.asset(
              'assets/img/logo.png', // ใส่โลโก้ที่ตรงกับ path ของคุณ
              height: 250,
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
