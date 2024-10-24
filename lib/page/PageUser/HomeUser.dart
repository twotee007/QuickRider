import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/PageUser/AddProduct.dart';
import 'package:quickrider/page/PageUser/DeliveryStatus.dart';
import 'package:quickrider/page/PageUser/MapScreen.dart';
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
  final box = GetStorage();
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
    String userId = box.read('Userid');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('senderId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        // ตรวจสอบว่ามีออเดอร์ที่ไม่ใช่สถานะ 4 หรือไม่
        bool hasActiveOrders = orders.any((order) => order['status'] != '4');

        // ถ้าไม่มีออเดอร์ที่ไม่ใช่สถานะ 4
        if (!hasActiveOrders) {
          return const Center(child: Text('คุณยังไม่มีการส่งสินค้า'));
        }

        return Column(
          children: [
            // แสดงปุ่มถ้ามีออเดอร์ที่ไม่ใช่สถานะ 4
            if (hasActiveOrders)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    box.write('senderId', true);
                    Get.to(() => const MapscreenPage(),
                        arguments: {
                          'senderId': userId,
                        },
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300));
                    log("ปุ่มถูกกด");
                  },
                  child: const Text(
                    'ดูตำแหน่ง Rider ทั้งหมดของสินค้าที่คุณส่ง',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final receiverId = order['receiverId'];
                  final orderId = order.id;
                  final status = order['status']; // ดึงสถานะ

                  // ถ้าสถานะเป็น 4 จะไม่แสดงออเดอร์นี้
                  if (status == '4') {
                    return const SizedBox.shrink(); // ซ่อน Widget
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(receiverId)
                        .get(),
                    builder: (context, receiverSnapshot) {
                      if (!receiverSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final receiverData = receiverSnapshot.data!;
                      final receiverName =
                          receiverData['fullname'] ?? 'ไม่ระบุ';

                      return _orderRider(
                        userService.name,
                        receiverName,
                        orderId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReceivedItems() {
    String userId = box.read('Userid');
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('receiverId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        // ตรวจสอบว่าไม่มีออเดอร์
        bool hasActiveOrders = orders.any((order) => order['status'] != '4');

        // ถ้าไม่มีออเดอร์ที่ไม่ใช่สถานะ 4
        if (!hasActiveOrders) {
          return const Center(child: Text('คุณยังไม่มีการส่งสินค้า'));
        }

        return Column(
          children: [
            // แสดงปุ่มถ้ามีออเดอร์ที่ไม่ใช่สถานะ 4
            if (hasActiveOrders)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    box.write('receiverId', true);
                    Get.to(() => const MapscreenPage(),
                        arguments: {
                          'receiverId': userId,
                        },
                        transition: Transition.rightToLeft,
                        duration: const Duration(milliseconds: 300));
                    log("ปุ่มถูกกด");
                  },
                  child: const Text(
                    'ดูตำแหน่ง Rider ทั้งหมดของสินค้าที่คุณรับ',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  final senderId = order['senderId'];
                  final orderId = order.id;
                  final status = order['status']; // ดึงสถานะ

                  // ถ้าสถานะเป็น 4 จะไม่แสดงออเดอร์นี้
                  if (status == '4') {
                    return const SizedBox.shrink(); // ซ่อน Widget
                  }

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(senderId)
                        .get(),
                    builder: (context, senderSnapshot) {
                      if (!senderSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final senderData = senderSnapshot.data!;
                      final senderName = senderData['fullname'] ?? 'ไม่ระบุ';

                      return _orderRider(
                        senderName,
                        userService.name,
                        orderId,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _orderRider(String senderName, String receiverName, String orderId) {
    return Column(
      children: [
        // เพิ่ม SizedBox ด้านบนเพื่อให้ขยับขึ้น
        // เปลี่ยนจาก 10 เป็น 0 หรือค่าที่ต้องการ

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
                          arguments: {
                            'orderId': orderId,
                          },
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
        const SizedBox(height: 10), // ระยะห่างด้านล่าง
      ],
    );
  }
}
