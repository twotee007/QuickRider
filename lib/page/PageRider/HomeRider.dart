import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeRiderPage extends StatefulWidget {
  const HomeRiderPage({super.key});

  @override
  State<HomeRiderPage> createState() => _HomeRiderPageState();
}

class _HomeRiderPageState extends State<HomeRiderPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // final box = GetStorage();
    // box.remove('isLoggedIn'); // ลบสถานะการล็อกอิน
    // box.remove('Userid'); // ลบ User ID หากมี
    // box.remove('Riderid'); // ลบ Rider ID หากมี
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _cycletop('จูเนียร์',
                'https://pbs.twimg.com/profile_images/1679205589803495428/W-FssaOO_200x200.jpg'),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Container(
                width: 400,
                height: 650,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Quick Rider',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'ออเดอร์มาใหม่',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderRider(String namesender, String namereceiver) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                // Call your method here
                log('กดสำเร็จ');
              },
              child: Container(
                width: 360,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF412160),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ผู้จัดส่ง : $namesender',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ส่งให้คุณ : $namereceiver',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 18, 172, 82),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'รับงาน',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              bottom: 5,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'คลิกดูรายละเอียด',
                  style: TextStyle(
                    color: Color.fromARGB(255, 216, 58, 58),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10), // Properly placed inside the Column
      ],
    );
  }

  Widget _cycletop(String name, String url) {
    return Padding(
      padding: const EdgeInsets.only(top: 35), // กำหนดระยะห่างจากด้านบน
      child: Container(
        width: 360, // กำหนดความกว้าง
        height: 80, // กำหนดความสูง
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rider ',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: 'คุณ$name',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'ออนไลน์',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Image.asset(
                        'assets/img/motorcycle.png',
                        width: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipOval(
                child: Image.network(
                  url,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                      child:
                          const Center(child: Text('ไม่สามารถโหลดรูปภาพได้')),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
