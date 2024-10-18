import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryStatusScreen extends StatefulWidget {
  @override
  _DeliveryStatusScreenState createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  List<bool> statusActive = [false, false, false, false];
  bool isLoading = true;
  late String orderId;

  @override
  void initState() {
    super.initState();
    final Map<String, dynamic> args = Get.arguments as Map<String, dynamic>;
    orderId = args['orderId'] ?? 'Unknown orderId';
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
                          _buildTitle('รูปประกอบสถานะระหว่างจัดส่ง'),
                          SizedBox(height: 10),
                          _buildOrderItemDetails(orderData),
                          SizedBox(height: 20),
                          _buildDeliveryPersonDetails(orderData),
                          SizedBox(height: 20),
                          _buildViewLocationButton(orderData),
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
      width: 390,
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 20),
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
              onPressed: () => Navigator.pop(context),
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
      width: 35,
      height: 3,
      color: isActive ? Color(0xFF412160) : Colors.grey.shade300,
      margin: EdgeInsets.only(bottom: 20),
    );
  }

  Widget _buildUserDetails(Map<String, dynamic> orderData) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(orderData['senderId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error loading user details');
        }
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return ListTile(
          leading: CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(
                userData['img'] ?? 'https://via.placeholder.com/150'),
          ),
          title: Text('ชื่อ: ${userData['fullname']}'),
          subtitle: Text('เบอร์โทร: ${userData['phone']}'),
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
              child: Image.network(
                orderItem['Photos'] ?? 'https://via.placeholder.com/150',
                fit: BoxFit.cover,
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
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('Users')
          .doc(orderData['receiverId'])
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Text('Error loading delivery person details');
        }
        final receiverData = snapshot.data!.data() as Map<String, dynamic>;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: 'ผู้จัดส่ง: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: receiverData['fullname'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: 'ที่อยู่: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: orderData['deliveryAddress'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                      text: 'เบอร์โทร: ',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: receiverData['phone'] ?? 'ไม่ระบุ'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildViewLocationButton(Map<String, dynamic> orderData) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement location viewing functionality
        },
        child: Text(
          'ดูตำแหน่ง',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
      ),
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
        return 'รับของแล้ว';
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
