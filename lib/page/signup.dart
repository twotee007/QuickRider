import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/DriverSignUp.dart';
import 'package:quickrider/page/UserSignUp.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  MapController mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF412160), // สีพื้นหลังม่วง
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20.0), // เพิ่ม padding เพื่อขยับ Row ไม่ให้ติดขอบ
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white, // ไอคอนลูกศรสีขาว
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),

                  Spacer(), // ทำให้ Quick Ride อยู่ตรงกลาง
                  Text(
                    'Quick Ride',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(flex: 2), // ปรับขนาดเพื่อให้ระยะห่างขวาเหมาะสม
                ],
              ),
            ),
            SizedBox(height: 90),
            Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold, // ตัวหนา (ถ้าต้องการ)
              ),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: () {
                // เมื่อกดปุ่มนี้จะไปยังหน้า DriverSignup
                Get.to(
                  () => const DriverSignup(),
                  transition:
                      Transition.cupertino, // ใช้ Transition.circularReveal
                  duration: Duration(milliseconds: 300),
                );
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
              onPressed: () async {
                Position position = await _determinePosition();
                context.read<AppData>().latitude = position.latitude;
                context.read<AppData>().longitude = position.longitude;
                log('Current position: ${position.latitude} ${position.longitude}');
                setState(() {});
                Get.to(
                  () => UserSignup(),
                  transition:
                      Transition.cupertino, // Specify the transition here
                  duration: Duration(milliseconds: 300),
                );
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าเปิดใช้บริการตำแหน่งหรือไม่
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
