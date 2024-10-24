import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/PageUser/DeliveryStatus.dart';

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
  final box = GetStorage();
  final userService = Get.find<UserService>();
  late String orderId;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
                              Tab(text: 'ประวัติสินค้าที่คุณส่ง'),
                              Tab(text: 'ประวัติสินค้าที่คุณได้รับ'),
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

        final orders = snapshot.data!.docs.where((order) {
          // แสดงเฉพาะรายการที่มีสถานะเป็น 4
          return order['status'] == '4';
        }).toList();

        if (orders.isEmpty) {
          return const Center(
              child: Text('คุณยังไม่มีการส่งสินค้าในสถานะที่แสดง'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final receiverId = order['receiverId'];
            final orderId = order.id;
            final status = order['status'];

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
                final receiverName = receiverData['fullname'] ?? 'ไม่ระบุ';

                return _orderRider(
                  userService.name,
                  receiverName,
                  orderId,
                  status,
                );
              },
            );
          },
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

        final orders = snapshot.data!.docs.where((order) {
          // แสดงเฉพาะรายการที่มีสถานะเป็น 4
          return order['status'] == '4';
        }).toList();

        if (orders.isEmpty) {
          return const Center(
              child: Text('คุณยังไม่มีการรับสินค้าในสถานะที่แสดง'));
        }

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final senderId = order['senderId'];
            final orderId = order.id;
            final status = order['status'];

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
                  status,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _orderRider(
      String senderName, String receiverName, String orderId, String status) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 340,
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
                            'status': status,
                          },
                          transition: Transition.cupertino,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'รายละเอียด', // แสดงข้อความเป็น 'รายละเอียด' เสมอ
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
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
