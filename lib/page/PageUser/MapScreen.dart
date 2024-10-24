import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/PageUser/DeliveryStatus.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';

class MapscreenPage extends StatefulWidget {
  const MapscreenPage({super.key});

  @override
  State<MapscreenPage> createState() => _MapscreenPageState();
}

class _MapscreenPageState extends State<MapscreenPage> {
  List<Map<String, dynamic>> ridersLocations = [];
  List<Marker> ridersMarkers = [];
  Map<String, Color> riderColors = {};
  final box = GetStorage();
  StreamSubscription<QuerySnapshot>? ordersSubscription;
  StreamSubscription<DocumentSnapshot>? riderSubscription;
  Random random = Random();
  String textfirebase = '';
  bool isLoading = true;
  LatLng centerPosition = const LatLng(17.303615, 101.775303);
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    bool senderId = box.read('senderId') == true; // ถ้าไม่ใช่ true จะเป็น false
    bool receiverId =
        box.read('receiverId') == true; // ถ้าไม่ใช่ true จะเป็น false

    if (senderId) {
      textfirebase = 'senderId';
    } else if (receiverId) {
      textfirebase = 'receiverId';
    }
    _listenToRidersLocation();
  }

  Color getRandomColor() {
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  void _listenToRidersLocation() async {
    if (context.read<AppData>().ordersSubscription != null &&
        context.read<AppData>().riderSubscription != null) {
      context.read<AppData>().ordersSubscription!.cancel();
      context.read<AppData>().ordersSubscription = null;
      context.read<AppData>().riderSubscription!.cancel();
      context.read<AppData>().riderSubscription = null;
    }
    try {
      String userid = box.read('Userid');

      // อ่านตำแหน่งจาก Firebase
      DocumentSnapshot riderDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userid)
          .get();

      if (riderDoc.exists) {
        var location = riderDoc.get('gpsLocation');
        if (location != null) {
          setState(() {
            centerPosition = LatLng(
              location['latitude'] ?? 17.303615,
              location['longitude'] ?? 101.775303,
            );
          });
        }
      }

      print('Start Real Time');
      context.read<AppData>().ordersSubscription = FirebaseFirestore.instance
          .collection('orders')
          .where(textfirebase, isEqualTo: userid)
          .snapshots()
          .listen((ordersSnapshot) {
        print('Orders Snapshot: ${ordersSnapshot.docs.length}');
        Map<String, Map<String, dynamic>> updatedRidersLocations = {};

        for (var orderDoc in ordersSnapshot.docs) {
          var data = orderDoc.data() as Map<String, dynamic>;

          // กรองข้อมูล order ที่ status ไม่ใช่ 4
          if (data['status'] != '4') {
            if (data['riderId'] != null &&
                data['riderId'].toString().isNotEmpty) {
              context.read<AppData>().riderSubscription = FirebaseFirestore
                  .instance
                  .collection('Users')
                  .doc(data['riderId'])
                  .snapshots()
                  .listen((riderDoc) {
                if (riderDoc.exists) {
                  var riderData = riderDoc.data() as Map<String, dynamic>;
                  var gpsLocation =
                      riderData['gpsLocation'] as Map<String, dynamic>;

                  // เช็คว่าสีของผู้ขับขี่เคยถูกตั้งไว้แล้วหรือไม่
                  if (!riderColors.containsKey(data['riderId'])) {
                    riderColors[data['riderId']] =
                        getRandomColor(); // สุ่มสีใหม่
                  }
                  var cheack = data['status'];
                  var statusstring;
                  if (cheack == '1') {
                    statusstring = 'รอไรเดอร์รับงาน';
                  } else if (cheack == '2') {
                    statusstring = 'กำลังไปรับสินค้า';
                  } else if (cheack == '3') {
                    statusstring = 'กำลังจัดส่งสินค้า';
                  } else if (cheack == '4') {
                    statusstring = 'จัดส่งสำเร็จ';
                  }
                  Color riderColor =
                      riderColors[data['riderId']] ?? Colors.grey;

                  updatedRidersLocations[orderDoc.id] = {
                    'fullname': riderData['fullname'],
                    'status': statusstring,
                    'img': riderData['img'],
                    'phone': riderData['phone'],
                    'registration': riderData['registration'],
                    'latitude': gpsLocation['latitude'],
                    'longitude': gpsLocation['longitude'],
                    'color': riderColor,
                  };

                  setState(() {
                    ridersLocations = updatedRidersLocations.entries
                        .map((entry) => {
                              'orderId': entry.key,
                              'registration': entry.value['registration'],
                              'img': entry.value['img'],
                              'phone': entry.value['phone'],
                              'status': entry.value['status'],
                              'fullname': entry.value['fullname'],
                              'latitude': entry.value['latitude'],
                              'longitude': entry.value['longitude'],
                              'color': entry.value['color'],
                            })
                        .toList();

                    // สร้างมาร์กเกอร์ของผู้ขับขี่
                    ridersMarkers = ridersLocations.map((rider) {
                      return Marker(
                        point: LatLng(rider['latitude'], rider['longitude']),
                        child: Container(
                          child: Icon(
                            Icons.motorcycle,
                            color: rider['color'],
                            size: 40,
                          ),
                        ),
                      );
                    }).toList();

                    // เพิ่มมาร์กเกอร์สำหรับ centerPosition
                    ridersMarkers.add(
                      Marker(
                        point: centerPosition,
                        child: Container(
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ),
                    );

                    // ย้ายไปยังตำแหน่งของผู้ขับขี่ล่าสุด
                    if (_isMapReady && ridersLocations.isNotEmpty) {
                      _mapController.move(
                          LatLng(ridersLocations[0]['latitude'],
                              ridersLocations[0]['longitude']),
                          15.0);
                    }
                  });
                }
              });
            }
          } else {
            ridersMarkers.add(
              Marker(
                point: centerPosition,
                child: Container(
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ),
            );
          }
        }
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // เปลี่ยนเส้นทางไปยัง HomeUserpage แทนที่จะ pop ออก
        box.remove('receiverId');
        box.remove('senderId');
        if (context.read<AppData>().ordersSubscription != null &&
            context.read<AppData>().riderSubscription != null) {
          context.read<AppData>().ordersSubscription!.cancel();
          context.read<AppData>().ordersSubscription = null;
          context.read<AppData>().riderSubscription!.cancel();
          context.read<AppData>().riderSubscription = null;
        }
        print('StopRealTime');
        Get.to(() => const HomeUserpage(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300));
        return false; // ไม่ให้ pop หน้าออก
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riders Map'),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: centerPosition,
                      initialZoom: 15.0,
                      onMapReady: () {
                        setState(() {
                          _isMapReady = true;
                        });
                        // Move to center position after map is ready
                        _mapController.move(centerPosition, 15.0);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: ridersMarkers,
                      ),
                    ],
                  ),
                  DraggableScrollableSheet(
                    initialChildSize: 0.3,
                    minChildSize: 0.1,
                    maxChildSize: 0.5,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  'Riders List',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (ridersLocations.isEmpty)
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(
                                          0.1), // สีพื้นหลังที่นุ่มนวล
                                      borderRadius:
                                          BorderRadius.circular(12), // มุมมน
                                      border: Border.all(
                                          color: Colors.blue,
                                          width: 1.5), // เส้นขอบ
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons
                                              .info_outline, // เปลี่ยนเป็นไอคอนข้อมูล
                                          color: Colors.blue,
                                          size: 30, // ขนาดไอคอน
                                        ),
                                        const SizedBox(height: 8), // เว้นระยะ
                                        Text(
                                          'ตอนนี้ออเดอร์ยังไม่มีไรเดอร์รับงาน',
                                          style: const TextStyle(
                                            fontSize: 18, // ขนาดตัวอักษร
                                            fontWeight:
                                                FontWeight.bold, // หนักตัวอักษร
                                            color: Colors.blue, // สีตัวอักษร
                                          ),
                                          textAlign: TextAlign
                                              .center, // จัดข้อความกลาง
                                        ),
                                        const SizedBox(
                                            height: 12), // เว้นระยะเพิ่มเติม
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...ridersLocations.map((rider) {
                                  return GestureDetector(
                                    onTap: () {
                                      if (context
                                                  .read<AppData>()
                                                  .ordersSubscription !=
                                              null &&
                                          context
                                                  .read<AppData>()
                                                  .riderSubscription !=
                                              null) {
                                        context
                                            .read<AppData>()
                                            .ordersSubscription!
                                            .cancel();
                                        context
                                            .read<AppData>()
                                            .ordersSubscription = null;
                                        context
                                            .read<AppData>()
                                            .riderSubscription!
                                            .cancel();
                                        context
                                            .read<AppData>()
                                            .riderSubscription = null;
                                      }
                                      print('StopRealTime');
                                      print(
                                          'Card clicked for order ID: ${rider['orderId']}');
                                      Get.to(() => DeliveryStatusScreen(),
                                          arguments: {
                                            'orderId': rider['orderId'],
                                          },
                                          transition: Transition.rightToLeft,
                                          duration: const Duration(
                                              milliseconds: 300));
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 16),
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: rider['color'],
                                          child: ClipOval(
                                            child: Image.network(
                                              rider[
                                                  'img'], // ใช้รูปภาพของรถแทนไอคอน
                                              fit: BoxFit
                                                  .cover, // ปรับให้เต็มพื้นที่
                                              height: 50, // ปรับขนาดให้เหมาะสม
                                              width: 50, // ปรับขนาดให้เหมาะสม
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          rider['fullname'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                                'เบอร์โทร : ${rider['phone']}'),
                                            const SizedBox(height: 2),
                                            Text(
                                                'ทะเบียนรถ : ${rider['registration']}'),
                                            const SizedBox(height: 2),
                                            Text('Status : ${rider['status']}'),
                                          ],
                                        ),
                                        trailing: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: rider['color'],
                                          child: const Icon(
                                            Icons.motorcycle,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
