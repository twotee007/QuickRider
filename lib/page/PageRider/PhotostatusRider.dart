import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageRider/MapOrderRider.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';
import 'package:uuid/uuid.dart';

class PhotostatusriderPage extends StatefulWidget {
  const PhotostatusriderPage({super.key});

  @override
  State<PhotostatusriderPage> createState() => _PhotostatusriderPageState();
}

class _PhotostatusriderPageState extends State<PhotostatusriderPage> {
  final riderService = Get.find<RiderService>();
  final ImagePicker picker = ImagePicker();
  File? imageFile; // ตัวแปรสำหรับเก็บไฟล์รูปภาพที่เลือก
  String orderid = '';
  String senderId = '';
  String receiverId = '';
  String productName = '';
  String description = '';
  int quantity = 0;
  String name = '';
  String address = '';
  String phone = '';
  String status = '';
  String textstatus = '';
  String text = '';
  late Future<void> loadData;
  @override
  void initState() {
    super.initState();
    orderid = context.read<AppData>().order.orderId;
    senderId = context.read<AppData>().order.senderId;
    receiverId = context.read<AppData>().order.receiverId;
    log('orderid : $orderid');
    log('senderId : $senderId');
    log('receiverId : $receiverId');
    loadData = loadDataAstnc();
  }

  Future<void> loadDataAstnc() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderid)
              .get();

      if (documentSnapshot.exists) {
        setState(() {
          status =
              documentSnapshot.data()?['status']; // ดึง status จาก Firestore
        });

        // ดึง gpsLocation จาก collection Users ตาม Riderid
      } else {
        log("No such document status!");
      }
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('orderItems')
          .where('orderId', isEqualTo: orderid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          Map<String, dynamic>? orderItemData = doc.data();
          description = orderItemData['description'] ?? 'ไม่มีรายละเอียด';
          quantity = orderItemData['quantity'] ?? 0;
          productName = orderItemData['name'] ?? 'ไม่ทราบชื่อผลิตภัณฑ์';

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
          if (status == '2') {
            name = senderDoc.data()?['fullname'] ?? 'ไม่ทราบชื่อผู้ส่ง';
            address = senderDoc.data()?['address'] ?? 'ไม่ทราบที่อยู่ผู้ส่ง';
            phone = senderDoc.data()?['phone'] ?? 'ไม่ทราบเบอร์โทรผู้ส่ง';
            textstatus = 'เพิ่มรูปภาพประกอบสถานะรับของ';
            text = 'รับของจากคุณ';
          } else {
            name = receiverDoc.data()?['fullname'] ?? 'ไม่ทราบชื่อผู้รับ';
            address = receiverDoc.data()?['address'] ?? 'ไม่ทราบที่อยู่ผู้รับ';
            phone = receiverDoc.data()?['phone'] ?? 'ไม่ทราบเบอร์โทรผู้รับ';
            textstatus = 'เพิ่มรูปภาพประกอบสถานะจัดส่งสำเร็จ';
            text = 'จัดส่งคุณ';
          }

          // Update the UI
          setState(() {});
        }
      } else {
        log('ไม่มีรายการใดที่ตรงกับ orderId: ${orderid}');
      }
    } catch (e) {
      log('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path); // อัปเดตรูปภาพในสถานะ
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
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
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: FutureBuilder(
                      future: loadData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(
                            child: (CircularProgressIndicator()),
                          );
                        }

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                                height: 50), // เพิ่มระยะห่างจากปุ่มย้อนกลับ
                            GestureDetector(
                              onTap: () {
                                _showImageSourceActionSheet(context);
                              },
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[200],
                                child: imageFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          imageFile!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      )
                                    : Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.camera,
                                            color: Color(0xFF412160),
                                            size: 50,
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(3),
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: Color(0xFF412160),
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '$textstatus',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'ชื่อสินค้า : $productName',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'จำนวน : $quantity x',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'รายละเอียดสินค้า : $description',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: Text(
                                  '$text',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'คุณ : $name',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'ที่อยู่ : $address',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                child: Text(
                                  'เบอร์โทร : $phone',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  submit(); // ส่งข้อมูลถ้าข้อมูลครบ
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 18, 172, 82),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  status == '2'
                                      ? 'รับของสำเร็จ'
                                      : 'จัดส่งสำเร็จ', // เปลี่ยนข้อความตาม status
                                  style: const TextStyle(
                                    fontSize: 20, // ขนาดฟอนต์
                                    color: Colors.white, // สีข้อความ
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  // ปุ่มย้อนกลับที่ซ้ายบนของกล่องสี่เหลี่ยม
                  Positioned(
                    top: 10,
                    left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        _checkPermissions();
                        Get.to(
                          () => const MapOrderPage(),
                          transition: Transition.leftToRightWithFade,
                          duration: const Duration(milliseconds: 300),
                        );
                      },
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

  void submit() async {
    _checkPermissions();

    if (imageFile == null) {
      // No image selected, show an error message
      Get.snackbar(
        'ข้อผิดพลาด', // หัวข้อ
        'กรุณา$textstatus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return; // Stop further execution if there's no image
    }

    // Show loading dialog
    showDialog(
      context: Get.context!,
      barrierDismissible: false, // Prevent dismissing while loading
      builder: (BuildContext context) {
        return const Center(
          child:
              CircularProgressIndicator(), // Show circular progress indicator
        );
      },
    );

    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      if (status == '2') {
        // Upload image for Photopickup
        String fileName = '${const Uuid().v4()}.jpg';
        String filePath = 'orders_status/$fileName';
        Reference storageRef = storage.ref().child(filePath);
        UploadTask uploadTask = storageRef.putFile(imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with Photopickup and status 3
        await firestore.collection('orders').doc(orderid).update({
          'Photopickup': downloadUrl,
          'status': '3',
        });

        log('Image uploaded and order updated successfully for status 2');
        Get.back();

        Get.to(() => const MapOrderPage(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 300));
      } else if (status == '3') {
        // Upload image for deliveredPhoto
        String fileName = '${const Uuid().v4()}.jpg';
        String filePath = 'orders_status/$fileName';
        Reference storageRef = storage.ref().child(filePath);
        UploadTask uploadTask = storageRef.putFile(imageFile!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with deliveredPhoto and status 4
        await firestore.collection('orders').doc(orderid).update({
          'deliveredPhoto': downloadUrl,
          'status': '4',
        });

        log('Image uploaded and order updated successfully for status 3');
        Get.back();

        // Navigate to home after successful update
        Get.offAll(() => const HomeRiderPage());
        return;
      }
    } catch (e) {
      log('Error uploading image or updating order: $e');
      Navigator.pop(context); // Close loading dialog in case of error
      // Show error message to the user
      Get.snackbar(
        'Error',
        'Failed to upload image and update order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Stop further execution in case of error
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

    // Start tracking location if permissions are granted
  }
}
