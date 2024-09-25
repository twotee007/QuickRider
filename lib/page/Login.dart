import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';
import 'package:quickrider/page/signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String text = '';
  bool _isPasswordVisible = false; // To track password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160), // สีพื้นหลังม่วง
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // จัดตำแหน่งซ้าย
              children: <Widget>[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(flex: 2), // ดัน Quick Ride ให้อยู่ตรงกลาง
                    Text(
                      'Quick Ride',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(flex: 2), // ดันไอคอนกับข้อความให้อยู่แนวเดียวกัน
                  ],
                ),
                const SizedBox(height: 20), // เพิ่มระยะห่างด้านล่าง
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 30), // ขยายด้านบนของกรอบสีขาว
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
                    children: [
                      const Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20), // ขยับลงให้ฟิลด์ห่างจากหัวข้อ
                      _buildTextField(Icons.person, 'Email', _emailController),
                      _buildPasswordField(Icons.lock, 'Password'),
                      Center(child: Text(text)),
                      const SizedBox(
                          height: 20), // เพิ่มระยะห่างระหว่างฟิลด์และปุ่ม
                      ElevatedButton(
                        onPressed: () {
                          cheacklogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF412160), // สีม่วง
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          height: 30), // เพิ่มระยะห่างจากปุ่ม "Login"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              Get.to(
                                () => Signup(),
                                transition: Transition.cupertino,
                                duration: Duration(
                                    milliseconds:
                                        300), // ระยะเวลาที่ใช้ในการเปลี่ยนหน้า
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Color(0xFF412160),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF412160)),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF412160)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF412160)),
          ),
        ),
      ),
    );
  }

  // สร้าง TextField สำหรับรหัสผ่านที่มีไอคอนเปิด/ปิดตา
  Widget _buildPasswordField(IconData icon, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF412160)),
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF412160),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF412160)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Color(0xFF412160)),
          ),
        ),
      ),
    );
  }

  void cheacklogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        text = 'กรุณากรอก Email และ Password ให้ถูกต้อง';
      });
      return;
    }

    // ดึงข้อมูลจาก Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('email', isEqualTo: _emailController.text)
        .get();

    if (snapshot.docs.isNotEmpty) {
      // พบอีเมลในฐานข้อมูล
      String storedPassword =
          snapshot.docs.first['password']; // ดึงรหัสผ่านจากฐานข้อมูล
      String userType =
          snapshot.docs.first['type']; // ดึงประเภทผู้ใช้จากฐานข้อมูล
      if (storedPassword == _passwordController.text) {
        log('เข้าสู่ระบบสำเร็จ');
        if (userType == 'user') {
          Get.to(() => const HomeUserpage());
        } else {
          Get.to(() => const HomeRiderPage());
        }
      } else {
        setState(() {
          text = 'รหัสผ่านไม่ถูกต้อง';
        });
        return;
      }
    } else {
      setState(() {
        text = 'ไม่พบอีเมลนี้ในระบบ';
      });
      return;
    }
  }
}
