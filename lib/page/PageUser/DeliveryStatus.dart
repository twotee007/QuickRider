import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickrider/page/PageUser/MapScreen.dart';

class DeliveryStatusScreen extends StatefulWidget {
  @override
  _DeliveryStatusScreenState createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  List<bool> statusActive = [false, false, false, false];
  bool isLoading = true;
  late String orderId;
  File? selectedImage;
  bool _isLoading = false;
  String? uploadedImageUrl;
  final box = GetStorage();

  bool isImageUploaded = false;
  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] ?? 'Unknown orderId';
    // _fetchOrderData();
    (orderId);
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _getOrderStream(
      String orderId) {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .snapshots();
  }

  Future<void> pickImage(String orderId, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
        _isLoading = true; // เริ่มโหลด
      });
      // อัปโหลดภาพไปยัง Firebase Storage พร้อมกับ orderId
      await uploadImageToFirebase(selectedImage!, orderId);
      setState(() {
        _isLoading = false; // หยุดแสดงสถานะโหลดเมื่อเสร็จสิ้นการอัปโหลด
      });
    } else {
      setState(() {
        _isLoading = false; // กรณีที่ไม่เลือกภาพก็หยุดแสดงสถานะโหลด
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, String orderId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('ถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(
                      orderId, ImageSource.camera); // เลือกถ่ายรูปจากกล้อง
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(
                      orderId, ImageSource.gallery); // เลือกรูปจากแกลเลอรี่
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadImageToFirebase(File image, String orderId) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef =
          FirebaseStorage.instance.ref().child('images/$fileName');

      // อัปโหลดภาพ
      await storageRef.putFile(image);

      // รับ URL ของภาพที่อัปโหลด
      String imageUrl = await storageRef.getDownloadURL();

      // อัปเดต Firestore ด้วย URL ของภาพและ orderId
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'senderPhoto': imageUrl,
      });

      // อัปเดตตัวแปรสถานะ
      setState(() {
        uploadedImageUrl = imageUrl; // ตั้งค่า URL ของภาพที่อัปโหลด
        isImageUploaded = true; // อัปเดตสถานะว่ามีการอัปโหลด
        _isLoading = false; // หยุดโหลด
      });

      // แจ้งเตือนเมื่ออัปโหลดเสร็จสิ้น
      Get.snackbar('สำเร็จ', 'อัปโหลดรูปภาพเรียบร้อยแล้ว');
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'ไม่สามารถอัปโหลดรูปภาพได้: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Order not found'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          _updateStatus(orderData['status']);

          return Column(
            children: [
              _buildTopHeader(),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          _buildTitle('สถานะการจัดส่ง'),
                          SizedBox(height: 16),
                          buildStatusRow(),
                          SizedBox(height: 20),
                          _buildUserDetails(orderData),
                          SizedBox(height: 16),
                          _buildTitle('รูปสินค้าระหว่างการจัดส่ง'),
                          SizedBox(height: 10),
                          _buildOrderItemDetails(orderData),
                          SizedBox(height: 20),
                          _buildDeliveryPersonDetails(orderData),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: 350,
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      margin: const EdgeInsets.only(top: 50),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                bool senderId =
                    box.read('senderId') == true; // ถ้าไม่ใช่ true จะเป็น false
                bool receiverId = box.read('receiverId') ==
                    true; // ถ้าไม่ใช่ true จะเป็น false

                if (senderId) {
                  Get.to(() => MapscreenPage(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300));
                } else if (receiverId) {
                  Get.to(() => MapscreenPage(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300));
                } else {
                  Get.back(); // ย้อนกลับไปยังหน้าที่ผ่านมา
                }
              },
            ),
            Text(
              'Quick Rider',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 50),
          ],
        ),
      ),
    );
  }

  Widget buildStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 0; i < 4; i++) ...[
          _buildStatusColumn(
            _getIconForIndex(i),
            _getLabelForIndex(i),
            statusActive[i],
          ),
          if (i < 3) _buildHorizontalConnectorLine(statusActive[i]),
        ],
      ],
    );
  }

  Widget _buildStatusColumn(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: isActive ? Color(0xFF412160) : Colors.grey.shade300,
          child: Icon(icon, size: 28, color: Colors.white),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Color(0xFF412160) : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalConnectorLine(bool isActive) {
    return Container(
      width: 30,
      height: 3,
      color: isActive ? Color(0xFF412160) : Colors.grey.shade300,
      margin: EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> orderData) {
    final riderId = orderData['riderId']; // ดึง riderId จาก orderData

    if (riderId == null || riderId.isEmpty) {
      // กรณีไม่มี riderId ให้แสดงข้อความรอไรเดอร์รับงาน
      return ListTile(
        title: Text(
          'รอไรเดอร์รับงาน.....',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        leading: Icon(Icons.access_time, size: 40, color: Colors.grey),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(riderId) // ใช้ riderId ที่ตรวจสอบแล้ว
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Text('เกิดข้อผิดพลาดในการโหลดข้อมูล');
        }

        final riderData = snapshot.data!.data() as Map<String, dynamic>;

        return ListTile(
          leading: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
                riderData['img'] ?? 'https://via.placeholder.com/150'),
          ),
          title: Text('ชื่อไรเดอร์: ${riderData['fullname']}'),
          subtitle: Text(
              'เบอร์โทร: ${riderData['phone']} \nทะเบียนรถ: ${riderData['registration']}'),
        );
      },
    );
  }

  Widget _buildOrderItemDetails(Map<String, dynamic> orderData) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('orderItems')
          .where('orderId', isEqualTo: orderId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Text('Error loading order items');
        }
        final orderItem =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // ปรับขอบให้โค้ง
                child: Image.network(
                  orderItem['Photos'] ?? 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'ชื่อสินค้า: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: orderItem['name']),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'จำนวน: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: '${orderItem['quantity']} x'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8), // เพิ่มระยะห่างก่อน description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: Colors.black),
                      children: [
                        TextSpan(
                            text: 'รายละเอียด: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(
                            text:
                                orderItem['description'] ?? 'ไม่มีรายละเอียด'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeliveryPersonDetails(Map<String, dynamic> orderData) {
    final senderId = orderData['senderId'];
    final receiverId = orderData['receiverId'];

    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('Users').doc(senderId).get(),
        FirebaseFirestore.instance.collection('Users').doc(receiverId).get(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data!.length < 2) {
          return Text('Error loading delivery details');
        }

        final senderData = snapshot.data![0].data() as Map<String, dynamic>;
        final receiverData = snapshot.data![1].data() as Map<String, dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // เส้นคั้นและหัวข้อผู้ส่ง
            Divider(height: 1, thickness: 1, color: Colors.grey[300]),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'ข้อมูลผู้ส่ง',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // ข้อมูลผู้ส่ง
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'ผู้ส่ง: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: senderData['fullname'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'ที่อยู่ผู้ส่ง: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: senderData['address'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'เบอร์โทรผู้ส่ง: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: senderData['phone'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            SizedBox(height: 10),

            // ข้อมูลผู้รับ
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'ผู้รับ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: receiverData['fullname'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'ที่อยู่ผู้รับ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: orderData['deliveryAddress'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: 'เบอร์โทรผู้รับ: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: receiverData['phone'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),

            // เพิ่มรูปภาพประกอบสถานะ
            _buildAddImageSection(orderId),
          ],
        );
      },
    );
  }

  Widget _buildAddImageSection(String orderId) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _getOrderStream(orderId), // เรียลไทม์สตรีม
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // แสดง spinner ขณะกำลังโหลดข้อมูลจาก Firestore
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            'ไม่มีข้อมูลคำสั่งซื้อ',
            style: TextStyle(fontSize: 16, color: Colors.red),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        // ตรวจสอบข้อมูล
        String status = data['status'] ?? '';
        String userId = box.read('Userid');
        String uploadedImageUrl = '';
        bool isImageUploaded = false;
        bool isReceiver = data['receiverId'] == userId;

        // ตรวจสอบสถานะและกำหนดรูปภาพตามลำดับสถานะ
        if (status == '4') {
          // ถ้า deliveredPhoto เป็น null, ให้ใช้ Photopickup จากสถานะ 3 หรือ senderPhoto จากสถานะก่อนหน้า
          uploadedImageUrl = data['deliveredPhoto'] ??
              data['Photopickup'] ??
              data['senderPhoto'] ??
              '';
        } else if (status == '3') {
          // ถ้า Photopickup เป็น null, ให้ใช้ senderPhoto จากสถานะก่อนหน้า
          uploadedImageUrl = data['Photopickup'] ?? data['senderPhoto'] ?? '';
        } else {
          // สถานะอื่น ๆ ใช้ senderPhoto
          uploadedImageUrl = data['senderPhoto'] ?? '';
        }

        // ถ้ามีรูปภาพใดๆ แสดงว่าอัปโหลดแล้ว
        isImageUploaded = uploadedImageUrl.isNotEmpty;

        // เมื่อโหลดภาพเสร็จแล้วให้ตั้งสถานะ _isLoading เป็น false
        if (isImageUploaded) {
          _isLoading = false;
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // ป้องกันไม่ให้ Column ยืดเต็มความสูง
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'รูปประกอบสถานะระหว่างจัดส่ง:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _isLoading
                    ? CircularProgressIndicator() // แสดง spinner ระหว่างรอโหลดรูป
                    : isImageUploaded
                        ? Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  uploadedImageUrl,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'เพิ่มรูปภาพแล้ว',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.green),
                              ),
                            ],
                          )
                        : Text(
                            'ไม่มีรูปภาพประกอบสถานะ',
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                SizedBox(height: 10),
                // แสดงปุ่มเพิ่มรูปภาพเฉพาะเมื่อไม่ใช่ผู้รับและไม่มีการอัปโหลดภาพใดๆ
                !isImageUploaded && !isReceiver && status != '2'
                    ? Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            _showImageSourceActionSheet(context,
                                orderId); // เรียกใช้งานฟังก์ชันการเลือกแหล่งที่มาของรูปภาพ
                          },
                          child: Text('เพิ่มรูปภาพ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF412160),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.pending_actions;
      case 1:
        return Icons.check_box;
      case 2:
        return Icons.delivery_dining;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.error;
    }
  }

  String _getLabelForIndex(int index) {
    switch (index) {
      case 0:
        return 'รอจัดส่ง';
      case 1:
        return 'รับงานแล้ว';
      case 2:
        return 'กำลังจัดส่ง';
      case 3:
        return 'ส่งแล้ว';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  void _updateStatus(String? status) {
    statusActive = [false, false, false, false];
    int statusIndex = int.tryParse(status ?? '') ?? 0;
    statusIndex = statusIndex - 1;
    for (int i = 0; i <= statusIndex && i < statusActive.length; i++) {
      statusActive[i] = true;
    }
  }
}
