import 'package:flutter/material.dart';
import 'package:quickrider/page/signup.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // To track password visibility

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
                Row(
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
                SizedBox(height: 20), // เพิ่มระยะห่างด้านล่าง
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 30), // ขยายด้านบนของกรอบสีขาว
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // จัดชิดซ้าย
                    children: [
                      Center(
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                      ),
                      SizedBox(height: 20), // ขยับลงให้ฟิลด์ห่างจากหัวข้อ
                      _buildTextField(
                          Icons.person, 'Email or Number', _emailController),
                      _buildPasswordField(Icons.lock, 'Password'),
                      SizedBox(height: 50), // เพิ่มระยะห่างระหว่างฟิลด์และปุ่ม
                      ElevatedButton(
                        onPressed: () {
                          // Handle login action here
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
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30), // เพิ่มระยะห่างจากปุ่ม "Login"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              // เมื่อกดปุ่มนี้จะไปยังหน้า Signup
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Signup()),
                              );
                            },
                            child: Text(
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
  Widget _buildPasswordField(IconData icon, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: _passwordController,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFF412160)),
          hintText: hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: Color(0xFF412160),
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
              });
            },
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
