import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/UploadDoc.dart';
import 'package:quickrider/page/login.dart';
import 'package:quickrider/page/signup.dart';

class DriverSignup extends StatefulWidget {
  const DriverSignup({super.key});

  @override
  State<DriverSignup> createState() => _DriverSignupState();
}

class _DriverSignupState extends State<DriverSignup> {
  bool _isPasswordHidden = true; // ตัวแปรเพื่อเก็บสถานะการซ่อนรหัสผ่าน
  bool _isConfirmPasswordHidden = true; // ตัวแปรสำหรับ Confirm Password
  TextEditingController fullnameCtl = TextEditingController();
  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();
  TextEditingController comPasswordCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController registrationCtl = TextEditingController();
  TextEditingController dateCtl = TextEditingController();
  String text = '';
  bool _isLoading = false; // ตัวแปรสำหรับควบคุมสถานะการโหลด
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160), // สีพื้นหลังม่วง
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(17.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // จัดตำแหน่งซ้าย
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white), // ไอคอนลูกศรสีขาว
                          onPressed: () {
                            Navigator.pop(
                                context); // กดปุ่มเพื่อกลับไปหน้าก่อนหน้านี้
                          },
                        ),
                        const Spacer(), // ดัน Quick Ride ให้อยู่ตรงกลาง
                        const Text(
                          'Quick Ride',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(
                            flex: 2), // ดันไอคอนกับข้อความให้อยู่แนวเดียวกัน
                      ],
                    ),
                    const SizedBox(height: 10), // เพิ่มระยะห่างด้านล่าง
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // จัดชิดซ้าย
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
                            'Driver Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF412160),
                            ),
                          ),
                          const SizedBox(height: 13),
                          _buildTextField(
                              Icons.person, 'FullName', fullnameCtl),
                          _buildTextField(Icons.email, 'Email Id', emailCtl),
                          _buildPasswordField(
                            Icons.lock,
                            'Password',
                            isPassword: true,
                            isHidden: _isPasswordHidden,
                            toggleVisibility: () {
                              setState(() {
                                _isPasswordHidden =
                                    !_isPasswordHidden; // เปลี่ยนสถานะการซ่อนรหัสผ่าน
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
                                    !_isConfirmPasswordHidden; // เปลี่ยนสถานะการซ่อนรหัสผ่าน Confirm
                              });
                            },
                            controller: comPasswordCtl,
                          ),
                          _buildTextField(
                              Icons.phone, 'Mobile Number', phoneCtl,
                              isMobileNumber: true),
                          const SizedBox(height: 10),
                          TextField(
                            controller: dateCtl,
                            readOnly: true, // ป้องกันการพิมพ์
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
                              // แสดง DatePicker เมื่อผู้ใช้แตะที่ TextField
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(), // วันที่เริ่มต้น
                                firstDate:
                                    DateTime(1900), // วันที่เริ่มต้นที่เลือกได้
                                lastDate:
                                    DateTime.now(), // วันที่สิ้นสุดที่เลือกได้
                              );

                              if (pickedDate != null) {
                                // แสดงวันที่ใน TextField
                                String formattedDate =
                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                dateCtl.text =
                                    formattedDate; // อัปเดต TextField
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildTextField(Icons.car_repair, 'Car registration',
                              registrationCtl),
                          Center(child: Text(text)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              cheacksignup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFF412160), // สีม่วง
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
                                  ); // กดเพื่อไปยังหน้าลงชื่อเข้าใช้งาน (Sign In)
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
      {bool isPassword = false, bool isMobileNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller, // ใช้คอนโทรลเลอร์เพื่อเก็บค่า
        obscureText: isPassword,
        keyboardType: isMobileNumber
            ? TextInputType.number
            : TextInputType
                .text, // ตั้งค่าให้พิมพ์ได้เฉพาะตัวเลขสำหรับเบอร์โทรศัพท์
        inputFormatters: isMobileNumber
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly, // รับเฉพาะตัวเลข
                LengthLimitingTextInputFormatter(
                    10), // จำกัดความยาวสูงสุด 10 ตัว
              ]
            : null,
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
          registrationCtl.text.trim().isEmpty) {
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

      // เก็บข้อมูลลงใน AppData
      context.read<AppData>().fullname = fullnameCtl.text.trim();
      context.read<AppData>().email = emailCtl.text.trim();
      context.read<AppData>().password = passwordCtl.text.trim();
      context.read<AppData>().phone = phoneCtl.text.trim();
      context.read<AppData>().date = dateCtl.text.trim();
      context.read<AppData>().registration = registrationCtl.text.trim();
      context.read<AppData>().type = 'rider';

      // นำไปสู่หน้าถัดไป
      Get.to(() => const UploadDocumentsPage(),
          transition: Transition.cupertino, // Specify the transition here
          duration: Duration(milliseconds: 300));
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
