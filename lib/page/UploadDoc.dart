import 'package:flutter/material.dart';
import 'package:quickrider/page/login.dart';
import 'package:quickrider/page/signup.dart';

class UploadDocumentsPage extends StatelessWidget {
  const UploadDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF412160), // พื้นหลังสีม่วง
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // จัดกึ่งกลาง
            children: [
              SizedBox(height: 20), // ขยับข้อความ Quick Ride ลงมา
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: Colors.white), // ไอคอนลูกศรสีขาว
                    onPressed: () {
                      Navigator.pop(context); // กลับไปยังหน้าก่อนหน้า
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
              SizedBox(height: 20), // เพิ่มระยะห่าง

              Container(
                padding: EdgeInsets.all(30), // ปรับขนาด padding เพื่อขยายกรอบ
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center, // จัดกึ่งกลาง
                  children: [
                    Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF412160),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Upload Documents',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF412160),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        // ใส่โค้ดสำหรับอัปโหลดรูปภาพ
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        child: Icon(
                          Icons.person_add_alt_1, // ไอคอนอัปโหลดรูป
                          color: Color(0xFF412160),
                          size: 50,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // โค้ดสำหรับการ submit ข้อมูล
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF412160), // สีปุ่มม่วง
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
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
                              MaterialPageRoute(builder: (context) => Login()),
                            ); // โค้ดสำหรับไปยังหน้าลงชื่อเข้าใช้งาน
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
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // เพิ่มระยะห่างระหว่างกรอบและขอบล่าง
            ],
          ),
        ),
      ),
    );
  }
}
