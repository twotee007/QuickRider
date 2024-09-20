import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF412160), // สีพื้นหลังม่วง
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // จัดตำแหน่งซ้าย
              children: <Widget>[
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Colors.white), // ไอคอนลูกศรสีขาว
                      onPressed: () {
                        Navigator.pop(
                            context); // กดปุ่มเพื่อกลับไปหน้าก่อนหน้านี้
                      },
                    ),
                    Spacer(), // ดัน Quick Ride ให้อยู่ตรงกลาง
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
                SizedBox(height: 10), // เพิ่มระยะห่างด้านล่าง
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
                    children: [
                      Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'User Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF412160),
                        ),
                      ),
                      SizedBox(height: 13),
                      _buildTextField(Icons.person, 'Full Name'),
                      _buildTextField(Icons.email, 'Email Id'),
                      _buildPasswordField(Icons.lock, 'Password',
                          isPassword: true,
                          isHidden: _isPasswordHidden, toggleVisibility: () {
                        setState(() {
                          _isPasswordHidden =
                              !_isPasswordHidden; // เปลี่ยนสถานะการซ่อนรหัสผ่าน
                        });
                      }),
                      _buildPasswordField(Icons.lock, 'Confirm Password',
                          isPassword: true, isHidden: _isConfirmPasswordHidden,
                          toggleVisibility: () {
                        setState(() {
                          _isConfirmPasswordHidden =
                              !_isConfirmPasswordHidden; // เปลี่ยนสถานะการซ่อนรหัสผ่าน Confirm
                        });
                      }),
                      _buildTextField(Icons.phone, 'Mobile Number'),
                      _buildTextField(Icons.calendar_today, 'Date of birth'),
                      _buildTextField(Icons.home,
                          'Estate & City'), // เปลี่ยนไอคอนเป็นไอคอนสถานที่
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // เมื่อกดปุ่มนี้จะไปยังหน้า DriverSignup
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UploadDocumentsPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF412160), // สีม่วง
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Next Add Photos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              ); // กดเพื่อไปยังหน้าลงชื่อเข้าใช้งาน (Sign In)
                            },
                            child: Text(
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
      ),
    );
  }

  Widget _buildTextField(IconData icon, String hintText,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF412160)),
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF412160)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF412160)),
          ),
        ),
      ),
    );
  }

  // สร้าง TextField สำหรับรหัสผ่านที่มีไอคอนเปิด/ปิดตา
  Widget _buildPasswordField(IconData icon, String hintText,
      {required bool isPassword,
      required bool isHidden,
      required VoidCallback toggleVisibility}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        obscureText: isHidden,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF412160)),
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF412160),
            ),
            onPressed: toggleVisibility, // เปลี่ยนสถานะการแสดงรหัสผ่าน
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF412160)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Color(0xFF412160)),
          ),
        ),
      ),
    );
  }
}
