import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/PageUser/AddProduct.dart';
import 'package:quickrider/page/PageUser/DeliveryStatus.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';
import 'package:uuid/uuid.dart';

class HomeUserpage extends StatefulWidget {
  const HomeUserpage({super.key});

  @override
  State<HomeUserpage> createState() => _HomeUserpageState();
}

class _HomeUserpageState extends State<HomeUserpage>
    with TickerProviderStateMixin {
  late Map<String, dynamic>? user;
  int _selectedIndex = 0;
  final userService = Get.find<UserService>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    userService.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    TabController _tabController = TabController(length: 2, vsync: this);

    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      floatingActionButton: RawMaterialButton(
        onPressed: () {
          Get.to(() => const AddProductPage(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 300));
        },
        shape: const CircleBorder(),
        elevation: 0,
        fillColor: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage('assets/img/Plus.png'),
              fit: BoxFit.cover,
            ),
          ),
          width: 60,
          height: 60,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: cycletop(
              userService.name,
              userService.url,
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
                              Tab(text: 'สินค้าที่คุณรับ'),
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
          ),
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
        children: [
          const SizedBox(height: 10),
          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
          _orderRider('อัครผล', 'วู้ดดี้ จิน'),
        ],
      ),
    );
  }

  // Widget _buildSentItems() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection('orderItems')
  //         .where('sender',
  //             isEqualTo: userService.name) // ดึงสินค้าที่ส่งจากผู้ใช้
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return const Center(child: Text('ไม่มีสินค้าที่คุณส่ง'));
  //       }
  //       var items = snapshot.data!.docs;
  //       return ListView.builder(
  //         itemCount: items.length,
  //         itemBuilder: (context, index) {
  //           var data = items[index].data() as Map<String, dynamic>;
  //           return _orderRider(data['sender'], data['receiver']);
  //         },
  //       );
  //     },
  //   );
  // }
  Widget _buildReceivedItems() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _orderRider('วู้ดดี้ จิน', 'อัครผล'),
          _orderRider('วู้ดดี้ จิน', 'อัครผล'),
        ],
      ),
    );
  }
  // Widget _buildReceivedItems() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: FirebaseFirestore.instance
  //         .collection('orderItems')
  //         .where('receiver',
  //             isEqualTo: userService.name) // ดึงสินค้าที่รับจากผู้ใช้
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return const Center(child: Text('ไม่มีสินค้าที่คุณรับ'));
  //       }
  //       var items = snapshot.data!.docs;
  //       return ListView.builder(
  //         itemCount: items.length,
  //         itemBuilder: (context, index) {
  //           var data = items[index].data() as Map<String, dynamic>;
  //           return _orderRider(data['sender'], data['receiver']);
  //         },
  //       );
  //     },
  //   );
  // }

  Widget _orderRider(String senderName, String receiverName) {
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
                          'ผู้จัดส่ง : $senderName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ส่งให้คุณ : $receiverName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => DeliveryStatusScreen(),
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ดูสถานะ',
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
}
