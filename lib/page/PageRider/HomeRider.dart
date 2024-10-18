import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/PageRider/JobdscriptionRider.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';
import 'package:quickrider/page/ChangePage/NavigationBarRider.dart';

class HomeRiderPage extends StatefulWidget {
  const HomeRiderPage({super.key});

  @override
  State<HomeRiderPage> createState() => _HomeRiderPageState();
}

class _HomeRiderPageState extends State<HomeRiderPage>
    with TickerProviderStateMixin {
  late Map<String, dynamic>? rider;
  int _selectedIndex = 0;
  List<Map<String, dynamic>> ordersList = [];
  bool isLoading = true; // ตัวแปรสำหรับสถานะการโหลด
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final riderService = Get.find<RiderService>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final riderService = Get.put(RiderService());
    riderService.loadUserData();
    startRealtimeGetOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: cycletopri(
              riderService.name, // ใช้ข้อมูลชื่อจาก UserService
              riderService.url, // ใช้ข้อมูล URL จาก UserService
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 140),
              child: Container(
                width: MediaQuery.of(context).size.width * 1,
                height:
                    MediaQuery.of(context).size.height, // ใช้ความสูงของหน้าจอ
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: SingleChildScrollView(
                  // ห่อ Column ด้วย SingleChildScrollView
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

                      _buildSentItems(), // เรียกฟังก์ชันแสดงออเดอร์
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBarRider(
        currentIndex: 0,
        onTap: (index) {
          setState(() {
            if (context.read<AppData>().listener != null) {
              context.read<AppData>().listener!.cancel();
              context.read<AppData>().listener = null;
              log('Stop real Time');
            }
          });
        },
      ),
    );
  }

  Widget _buildSentItems() {
    if (isLoading) {
      // แสดง CircularProgressIndicator ถ้ากำลังโหลดข้อมูล
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 10),
          ...ordersList.map((order) {
            String senderName = order['senderName'] ?? 'Unknown Sender';
            String receiverName = order['receiverName'] ?? 'Unknown Receiver';
            String orderId = order['orderId'] ?? 'Unknown orderId';
            String senderId = order['senderId'] ?? 'Unknown senderId';
            String receiverId = order['receiverId'] ?? 'Unknown receiverId';
            return _orderRider(
                senderName, receiverName, orderId, senderId, receiverId);
          }).toList(),
        ],
      ),
    );
  }

  Widget _orderRider(String namesender, String namereceiver, String orderId,
      String senderId, String receiverId) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (context.read<AppData>().listener != null) {
                  context.read<AppData>().listener!.cancel();
                  context.read<AppData>().listener = null;
                  log('Stop real Time');
                }
                Get.to(() => const JobdscriptionriderPage(),
                    arguments: {
                      'orderId': orderId,
                      'senderId': senderId,
                      'receiverId': receiverId,
                    },
                    transition: Transition.rightToLeftWithFade,
                    duration: const Duration(milliseconds: 300));
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

  void startRealtimeGetOrders() {
    final collectionRef = FirebaseFirestore.instance.collection('orders');

    if (context.read<AppData>().listener != null) {
      context.read<AppData>().listener!.cancel();
      context.read<AppData>().listener = null;
    }

    context.read<AppData>().listener = collectionRef
        .where('status', isEqualTo: '1')
        .snapshots()
        .listen((querySnapshot) async {
      log("startRealtimeGetOrders");
      log("Total documents: ${querySnapshot.docs.length}");

      ordersList.clear(); // ล้างรายการก่อน

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> jsonData = doc.data() as Map<String, dynamic>;

          // ดึงข้อมูลผู้ใช้จาก Firestore
          String senderId = jsonData["senderId"];
          String receiverId = jsonData["receiverId"];
          DocumentSnapshot<Map<String, dynamic>> senderDoc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(senderId)
                  .get();
          DocumentSnapshot<Map<String, dynamic>> receiverDoc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(receiverId)
                  .get();

          String senderName = senderDoc.data()?['fullname'] ?? 'Unknown Sender';
          String receiverName =
              receiverDoc.data()?['fullname'] ?? 'Unknown Receiver';

          // สร้าง Map สำหรับ orderData
          Map<String, dynamic> orderData = {
            "orderId": doc.id,
            "senderId": senderId,
            "receiverId": receiverId,
            "senderName": senderName,
            "receiverName": receiverName,
          };

          ordersList.add(orderData);
          log(orderData['orderId']);
        }

        // เปลี่ยนสถานะการโหลดให้เป็น false เมื่อโหลดเสร็จ
        setState(() {
          isLoading = false;
        });
      } else {
        log("No orders with status 1 found");
        setState(() {
          isLoading = false; // เปลี่ยนสถานะการโหลดให้เป็น false
        });
      }
    }, onError: (error) => log("Listen failed: $error"));
  }
}
