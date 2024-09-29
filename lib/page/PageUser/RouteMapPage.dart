import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteMapPage extends StatefulWidget {
  const RouteMapPage({Key? key}) : super(key: key);

  @override
  _RouteMapPageState createState() => _RouteMapPageState();
}

class _RouteMapPageState extends State<RouteMapPage> {
  final MapController _mapController = MapController();
  List<LatLng> routePoints = [];

  // จุดเริ่มต้นและจุดสิ้นสุด
  LatLng start = const LatLng(13.7563, 100.5018); // Bangkok
  LatLng end = const LatLng(13.736717, 100.523186); // Another point in Bangkok

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  Future<void> _getRoute() async {
    // เรียก OSRM API เพื่อคำนวณเส้นทาง
    final url =
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    // ดึงข้อมูลเส้นทางจาก API
    final List<dynamic> coordinates =
        data['routes'][0]['geometry']['coordinates'];

    // แปลงข้อมูลให้เป็น LatLng
    final List<LatLng> points =
        coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

    setState(() {
      routePoints = points;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OSM Route Map"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: const LatLng(13.7563, 100.5018),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints,
                strokeWidth: 4.0,
                color: const Color.fromARGB(255, 255, 0, 0),
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: start,
                width: 80.0,
                height: 80.0,
                child: const Icon(Icons.location_pin,
                    color: Colors.red), // Directly passing the Icon widget
              ),
              Marker(
                point: end,
                width: 80.0,
                height: 80.0,
                child: const Icon(Icons.location_pin,
                    color: Colors.green), // Directly passing the Icon widget
              ),
            ],
          ),
        ],
      ),
    );
  }
}
