import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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
  late LatLng latLng;
  MapController mapController = MapController();
  double? latitude;
  double? longitude;
  String text = '';
  bool _isLoading = false; // ตัวแปรสำหรับควบคุมสถานะการโหลด
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    latitude = context.read<AppData>().latitude;
    longitude = context.read<AppData>().longitude;
    latLng = LatLng(latitude ?? 13.7524938, longitude ?? 100.4935089);
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
                        const SizedBox(height: 10),
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
                        _buildTextField(Icons.phone, 'Mobile Number', phoneCtl,
                            isMobileNumber: true),

                        const SizedBox(height: 10),
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
                        const SizedBox(height: 10),
                        _buildTextField(Icons.home, 'Estate & City', estateCtl),
                        const SizedBox(
                            height: 10), // Add some spacing between the fields
                        Center(
                          child: SizedBox(
                            width: 250, // Set the desired width here
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _showMapPopup(
                                    context); // Call the function to show the map or handle location
                                log('My Location button pressed');
                              },
                              icon: const Icon(
                                  Icons.my_location), // Location Icon
                              label: const Text(
                                'Use Current Location',
                                style: TextStyle(
                                    color: Colors.white), // White text
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFF412160), // Button background color
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ),

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

  void _showMapPopup(BuildContext context) {
    LatLng initialLatLng = latLng; // บันทึก latLng ปัจจุบัน
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            // ใช้ StatefulBuilder เพื่ออัปเดตสถานะใน dialog
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    height: 500,
                    width: 400,
                    child: Column(
                      children: [
                        const Text(
                          'Select Location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Expanded(
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: mapController,
                                options: MapOptions(
                                  initialCenter: initialLatLng,
                                  initialZoom: 15.0,
                                  onTap: (tapPosition, tappedLatLng) {
                                    setState(() {
                                      initialLatLng =
                                          tappedLatLng; // อัปเดตตำแหน่งมาร์กเกอร์
                                    });
                                    log('Marker placed at: ${initialLatLng.latitude}, ${initialLatLng.longitude}');

                                    mapController.move(initialLatLng,
                                        mapController.camera.zoom);
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                    maxNativeZoom: 19,
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: initialLatLng,
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        alignment: Alignment.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: FloatingActionButton(
                                  backgroundColor: Colors.white,
                                  onPressed: () async {
                                    Position position =
                                        await _determinePosition();
                                    log('Current position: ${position.latitude} ${position.longitude}');
                                    initialLatLng = LatLng(
                                        position.latitude, position.longitude);
                                    setState(() {}); // อัปเดต latLng ใน dialog
                                    mapController.move(initialLatLng,
                                        mapController.camera.zoom);
                                  },
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AppData>().latitude =
                                initialLatLng.latitude;
                            context.read<AppData>().longitude =
                                initialLatLng.longitude;
                            Navigator.of(context).pop(); // ปิดหน้าต่างป๊อปอัพ
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF412160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'ยืนยัน',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop(); // ปิดหน้าต่างเมื่อกดกากบาท
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

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
          text = 'รหัสผ่านไม่ตรงกัน';
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
      context.read<AppData>().estate = estateCtl.text.trim();
      context.read<AppData>().type = 'user';

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
