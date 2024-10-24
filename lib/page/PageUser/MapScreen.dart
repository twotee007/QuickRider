import 'dart:async';
import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';

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
  late String senderId;
  late String receiverId;
  String textfirebase = '';
  bool isLoading = true;
  LatLng centerPosition = LatLng(17.303615, 101.775303);
  final MapController _mapController = MapController();
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    senderId = args['senderId'] ?? '0';
    receiverId = args['receiverId'] ?? '0';
    _listenToRidersLocation();
  }

  @override
  void dispose() {
    ordersSubscription?.cancel();
    riderSubscription?.cancel();
    print('StopRealTime');
    super.dispose();
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
    try {
      String userid = box.read('Userid');
      if (senderId != '0') {
        textfirebase = 'senderId';
      } else if (receiverId != '0') {
        textfirebase = 'receiverId';
      }

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
            isLoading = false;
          });
        }
      }

      ordersSubscription = FirebaseFirestore.instance
          .collection('orders')
          .where(textfirebase, isEqualTo: userid)
          .where('status', isNotEqualTo: '4') // Exclude orders with status == 4
          .snapshots()
          .listen((ordersSnapshot) {
        print('Orders Snapshot: ${ordersSnapshot.docs.length}');
        Map<String, Map<String, dynamic>> updatedRidersLocations = {};

        for (var orderDoc in ordersSnapshot.docs) {
          var data = orderDoc.data() as Map<String, dynamic>;
          if (data['riderId'] != null &&
              data['riderId'].toString().isNotEmpty) {
            riderSubscription = FirebaseFirestore.instance
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
                  riderColors[data['riderId']] = getRandomColor(); // สุ่มสีใหม่
                }

                Color riderColor = riderColors[data['riderId']] ??
                    Colors.grey; // ใช้สีเริ่มต้นถ้าไม่พบ

                updatedRidersLocations[orderDoc.id] = {
                  'fullname': riderData['fullname'],
                  'latitude': gpsLocation['latitude'],
                  'longitude': gpsLocation['longitude'],
                  'color': riderColor,
                };

                setState(() {
                  ridersLocations = updatedRidersLocations.entries
                      .map((entry) => {
                            'orderId': entry.key,
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
                          color: rider['color'], // ใช้สีที่เก็บไว้
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
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red, // เปลี่ยนสีได้ตามต้องการ
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
        }
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...ridersLocations.map((rider) {
                              return ListTile(
                                title: Text(rider['fullname']),
                                subtitle: Text('Order ID: ${rider['orderId']}'),
                                trailing: Icon(
                                  Icons.motorcycle,
                                  color: rider['color'],
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
    );
  }
}
