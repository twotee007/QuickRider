import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';

class HistoryPageUser extends StatefulWidget {
  const HistoryPageUser({super.key});

  @override
  State<HistoryPageUser> createState() => _HistoryPageUserState();
}

class _HistoryPageUserState extends State<HistoryPageUser>
    with TickerProviderStateMixin {
  int _selectedIndex = 1;
  final userService = Get.find<UserService>();
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   loadDate = loadDataAstnc();
  // }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: cycletop(
              userService.name, // ใช้ข้อมูลชื่อจาก UserService
              userService.url, // ใช้ข้อมูล URL จาก UserService
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 150),
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Column(
                        children: [
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            indicatorColor:
                                const Color.fromARGB(255, 127, 86, 166),
                            tabs: const [
                              Tab(text: 'สินค้าที่คุณส่ง'),
                              Tab(text: 'สินค้าที่คุณได้รับ'),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSentItems(),
                                _buildReceivedItems(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildSentItems() {
    return SingleChildScrollView(
      child: Column(
        children: [Text('ตำแหน่ง Rider สินค้าที่คุณส่ง')],
      ),
    );
  }

  Widget _buildReceivedItems() {
    return SingleChildScrollView(
      child: Column(
        children: [Text('ตำแหน่ง Rider สินค้าที่คุณได้รับ')],
      ),
    );
  }

  Widget _orderRider(String namesender, String namereceiver) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 360,
              height: 90,
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
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'รายละเอียด',
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
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // Future<void> loadDataAstnc() async {
  //   String userid = box.read('Userid');
  //   try {
  //     // เข้าถึงเอกสารโดยใช้ Document ID
  //     var docSnapshot = await db.collection('Users').doc(userid).get();

  //     if (docSnapshot.exists) {
  //       log('Document ID: ${docSnapshot.id}'); // แสดง ID ของเอกสาร

  //       // เก็บข้อมูลใน Map
  //       user = docSnapshot.data() as Map<String, dynamic>?;
  //       log('Data: $user'); // แสดงข้อมูลทั้งหมด

  //       // อัปเดต UI เมื่อโหลดข้อมูลเสร็จ
  //       setState(() {}); // เรียกใช้ setState เพื่อให้ UI อัปเดต
  //     } else {
  //       log('No user found with docId: ${docSnapshot.id}');
  //     }
  //   } catch (e) {
  //     log('Error fetching user: $e');
  //   }
  // }
}
