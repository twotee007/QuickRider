import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
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
  MapController mapController1 = MapController();
  MapController mapController2 = MapController();
  late String orderId;
  late String senderId;
  late String receiverId;
  late Future<void> loadData;
  final box = GetStorage();
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
  double? pickupLatitude;
  double? pickupLongitude;
  double? deliveryLatitude;
  double? deliveryLongitude;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orderId = context.read<AppData>().order.orderId;
    senderId = context.read<AppData>().order.senderId;
    receiverId = context.read<AppData>().order.receiverId;
    pickupLatitude = context.read<AppData>().pickup.latitude;
    pickupLongitude = context.read<AppData>().pickup.longitude;
    deliveryLatitude = context.read<AppData>().delivery.latitude;
    deliveryLongitude = context.read<AppData>().delivery.longitude;
    log(pickupLatitude.toString());
    log(pickupLongitude.toString());
    log(deliveryLatitude.toString());
    log(deliveryLongitude.toString());

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
                                  // FlutterMap
                                  Container(
                                    height: 200,
                                    padding: const EdgeInsets.all(8.0),
                                    child: FlutterMap(
                                      mapController: mapController1,
                                      options: MapOptions(
                                        initialCenter: LatLng(
                                            pickupLatitude!, pickupLongitude!),
                                        initialZoom: 13.0,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: ['a', 'b', 'c'],
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(pickupLatitude!,
                                                  pickupLongitude!),
                                              width: 40,
                                              height: 40,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.blue,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                  Container(
                                    height: 200,
                                    padding: const EdgeInsets.all(8.0),
                                    child: FlutterMap(
                                      mapController: mapController2,
                                      options: MapOptions(
                                        initialCenter: LatLng(deliveryLatitude!,
                                            deliveryLongitude!),
                                        initialZoom: 13.0,
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          subdomains: ['a', 'b', 'c'],
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(deliveryLatitude!,
                                                  deliveryLongitude!),
                                              width: 40,
                                              height: 40,
                                              child: const Icon(
                                                Icons.location_on,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      submit();
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

  void submit() async {
    String riderId = box.read('Riderid');
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot riderSnapshot =
          await firestore.collection('Users').doc(riderId).get();
      Map<String, dynamic> riderData =
          riderSnapshot.data() as Map<String, dynamic>;

      if (riderData['currentJob'] == '1') {
        // แสดง snackbar หากไรเดอร์มีงานอยู่แล้ว
        Get.snackbar('Error', 'คุณรับงานไปแล้ว',
            backgroundColor: Colors.red, colorText: Colors.white);
        return; // หยุดการทำงานถ้าไรเดอร์มีงานอยู่แล้ว
      }
      // เริ่ม Firebase Transaction
      await firestore.runTransaction((transaction) async {
        DocumentReference orderRef =
            firestore.collection('orders').doc(orderId);

        // ดึงข้อมูลออเดอร์แบบ transaction
        DocumentSnapshot snapshot = await transaction.get(orderRef);

        if (!snapshot.exists) {
          throw Exception("ไม่พบออเดอร์นี้");
        }

        Map<String, dynamic> orderData =
            snapshot.data() as Map<String, dynamic>;
        // ตรวจสอบว่าออเดอร์นี้ยังไม่มีใครรับ
        String cheack = orderData['riderId'];
        if (cheack.isEmpty) {
          // อัปเดตสถานะและ riderId ใน transaction
          transaction.update(orderRef, {
            'status': '2', // เปลี่ยนสถานะเป็นรับงานแล้ว
            'riderId': riderId, // กำหนด riderId ของไรเดอร์ที่รับงาน
          });
        } else {
          throw Exception("งานนี้มีไรเดอร์รับไปแล้ว");
        }
      });

      // แสดง Dialog ขณะโหลด
      showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(), // วงกลมหมุนขณะโหลด
          );
        },
      );

      // ตรวจสอบสิทธิ์ของผู้ใช้
      _checkPermissions();

      // อัปเดตข้อมูลของไรเดอร์ว่ากำลังทำงาน
      await firestore
          .collection('Users')
          .doc(riderId)
          .update({'currentJob': '1'});

      // ปิด dialog หลังจากทำเสร็จ
      Get.back();

      // นำผู้ใช้ไปยังหน้า MapOrderPage
      Get.to(() => const MapOrderPage(),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 300));
    } catch (e) {
      log('ไม่สามารถรับงานได้: $e');
      // สามารถแจ้งเตือนให้ผู้ใช้ทราบเมื่อเกิดข้อผิดพลาด
      Get.snackbar('Error', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle permission denied scenario
        log("Location permissions are denied");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when the user denied permissions forever
      log("Location permissions are permanently denied");
      return;
    }
  }
}
