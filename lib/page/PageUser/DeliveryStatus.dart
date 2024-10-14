import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryStatusScreen extends StatefulWidget {
  @override
  _DeliveryStatusScreenState createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  List<bool> statusActive = [false, false, false, false]; // สถานะของแต่ละขั้น
  bool isLoading = true; // ตัวแปรเพื่อตรวจสอบสถานะการโหลด

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF412160), // พื้นหลังสีม่วง
      body: Column(
        children: [
          // กรอบด้านบนสีขาว
          _buildTopHeader(),

          SizedBox(height: 20),

          // กรอบสีขาวคลุมพื้นที่ด้านล่าง
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white, // สีขาวคลุมพื้นด้านล่าง
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
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

                      // StreamBuilder เพื่อติดตามสถานะการจัดส่ง
                      StreamBuilder<DeliveryStatus>(
                        stream: getDeliveryStatusStream(), // ดึงสถานะจาก Stream
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final status = snapshot.data;
                          _updateStatus(status); // อัปเดตสถานะในแอป

                          return buildStatusRow(); // แสดงสถานะพร้อมเส้นเชื่อม
                        },
                      ),

                      SizedBox(height: 20),

                      _buildUserDetails(), // แสดงรายละเอียดผู้ใช้งาน

                      SizedBox(height: 16),
                      _buildTitle('รูปประกอบสถานะระหว่างจัดส่ง'),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // สี่เหลี่ยมจตุรัสสำหรับรูปภาพ
                          Container(
                            width: 150, // กำหนดความกว้าง
                            height: 150, // กำหนดความสูงให้เท่ากัน
                            child: Image.asset(
                              'assets/img/logo.png',
                              fit: BoxFit
                                  .cover, // ปรับขนาดรูปให้พอดีกับ Container
                            ),
                          ),
                          SizedBox(
                              width: 20), // ระยะห่างระหว่างรูปภาพกับข้อความ
                          // ข้อความรายละเอียดสินค้า
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start, // ข้อความอยู่ซ้าย
                              mainAxisAlignment: MainAxisAlignment
                                  .center, // จัดให้อยู่ตรงกลางในแนวตั้ง
                              children: [
                                SizedBox(
                                    height:
                                        40), // เพิ่มระยะห่างด้านบนของข้อความ
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black), // สีพื้นฐาน
                                    children: [
                                      TextSpan(
                                        text: 'ชื่อสินค้า: ',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold), // ตัวหนา
                                      ),
                                      TextSpan(
                                        text: 'น้ำพิเศษ',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.normal), // ปกติ
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black), // สีพื้นฐาน
                                    children: [
                                      TextSpan(
                                        text: 'จำนวน: ',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.bold), // ตัวหนา
                                      ),
                                      TextSpan(
                                        text: '100 x',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight.normal), // ปกติ
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 16, color: Colors.black), // สีพื้นฐาน
                          children: [
                            TextSpan(
                              text: 'รายละเอียดสินค้า: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold), // ตัวหนา
                            ),
                            TextSpan(
                              text: 'น้ำพิเศษทำจากป๋องแชลอท...',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal), // ปกติ
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),
                      _buildDeliveryPersonDetails(), // แสดงข้อมูลผู้จัดส่ง

                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // กำหนดฟังก์ชันการทำงานเมื่อต้องการกดดูตำแหน่ง
                          },
                          child: Text(
                            'ดูตำแหน่ง',
                            style: TextStyle(
                              color: Colors.white, // สีของข้อความ
                              fontWeight:
                                  FontWeight.bold, // ทำให้ข้อความเป็นตัวหนา
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

  // กรอบหัวด้านบนสีขาว
  Widget _buildTopHeader() {
    return Container(
      width: 390,
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context); // ย้อนกลับ
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

  // แถวแสดงสถานะการจัดส่ง
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
          if (i < 3) _buildHorizontalConnectorLine(statusActive[i + 1]),
        ],
      ],
    );
  }

  // วิดเจ็ตแสดงสถานะพร้อมไอคอนและข้อความ
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

  // เส้นเชื่อมระหว่างสถานะ
  Widget _buildHorizontalConnectorLine(bool isActive) {
    return Container(
      width: 35,
      height: 3,
      color: isActive ? Color(0xFF412160) : Colors.grey.shade300,
      margin: EdgeInsets.only(bottom: 20), // ปรับระยะห่างขึ้น
    );
  }

  // ข้อมูลผู้ใช้และรายละเอียดการจัดส่ง
  Widget _buildUserDetails() {
    return ListTile(
      leading: CircleAvatar(
        radius: 40, // ปรับขนาดวงกลมที่แสดงรูปภาพ
        backgroundImage: AssetImage('assets/img/logo.png'),
      ),
      title: Text('ชื่อ: นายยูนิเยร์'),
      subtitle: Text('เบอร์โทร: 095651599\nทะเบียนรถ: กข 255'),
    );
  }
// Widget _buildUserDetails() {
//   return ListTile(
//     leading: Container(
//       width: 80, // ขนาดความกว้างของวงกลม
//       height: 80, // ขนาดความสูงของวงกลม
//       decoration: BoxDecoration(
//         shape: BoxShape.circle, // ทำให้เป็นวงกลม
//         image: DecorationImage(
//           image: AssetImage('assets/img/logo.png'), // รูปภาพที่ใช้
//           fit: BoxFit.cover, // ปรับให้รูปภาพเต็มวงกลม
//         ),
//       ),
//     ),
//     title: Text('ชื่อ: นายยูนิเยร์'),
//     subtitle: Text('เบอร์โทร: 095651599\nทะเบียนรถ: กข 255'),
//   );
// }

  // ข้อมูลผู้จัดส่ง
  Widget _buildDeliveryPersonDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black), // สีพื้นฐาน
            children: [
              TextSpan(
                text: 'ผู้จัดส่ง: ',
                style: TextStyle(fontWeight: FontWeight.bold), // ตัวหนา
              ),
              TextSpan(
                text: 'คุณอารฟล', // ข้อมูลปกติ
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black), // สีพื้นฐาน
            children: [
              TextSpan(
                text: 'ที่อยู่: ',
                style: TextStyle(fontWeight: FontWeight.bold), // ตัวหนา
              ),
              TextSpan(
                text: '999 หมู่ 99 ต.ดงดอกอ้อ อ.ขนมรส', // ข้อมูลปกติ
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 16, color: Colors.black), // สีพื้นฐาน
            children: [
              TextSpan(
                text: 'เบอร์โทร: ',
                style: TextStyle(fontWeight: FontWeight.bold), // ตัวหนา
              ),
              TextSpan(
                text: '099636933', // ข้อมูลปกติ
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // กำหนดไอคอนสำหรับแต่ละสถานะ
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

  // กำหนดข้อความสำหรับแต่ละสถานะ
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

  // ฟังก์ชันอัปเดตสถานะ
  void _updateStatus(DeliveryStatus? status) {
    statusActive = [false, false, false, false];
    if (status != null) {
      for (int i = 0; i <= status.index; i++) {
        statusActive[i] = true;
      }
    }
  }

  // Stream จำลองการเปลี่ยนสถานะ
  Stream<DeliveryStatus> getDeliveryStatusStream() async* {
    await Future.delayed(Duration(seconds: 1));
    yield DeliveryStatus.pending;
    await Future.delayed(Duration(seconds: 2));
    yield DeliveryStatus.pickedUp;
    await Future.delayed(Duration(seconds: 2));
    yield DeliveryStatus.delivering;
    await Future.delayed(Duration(seconds: 2));
    yield DeliveryStatus.delivered;
  }
}

// Enum สำหรับสถานะการจัดส่ง
enum DeliveryStatus { pending, pickedUp, delivering, delivered }
