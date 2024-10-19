import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
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

  // จุดเริ่มต้นและจุดสิ้นสุด
  LatLng start = const LatLng(13.7563, 100.5018); // Bangkok
  LatLng end = const LatLng(13.7563, 100.5018); // Another point in Bangkok

  @override
  void initState() {
    super.initState();

    _getRoute();
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
        print("ไม่มีเส้นทางที่สามารถใช้งานได้");
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
                log('รับของ');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 18, 172, 82),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'รับของ',
                style: TextStyle(
                  fontSize: 20, // ขนาดฟอนต์
                  color: Colors.white, // สีข้อความ
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void comfrim() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          'ยืนยันการรับสินค้า',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF412160),
          ),
        ),
        content: const Text(
          'คุณแน่ใจว่าคุณรับสินค้าแล้ว?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog without doing anything
            },
            child: const Text(
              'ยกเลิก',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF412160),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
              Get.to(
                () => const PhotostatusriderPage(),
                transition: Transition.rightToLeftWithFade,
                duration: const Duration(milliseconds: 300),
              );
            },
            child: const Text(
              'รับสินค้า',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 18, 172, 82),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
    );
  }
}
