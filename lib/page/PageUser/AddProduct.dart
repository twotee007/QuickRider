import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productQuantityController =
      TextEditingController();
  final TextEditingController _productDetailsController =
      TextEditingController();
  final TextEditingController _shippingAddressController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final userService = Get.find<UserService>();
  File? _imageFile; // ตัวแปรสำหรับเก็บรูปภาพที่เลือก
  final box = GetStorage();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late Future<void> loadDate;
  late Map<String, dynamic>? user;
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path); // อัปเดตรูปภาพในสถานะ
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadDate = loadDataAstnc();
    phoneuser();
  }

  void phoneuser() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('type', isEqualTo: 'user') // กรองเฉพาะประเภทผู้ใช้ 'user'
          .get();

      _databasePhones = snapshot.docs.map((doc) {
        return doc['phone'] as String; // ดึงเบอร์โทรศัพท์จากเอกสาร
      }).toList();

      // ทำอะไรกับเบอร์โทรศัพท์ที่ค้นพบ เช่น แสดงใน UI หรืออื่น ๆ
      log('User Phones: $_databasePhones');
    } catch (e) {
      print('Error fetching user phones: $e');
    }
  }

  // จำลองฐานข้อมูลเบอร์โทรศัพท์
  List<String> _databasePhones = []; // ประกาศตัวแปรที่ระดับคลาส
  List<String> _filteredPhones = [];

  void _searchPhoneNumber(String input) {
    setState(() {
      if (input.isEmpty) {
        _filteredPhones.clear();
        _shippingAddressController.clear();
      } else {
        _filteredPhones =
            _databasePhones.where((phone) => phone.startsWith(input)).toList();
      }
    });
  }

  Future<void> _fetchUserAddress(String phone) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get()
          .then((querySnapshot) => querySnapshot.docs.first);

      if (snapshot.exists) {
        String address =
            snapshot['address'] as String; // สมมติว่า field ชื่อ 'address'
        // ทำอะไรกับที่อยู่ที่ดึงมา เช่น แสดงใน UI
        setState(() {
          _shippingAddressController.text = address; // กรอกที่อยู่ใน TextField
        });
      }
    } catch (e) {
      print('Error fetching user address: $e');
    }
  }

  void _selectPhoneNumber(String phone) {
    setState(() {
      _phoneController.text = phone;
      _filteredPhones.clear();
    });

    if (phone.isEmpty) {
      _shippingAddressController.clear(); // ล้างที่อยู่เมื่อไม่มีเบอร์โทร
    } else {
      _fetchUserAddress(phone); // เรียกฟังก์ชันเพื่อดึงที่อยู่
    }
  }

  // ฟังก์ชันสร้าง TextField
  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLines: null, // ทำให้จำนวนบรรทัดไม่จำกัด
          keyboardType: TextInputType.text, // กำหนดให้เป็นข้อความ
          textInputAction: TextInputAction.done, // ปุ่ม Done
          decoration: InputDecoration(
            border: const UnderlineInputBorder(), // เปลี่ยนเป็นเส้นใต้
            isDense: true, // ลดขนาดของฟอร์มให้พอดี
          ),
        ),
      ],
    );
  }

// ฟังก์ชันสร้าง TextField สำหรับจำนวนสินค้า (เฉพาะตัวเลข)
  Widget _buildQuantityField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType:
              TextInputType.number, // กำหนดให้เป็นแป้นพิมพ์สำหรับหมายเลข
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter
                .digitsOnly, // อนุญาตให้กรอกได้เฉพาะตัวเลข
          ],
          decoration: InputDecoration(
            border: const UnderlineInputBorder(), // เปลี่ยนเป็นเส้นใต้
            isDense: true, // ลดขนาดของฟอร์มให้พอดี
          ),
        ),
      ],
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
            child: cycletop(
              userService.name, // ใช้ข้อมูลชื่อจาก UserService
              userService.url, // ใช้ข้อมูล URL จาก UserService
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
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // แถวสำหรับลูกศรกลับ
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_back, // ลูกศรกลับ
                                      color: Color(0xFF412160),
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(
                                          context); // กลับไปหน้าก่อนหน้า
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(
                                  height: 0), // ช่องว่างระหว่างลูกศรกับวงกลม

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 30),
                                  // วงกลมสำหรับไอคอนเพิ่มรูปภาพ
                                  Center(
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Color(0xFF412160),
                                          width: 1,
                                        ),
                                      ),
                                      child: InkWell(
                                        splashColor:
                                            Colors.purple.withOpacity(0.5),
                                        highlightColor:
                                            Colors.purple.withOpacity(0.5),
                                        child: Center(
                                          child: _imageFile ==
                                                  null // ตรวจสอบว่ามีรูปภาพหรือไม่
                                              ? Icon(
                                                  Icons
                                                      .add_photo_alternate_outlined,
                                                  color: Color(0xFF412160),
                                                  size: 80,
                                                )
                                              : ClipOval(
                                                  // แสดงรูปภาพในรูปทรงวงกลม
                                                  child: Image.file(
                                                    _imageFile!,
                                                    fit: BoxFit.cover,
                                                    width: 120,
                                                    height: 120,
                                                  ),
                                                ),
                                        ),
                                        onTap: () {
                                          _showImageSourceActionSheet(context);
                                        },
                                      ),
                                    ),
                                  ),

                                  // คอลัมน์สำหรับกรอบค้นหาเบอร์โทร
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(
                                              left: 10), // ขยับไปทางซ้าย
                                          child: SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller: _phoneController,
                                              onChanged: (value) {
                                                _searchPhoneNumber(value);
                                              },
                                              keyboardType: TextInputType
                                                  .phone, // กำหนดให้เป็นแป้นพิมพ์สำหรับหมายเลขโทรศัพท์
                                              decoration: InputDecoration(
                                                labelText: 'เบอร์โทรผู้รับ',
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10), // ขอบโค้ง
                                                ),
                                                isDense: true,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              _buildTextField(
                                  'ชื่อสินค้า:', _productNameController),
                              const SizedBox(height: 20),
                              _buildQuantityField(
                                  'จำนวนสินค้า:', _productQuantityController),
                              const SizedBox(height: 20),
                              _buildTextField('รายละเอียดสินค้า:',
                                  _productDetailsController),
                              const SizedBox(height: 20),
                              _buildTextField('ที่อยู่จัดส่งที่:',
                                  _shippingAddressController),
                              const SizedBox(height: 30),
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // โค้ดสำหรับการจัดส่งสินค้า
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 50, vertical: 15),
                                    backgroundColor: const Color(0xFF00C853),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'จัดส่ง',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
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
            ),
          ),

          // ส่วนกรอบผลการค้นหา
          if (_filteredPhones.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              top: 310, // ปรับตำแหน่งตามต้องการ
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(8), // เพิ่ม padding ภายในกรอบ
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _filteredPhones.map((phone) {
                      return GestureDetector(
                        onTap: () {
                          _selectPhoneNumber(phone);
                        },
                        child: Container(
                          // กรอบใหม่สำหรับแต่ละหมายเลข
                          margin: const EdgeInsets.symmetric(
                              vertical: 4), // ระยะห่างระหว่างหมายเลข
                          padding: const EdgeInsets.all(8), // Padding ภายในกรอบ
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey), // ขอบกรอบ
                            borderRadius: BorderRadius.circular(5), // ขอบโค้ง
                            color: Colors.white,
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: _highlightMatchedText(
                                  phone, _phoneController.text),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
                leading: Icon(Icons.camera_alt),
                title: Text('ถ่ายรูป'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('เลือกจากแกลเลอรี่'),
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

  List<TextSpan> _highlightMatchedText(String fullText, String searchText) {
    final List<TextSpan> spans = [];
    if (searchText.isEmpty) {
      spans.add(TextSpan(text: fullText));
      return spans;
    }

    int start = 0;
    int indexOfHighlight = fullText.indexOf(searchText);

    while (indexOfHighlight != -1) {
      if (indexOfHighlight > start) {
        spans.add(TextSpan(text: fullText.substring(start, indexOfHighlight)));
      }

      spans.add(TextSpan(
        text: fullText.substring(
            indexOfHighlight, indexOfHighlight + searchText.length),
        style: const TextStyle(color: Colors.green),
      ));

      start = indexOfHighlight + searchText.length;
      indexOfHighlight = fullText.indexOf(searchText, start);
    }

    if (start < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(start)));
    }

    return spans;
  }

  // Future<void> loadDataAstnc() async {
  //   String userid = box.read('Userid');
  //   try {
  //     // เข้าถึงเอกสารโดยใช้ Document ID
  //     var docSnapshot = await db.collection('Users').doc(userid).get();

  //     if (docSnapshot.exists) {
  //       log('Document ID: ${docSnapshot.id}'); // แสดง ID ของเอกสาร

  //       // เก็บข้อมูลใน Map
  //       user = docSnapshot.data() as Map<String, dynamic>?;
  //       log('Data: $user'); // แสดงข้อมูลทั้งหมด

  //       // อัปเดต UI เมื่อโหลดข้อมูลเสร็จ
  //       setState(() {}); // เรียกใช้ setState เพื่อให้ UI อัปเดต
  //     } else {
  //       log('No user found with docId: ${docSnapshot.id}');
  //     }
  //   } catch (e) {
  //     log('Error fetching user: $e');
  //   }
  // }
}
