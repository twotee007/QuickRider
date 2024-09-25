import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/main.dart';
import 'package:quickrider/page/UploadDoc.dart';
import 'package:quickrider/page/login.dart';
import 'package:quickrider/page/signup.dart';

class UserSignup extends StatefulWidget {
  const UserSignup({super.key});

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  bool _isPasswordHidden = true; // ตัวแปรเพื่อเก็บสถานะการซ่อนรหัสผ่าน
  bool _isConfirmPasswordHidden = true; // ตัวแปรสำหรับ Confirm Password
  TextEditingController fullnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController comPasswordCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController estateCtl = TextEditingController();
  TextEditingController dateCtl = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  String text = '';
  bool _isLoading = false; // ตัวแปรสำหรับควบคุมสถานะการโหลด
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160), // สีพื้นหลังม่วง
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, // จัดตำแหน่งซ้าย
                children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      const Text(
                        'Quick Ride',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF412160),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'User Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                        const SizedBox(height: 13),
                        _buildTextField(Icons.person, 'FullName', fullnameCtl),
                        _buildTextField(Icons.email, 'Email Id', emailCtl),
                        _buildPasswordField(
                          Icons.lock,
                          'Password',
                          isPassword: true,
                          isHidden: _isPasswordHidden,
                          toggleVisibility: () {
                            setState(() {
                              _isPasswordHidden = !_isPasswordHidden;
                            });
                          },
                          controller: passwordCtl,
                        ),
                        _buildPasswordField(
                          Icons.lock,
                          'Confirm Password',
                          isPassword: true,
                          isHidden: _isConfirmPasswordHidden,
                          toggleVisibility: () {
                            setState(() {
                              _isConfirmPasswordHidden =
                                  !_isConfirmPasswordHidden;
                            });
                          },
                          controller: comPasswordCtl,
                        ),
                        _buildTextField(Icons.phone, 'Mobile Number', phoneCtl),
                        TextField(
                          controller: dateCtl,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            hintText: 'Date of birth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: Color(0xFF412160)),
                            ),
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );

                            if (pickedDate != null) {
                              String formattedDate =
                                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                              dateCtl.text = formattedDate;
                            }
                          },
                        ),
                        _buildTextField(Icons.home, 'Estate & City', estateCtl),
                        Center(child: Text(text)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  cheacksignup();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF412160),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Next Add Photos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF412160),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller, // ใช้คอนโทรลเลอร์เพื่อเก็บค่า
        obscureText: isPassword,
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
  Widget _buildPasswordField(IconData icon, String hintText,
      {required bool isPassword,
      required bool isHidden,
      required VoidCallback toggleVisibility,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller, // ใช้คอนโทรลเลอร์เพื่อเก็บค่า
        obscureText: isHidden, // ซ่อนรหัสผ่านถ้าจำเป็น
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF412160)),
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF412160),
            ),
            onPressed: toggleVisibility, // เปลี่ยนสถานะการแสดงรหัสผ่าน
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void cheacksignup() async {
    setState(() {
      _isLoading = true; // เริ่มการโหลด
    });
    try {
      final emailPattern = r'^[^@]+@[^@]+\.[^@]+$'; // รูปแบบการตรวจสอบอีเมล
      final phonePattern =
          r'^[0-9]+$'; // รูปแบบการตรวจสอบเบอร์โทรที่เป็นตัวเลขเท่านั้น

      final emailRegExp = RegExp(emailPattern);
      final phoneRegExp = RegExp(phonePattern);

      // ใช้ trim() เพื่อตรวจสอบช่องว่าง
      if (fullnameCtl.text.trim().isEmpty ||
          emailCtl.text.trim().isEmpty ||
          passwordCtl.text.trim().isEmpty ||
          comPasswordCtl.text.trim().isEmpty ||
          phoneCtl.text.trim().isEmpty ||
          dateCtl.text.trim().isEmpty ||
          estateCtl.text.trim().isEmpty) {
        setState(() {
          text = 'กรุณาเติมให้ครบช่องว่าง';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      var userSnapshot = await db
          .collection('Users')
          .where('email', isEqualTo: emailCtl.text.trim())
          .where('phone', isEqualTo: phoneCtl.text.trim())
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        setState(() {
          text = 'Email หรือ เบอร์โทร ซ้ำกรุณาใส่ใหม่อีกครั้ง';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }

      // ตรวจสอบว่าอีเมลซ้ำหรือไม่
      var emailSnapshot = await db
          .collection('Users')
          .where('email', isEqualTo: emailCtl.text.trim())
          .get();

      if (emailSnapshot.docs.isNotEmpty) {
        setState(() {
          text = 'Email ซ้ำกรุณาใส่ใหม่อีกครั้ง';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }

      // ตรวจสอบว่าเบอร์โทรซ้ำหรือไม่
      var phoneSnapshot = await db
          .collection('Users')
          .where('phone', isEqualTo: phoneCtl.text.trim())
          .get();

      if (phoneSnapshot.docs.isNotEmpty) {
        setState(() {
          text = 'เบอร์โทร ซ้ำกรุณาใส่ใหม่อีกครั้ง';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      // ตรวจสอบรูปแบบอีเมล
      if (!emailRegExp.hasMatch(emailCtl.text.trim())) {
        setState(() {
          text = 'กรุณากรอกอีเมลให้ถูกต้อง';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      // ตรวจสอบว่าเบอร์โทรศัพท์มีแต่ตัวเลข
      if (!phoneRegExp.hasMatch(phoneCtl.text.trim())) {
        setState(() {
          text = 'กรุณากรอกเบอร์โทรให้เป็นตัวเลขเท่านั้น';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      // ตรวจสอบความยาวเบอร์โทรศัพท์ต้องมี 10 ตัว
      if (phoneCtl.text.trim().length != 10) {
        setState(() {
          text = 'เบอร์โทรศัพท์ต้องมี 10 หลัก';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      // ตรวจสอบว่าเบอร์โทรศัพท์ต้องเริ่มด้วย 0
      if (!phoneCtl.text.trim().startsWith('0')) {
        setState(() {
          text = 'กรุณากรอกเบอร์โทรให้ถูกต้อง (ต้องเริ่มด้วย 0)';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      // ตรวจสอบว่ารหัสผ่านและการยืนยันรหัสผ่านตรงกัน
      if (passwordCtl.text.trim() != comPasswordCtl.text.trim()) {
        setState(() {
          text = 'รหัสผ่านไม่เหมือนกันกรุณาใส่ให้ตรงกัน';
          _isLoading = false; // จบการโหลดเมื่อมีข้อผิดพลาด
        });
        return;
      }
      Position position = await _determinePosition();
      // เก็บข้อมูลลงใน AppData
      context.read<AppData>().fullname = fullnameCtl.text.trim();
      context.read<AppData>().email = emailCtl.text.trim();
      context.read<AppData>().password = passwordCtl.text.trim();
      context.read<AppData>().phone = phoneCtl.text.trim();
      context.read<AppData>().date = dateCtl.text.trim();
      context.read<AppData>().estate = estateCtl.text.trim();
      context.read<AppData>().type = 'user';
      context.read<AppData>().latitude = position.latitude;
      context.read<AppData>().longitude = position.longitude;
      // นำไปสู่หน้าถัดไป
      Get.to(
        () => const UploadDocumentsPage(),
        transition: Transition.cupertino, // Specify the transition here
        duration: Duration(milliseconds: 300),
      );
    } catch (e) {
      setState(() {
        text = 'เกิดข้อผิดพลาด: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // จบการโหลดเมื่อเสร็จสิ้น
      });
    }
  }
}
