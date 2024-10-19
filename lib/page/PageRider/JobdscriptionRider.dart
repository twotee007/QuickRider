import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageRider/MapOrderRider.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';

class JobdscriptionriderPage extends StatefulWidget {
  const JobdscriptionriderPage({super.key});

  @override
  State<JobdscriptionriderPage> createState() => _JobdscriptionriderPageState();
}

class _JobdscriptionriderPageState extends State<JobdscriptionriderPage> {
  final riderService = Get.find<RiderService>();
  late String orderId;
  late String senderId;
  late String receiverId;
  late Future<void> loadData;
  String photo = '';
  String productName = '';
  String description = '';
  int quantity = 0;
  String sendername = '';
  String senderaddress = '';
  String senderphone = '';
  String receivername = '';
  String receiveraddress = '';
  String receiverphone = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderId = context.read<AppData>().order.orderId;
    senderId = context.read<AppData>().order.senderId;
    receiverId = context.read<AppData>().order.receiverId;
    loadData = loadDataAstnc();
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
              riderService.name,
              riderService.url,
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
                      child: SingleChildScrollView(
                        child: FutureBuilder(
                            future: loadData,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return const Center(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 100),
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                );
                              }
                              return Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back,
                                              color: Colors.black),
                                          onPressed: () {
                                            Get.to(() => const HomeRiderPage(),
                                                transition: Transition
                                                    .rightToLeftWithFade,
                                                duration: const Duration(
                                                    milliseconds: 300));
                                          },
                                        ),
                                        const Expanded(
                                          child: Center(
                                            child: Text(
                                              'รายละเอียดออเดอร์',
                                              style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Image.network(
                                          photo.isNotEmpty
                                              ? photo
                                              : 'https://media.istockphoto.com/id/1162198273/th/%E0%B9%80%E0%B8%A7%E0%B8%84%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C/%E0%B9%80%E0%B8%84%E0%B8%A3%E0%B8%B7%E0%B9%88%E0%B8%AD%E0%B8%87%E0%B8%AB%E0%B8%A1%E0%B8%B2%E0%B8%A2%E0%B8%84%E0%B9%8D%E0%B8%B2%E0%B8%96%E0%B8%B2%E0%B8%A1%E0%B9%84%E0%B8%AD%E0%B8%84%E0%B8%AD%E0%B8%99%E0%B8%81%E0%B8%B2%E0%B8%A3%E0%B8%AD%E0%B8%AD%E0%B8%81%E0%B9%81%E0%B8%9A%E0%B8%9A%E0%B8%A0%E0%B8%B2%E0%B8%9E%E0%B8%9B%E0%B8%A3%E0%B8%B0%E0%B8%81%E0%B8%AD%E0%B8%9A%E0%B9%80%E0%B8%A7%E0%B8%81%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B9%8C%E0%B9%81%E0%B8%9A%E0%B8%99.jpg?s=612x612&w=0&k=20&c=nFidzHGc1i9qQbS71G-ehfyiozViNc75Im3H-L_2QKY=',
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ชื่อสินค้า : ${productName.isNotEmpty ? productName : 'ไม่ทราบชื่อผลิตภัณฑ์'}',
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'จำนวน : $quantity x',
                                                style: const TextStyle(
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Text(
                                      'รายละเอียดสินค้า : ${description.isNotEmpty ? description : 'ไม่ทราบรายละเอียดสินค้า'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Align(
                                      alignment:
                                          Alignment.centerLeft, // จัดแนวชิดซ้าย
                                      child: Text(
                                        'รับออเดอร์จาก:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Align(
                                      alignment:
                                          Alignment.centerLeft, // จัดแนวชิดซ้าย
                                      child: Text(
                                        'คุณ: ${sendername.isNotEmpty ? sendername : 'ไม่ทราบชื่อผู้ส่ง'}\n'
                                        'ที่อยู่: ${senderaddress.isNotEmpty ? senderaddress : 'ไม่ทราบที่อยู่ผู้ส่ง'}\n'
                                        'เบอร์โทร: ${senderphone.isNotEmpty ? senderphone : 'ไม่ทราบเบอร์โทรผู้ส่ง'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Align(
                                      alignment:
                                          Alignment.centerLeft, // จัดแนวชิดซ้าย
                                      child: Text(
                                        'จัดส่งคุณ:',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Align(
                                      alignment:
                                          Alignment.centerLeft, // จัดแนวชิดซ้าย
                                      child: Text(
                                        'คุณ: ${receivername.isNotEmpty ? receivername : 'ไม่ทราบชื่อผู้รับ'}\n'
                                        'ที่อยู่: ${receiveraddress.isNotEmpty ? receiveraddress : 'ไม่ทราบที่อยู่ผู้รับ'}\n'
                                        'เบอร์โทร: ${receiverphone.isNotEmpty ? receiverphone : 'ไม่ทราบเบอร์โทรผู้รับ'}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => const MapOrderPage(),
                                          transition:
                                              Transition.rightToLeftWithFade,
                                          duration: const Duration(
                                              milliseconds: 300));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 18, 172, 82),
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
                                  const SizedBox(height: 20),
                                ],
                              );
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadDataAstnc() async {
    try {
      // เข้าถึง collection ที่มี orderItems
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('orderItems')
          .where('orderId', isEqualTo: orderId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Map<String, dynamic>? orderItemData = doc.data();
          description = orderItemData['description'] ?? 'ไม่มีรายละเอียด';
          quantity = orderItemData['quantity'] ?? 0;
          productName = orderItemData['name'] ?? 'ไม่ทราบชื่อผลิตภัณฑ์';
          photo = orderItemData['Photos'] ?? 'ไม่มีรูปภาพ';

          // ค้นหาข้อมูลผู้ส่ง
          DocumentSnapshot<Map<String, dynamic>> senderDoc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(senderId)
                  .get();

          // ค้นหาข้อมูลผู้รับ
          DocumentSnapshot<Map<String, dynamic>> receiverDoc =
              await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(receiverId)
                  .get();

          sendername = senderDoc.data()?['fullname'] ?? 'ไม่ทราบชื่อผู้ส่ง';
          senderaddress =
              senderDoc.data()?['address'] ?? 'ไม่ทราบที่อยู่ผู้ส่ง';
          senderphone = senderDoc.data()?['phone'] ?? 'ไม่ทราบเบอร์โทรผู้ส่ง';
          receivername = receiverDoc.data()?['fullname'] ?? 'ไม่ทราบชื่อผู้รับ';
          receiveraddress =
              receiverDoc.data()?['address'] ?? 'ไม่ทราบที่อยู่ผู้รับ';
          receiverphone =
              receiverDoc.data()?['phone'] ?? 'ไม่ทราบเบอร์โทรผู้รับ';

          // Update the UI
          setState(() {});
        }
      } else {
        log('ไม่มีรายการใดที่ตรงกับ orderId: ${orderId}');
      }
    } catch (e) {
      log('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    }
  }
}
