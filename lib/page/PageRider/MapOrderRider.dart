import 'dart:async';
import 'dart:convert';
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
import 'package:quickrider/page/PageRider/PhotostatusRider.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';
import 'package:http/http.dart' as http;

class MapOrderPage extends StatefulWidget {
  const MapOrderPage({super.key});

  @override
  State<MapOrderPage> createState() => _MapOrderPageState();
}

class _MapOrderPageState extends State<MapOrderPage> {
  final riderService = Get.find<RiderService>();
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];
  String orderid = '';
  String status = ''; // สถานะสินค้า
  // จุดเริ่มต้นและจุดสิ้นสุด
  double currentZoom = 16.0;
  LatLng start = LatLng(37.29228362890773, -121.98843719179415); // Bangkok
  LatLng end = LatLng(13.7563, 100.5018); // เปลี่ยนจาก const เป็น LatLng ปกติ
  StreamSubscription<Position>? _positionStreamSubscription;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    orderid = context.read<AppData>().order.orderId;
    if (orderid.isEmpty) {
      orderid = box.read('orderId');
    }
    log(orderid);
    _trackLocation();
    _getOrderStatus();
  }

  Future<void> _trackLocation() async {
    String riderid = box.read('Riderid');
    // รับตำแหน่งปัจจุบันก่อนที่จะเริ่มการติดตาม
    if (context.read<AppData>().listener != null) {
      context.read<AppData>().listener!.cancel();
      context.read<AppData>().listener = null;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // อัปเดตตำแหน่งเริ่มต้นด้วยตำแหน่งปัจจุบัน
    start = LatLng(position.latitude, position.longitude);

    // แสดงตำแหน่งเริ่มต้นบนแผนที่
    _mapController.move(start, currentZoom);
    // เริ่มการติดตามตำแหน่ง
    context.read<AppData>().listener = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // อัปเดตทุกๆ 1 เมตร
      ),
    ).listen((Position position) {
      setState(() {
        start = LatLng(position.latitude, position.longitude);
      });

      // ย้ายแผนที่ไปยังตำแหน่งใหม่
      updateRiderLocation(riderid, start);
      // ดึงเส้นทางใหม่เมื่อเปลี่ยนตำแหน่ง
      _getRoute();

      log("startRealtime Current position: $start");
    });
  }

  Future<void> updateRiderLocation(String riderId, LatLng location) async {
    final riderRef =
        FirebaseFirestore.instance.collection('Users').doc(riderId);

    await riderRef.update({
      'gpsLocation': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    }).catchError((error) {
      log("Error updating rider location: $error");
    });
  }

  Future<void> _getOrderStatus() async {
    String riderid = box.read('Riderid');
    try {
      if (riderid != null) {
        DocumentSnapshot<Map<String, dynamic>> riderDocumentSnapshot =
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(riderid)
                .get();

        if (riderDocumentSnapshot.exists) {
          final gpsLocation = riderDocumentSnapshot.data()?['gpsLocation'];
          if (gpsLocation != null) {
            double riderLat = gpsLocation['latitude'];
            double riderLng = gpsLocation['longitude'];
            start = LatLng(riderLat, riderLng); // กำหนดค่า location ของ rider
            _mapController.move(start, currentZoom);
            log('Rider Location: $start');
          }
        } else {
          log("No such Rider document!");
        }
      }
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderid)
              .get();

      if (documentSnapshot.exists) {
        setState(() {
          status =
              documentSnapshot.data()?['status']; // ดึง status จาก Firestore
          log('Status: $status');

          // ตรวจสอบค่า status ว่าเป็น 2 หรือ 3
          if (status == '2') {
            // ถ้า status เป็น 2 ให้ดึง pickupLocation และใช้กับ LatLng
            final pickupLocation = documentSnapshot.data()?['pickupLocation'];
            if (pickupLocation != null) {
              double pickupLat = pickupLocation['latitude'];
              double pickupLng = pickupLocation['longitude'];
              end = LatLng(pickupLat, pickupLng); // กำหนดค่า end ใหม่
              log('Updated End Location (Pickup): $end');
            }
          } else if (status == '3') {
            // ถ้า status เป็น 3 ให้ดึง deliveryLocation และใช้กับ LatLng
            final deliveryLocation =
                documentSnapshot.data()?['deliveryLocation'];
            if (deliveryLocation != null) {
              double deliveryLat = deliveryLocation['latitude'];
              double deliveryLng = deliveryLocation['longitude'];
              end = LatLng(deliveryLat, deliveryLng); // กำหนดค่า end ใหม่
              log('Updated End Location (Delivery): $end');
            }
          }
        });

        // ดึง gpsLocation จาก collection Users ตาม Riderid
      } else {
        log("No such document!");
      }
    } catch (e) {
      log("Error fetching document: $e");
    }
  }

  Future<void> _getRoute() async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        final List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];
        final List<LatLng> points =
            coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

        setState(() {
          routePoints = points;
        });
      } else {
        print("No available route");
      }
    } else {
      print("Error in API response");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: cycletopri(
              riderService.name,
              riderService.url,
            ),
          ),
          const SizedBox(height: 20), // เว้นระยะห่าง 20 หน่วยจากด้านบน
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: start,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      if (routePoints.isNotEmpty)
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: const Color.fromARGB(255, 132, 226, 239),
                        ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: start,
                        width: 80.0,
                        height: 80.0,
                        child: const Icon(Icons.two_wheeler,
                            color: Color.fromARGB(255, 121, 44, 222),
                            size: 40), // ไอคอนรถมอเตอร์ไซค์จาก Material Icons
                      ),
                      Marker(
                        point: end,
                        width: 80.0,
                        height: 80.0,
                        child:
                            const Icon(Icons.location_pin, color: Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // เพิ่มปุ่ม "รับของ" ที่ด้านล่าง
          Padding(
            padding: const EdgeInsets.all(16.0), // เพิ่ม Padding รอบปุ่ม
            child: ElevatedButton(
              onPressed: () {
                comfrim();
                log(status == 2 ? 'รับของ' : 'จัดส่ง');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 172, 82),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                status == '2'
                    ? 'ดูรายละเอียดรับของ'
                    : 'ดูรายละเอียดจัดส่ง', // เปลี่ยนข้อความตาม status
                style: const TextStyle(
                  fontSize: 20, // ขนาดฟอนต์
                  color: Colors.white, // สีข้อความ
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void comfrim() {
    if (context.read<AppData>().listener != null) {
      log('Stop Real Time Location');
      context.read<AppData>().listener!.cancel();
      context.read<AppData>().listener = null;
    }
    Get.to(
      () => const PhotostatusriderPage(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 300),
    );
  }
}
