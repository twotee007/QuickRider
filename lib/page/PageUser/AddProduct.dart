import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:image_picker/image_picker.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';
import 'package:uuid/uuid.dart';

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
  List<Map<String, dynamic>> _productControllers = [];
  final ImagePicker _picker = ImagePicker();
  final userService = Get.find<UserService>();
  File? _imageFile; // ตัวแปรสำหรับเก็บรูปภาพที่เลือก
  final box = GetStorage();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late Future<void> loadDate;
  late Map<String, dynamic>? user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // loadDate = loadDataAstnc();
    phoneuser();
    _addProductFields();
  }

  void _addProductFields() {
    setState(() {
      Map<String, dynamic> productMap = {
        'productName': TextEditingController(),
        'productQuantity': TextEditingController(),
        'productDetails': TextEditingController(),
        'image': null,
      };
      _productControllers.add(productMap);
    });
  }

  Future<void> _pickImage(ImageSource source, int index) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _productControllers[index]['image'] =
            File(pickedFile.path); // อัปเดตรูปภาพในสถานะ
      });
    }
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
                                  height: 10), // ช่องว่างระหว่างลูกศรกับวงกลม
                              Text('กรอกเบอร์ผู้รับ'),
                              const SizedBox(height: 20),

                              Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .center, // จัดให้อยู่ด้านขวา
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        right:
                                            30), // ปรับเป็น right แทน left เพื่อขยับไปทางขวา
                                    child: SizedBox(
                                      width: 200,
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
                                            borderRadius: BorderRadius.circular(
                                                10), // ขอบโค้ง
                                          ),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),

                              _buildTextField('ที่อยู่จัดส่งที่:',
                                  _shippingAddressController),
                              const SizedBox(height: 30),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 20), // ระยะห่างแนวตั้ง
                                height: 5, // ความสูงของเส้น
                                color: const Color.fromARGB(
                                    255, 59, 0, 102), // สีของเส้น
                              ),

                              // แสดงรายการสินค้าพร้อมปุ่มลบ
                              ..._productControllers
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                int index = entry.key;
                                var product = entry.value;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (index != 0)
                                      Divider(
                                        color: Color(0xFF412160), // สีม่วง
                                        thickness: 3, // ความหนา
                                      ),
                                    const SizedBox(height: 10),

                                    // แสดงข้อความ "รายการที่ X"
                                    Text(
                                      'รายการที่ ${index + 1}', // แสดงหมายเลขรายการ
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(
                                            255, 255, 4, 4), // สีม่วงเข้ม
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    Stack(
                                      children: [
                                        // แสดงถังขยะเฉพาะรายการที่ไม่ใช่รายการแรก
                                        if (index != 0)
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _removeProductField(
                                                    index); // เรียกฟังก์ชันลบสินค้า
                                              },
                                            ),
                                          ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
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
                                                  splashColor: Colors.purple
                                                      .withOpacity(0.5),
                                                  highlightColor: Colors.purple
                                                      .withOpacity(0.5),
                                                  child: Center(
                                                    child: product['image'] ==
                                                            null
                                                        ? Icon(
                                                            Icons
                                                                .add_photo_alternate_outlined,
                                                            color: Color(
                                                                0xFF412160),
                                                            size: 80,
                                                          )
                                                        : ClipOval(
                                                            child: Image.file(
                                                              product['image'],
                                                              fit: BoxFit.cover,
                                                              width: 120,
                                                              height: 120,
                                                            ),
                                                          ),
                                                  ),
                                                  onTap: () {
                                                    _showImageSourceActionSheet(
                                                        context, index);
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    _buildTextField(
                                        'ชื่อสินค้า:', product['productName']),
                                    const SizedBox(height: 20),
                                    _buildQuantityField('จำนวนสินค้า:',
                                        product['productQuantity']),
                                    const SizedBox(height: 20),
                                    _buildTextField('รายละเอียดสินค้า:',
                                        product['productDetails']),
                                    const SizedBox(height: 20),
                                  ],
                                );
                              }).toList(),

                              // ปุ่มเพิ่มรายการสินค้าใหม่
                              Center(
                                child: ElevatedButton(
                                  onPressed: _addProductFields,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 76, 243, 112),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                  ),
                                  child: const Icon(
                                    Icons.add, // ไอคอน +
                                    size: 24, // ขนาดไอคอนที่ต้องการ
                                  ),
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ปุ่มส่งข้อมูล
                              Center(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // ตรวจสอบว่าฟิลด์ทั้งหมดถูกกรอกครบหรือไม่
                                    if (_validateFields(context)) {
                                      _submitData(); // ส่งข้อมูลถ้าข้อมูลครบ
                                    }
                                    // หาก `_validateFields` คืนค่า false จะมีการแสดงข้อความเตือนอยู่ในฟังก์ชันนั้นแล้ว
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
                              const SizedBox(
                                  height:
                                      10), // ปรับลดขนาดของ SizedBox หรือ padding ด้านล่าง
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
          if (_filteredPhones.isNotEmpty)
            Positioned(
              left: 20,
              right: 20,
              top: 310, // ปรับตำแหน่งตามต้องการ
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.all(8),
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
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
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

  void _removeProductField(int index) {
    setState(() {
      _productControllers.removeAt(
          index); // ลบรายการที่ตำแหน่ง index ออกจาก _productControllers
    });
  }

  bool _validateFields(BuildContext context) {
    // ตรวจสอบที่อยู่จัดส่ง
    if (_shippingAddressController.text.isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด', // หัวข้อ
        'กรุณากรอกที่อยู่จัดส่ง',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red, // สีพื้นหลังเป็นสีแดง
        colorText: Colors.white, // สีข้อความเป็นสีขาว
        duration: const Duration(seconds: 3), // ระยะเวลา 3 วินาที
      );
      return false; // คืนค่า false ถ้าไม่กรอกที่อยู่
    }

    // ตรวจสอบเบอร์โทรศัพท์ผู้รับ
    if (_phoneController.text.isEmpty) {
      Get.snackbar(
        'ข้อผิดพลาด', // หัวข้อ
        'กรุณากรอกเบอร์โทรศัพท์ผู้รับ',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return false; // คืนค่า false ถ้าเบอร์โทรศัพท์ผู้รับไม่กรอก
    }

    // ตรวจสอบฟิลด์ในแต่ละรายการสินค้า
    for (var product in _productControllers) {
      if (product['productName'].text.isEmpty ||
          product['productQuantity'].text.isEmpty ||
          product['productDetails'].text.isEmpty) {
        Get.snackbar(
          'ข้อผิดพลาด', // หัวข้อ
          'กรุณากรอกข้อมูลให้ครบทุกช่อง',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false; // คืนค่า false ถ้าข้อมูลไม่ครบ
      }

      // ตรวจสอบรูปภาพ
      if (product['image'] == null) {
        Get.snackbar(
          'ข้อผิดพลาด', // หัวข้อ
          'กรุณาใส่รูปภาพ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return false; // คืนค่า false ถ้าไม่มีรูปภาพ
      }
    }

    // ถ้าข้อมูลครบทุกช่องและมีรูปภาพครบทุกสินค้าคืนค่า true
    return true;
  }

  void _showImageSourceActionSheet(BuildContext context, int index) {
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
                  _pickImage(ImageSource.camera, index);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, index);
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

  void _submitData() async {
    // แสดงป็อปอัพตัวหมุน
    Get.dialog(
      Center(
        child: Card(
          elevation: 8, // ความสูงของเงา
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // มุมโค้ง
          ),
          child: Padding(
            padding: const EdgeInsets.all(24), // ระยะห่างภายใน
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor), // เปลี่ยนสีตัวหมุนตามธีม
                ),
                const SizedBox(height: 20),
                Text(
                  "กรุณารอสักครู่ ระบบกำลังเพิ่มสินค้าให้ท่าน",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // เปลี่ยนสีข้อความ
                  ),
                  textAlign: TextAlign.center, // จัดกึ่งกลางข้อความ
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // ไม่ให้ปิดป็อปอัพโดยการกดข้างนอก
    );

    String senderId = box.read('Userid'); // อ่าน senderId จาก local storage

    try {
      DocumentSnapshot senderData = await FirebaseFirestore.instance
          .collection('Users') // คอลเลกชันผู้ใช้
          .doc(senderId) // ใช้ senderId เพื่อดึงข้อมูล
          .get();

      if (senderData.exists) {
        Map<String, dynamic>? senderInfo =
            senderData.data() as Map<String, dynamic>?;
        var senderGeolocation =
            senderInfo?['gpsLocation']; // ดึง geolocation ของผู้ส่ง
        var senderAddress = senderInfo?['address']; // ดึง address ของผู้ส่ง

        log('Sender Geolocation: $senderGeolocation');
        log('Sender Address: $senderAddress');

        for (var product in _productControllers) {
          String productName = product['productName']?.text ?? '';
          String productQuantity = product['productQuantity']?.text ?? '';
          String productDetails = product['productDetails']?.text ?? '';
          File? image = product['image'];
          String phoneNumber = _phoneController.text;

          try {
            QuerySnapshot querySnapshotReceiver = await FirebaseFirestore
                .instance
                .collection('Users')
                .where('phone', isEqualTo: phoneNumber)
                .get();

            if (querySnapshotReceiver.docs.isNotEmpty) {
              String receiverId = querySnapshotReceiver.docs.first.id;
              log('Receiver ID: $receiverId');

              DocumentSnapshot receiverData = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(receiverId)
                  .get();

              if (receiverData.exists) {
                Map<String, dynamic>? receiverInfo =
                    receiverData.data() as Map<String, dynamic>?;

                // ดึงชื่อผู้รับ
                String receiverName = receiverInfo?['fullname'] ?? 'ไม่ระบุ';
                log('Receiver Name: $receiverName');

                var receiverGeolocation = receiverInfo?['gpsLocation'];
                var receiverAddress = receiverInfo?['address'];

                try {
                  String? imageUrl;
                  if (image != null) {
                    String fileName = '${const Uuid().v4()}.jpg';
                    Reference storageRef = FirebaseStorage.instance
                        .ref()
                        .child('order_images/$fileName');

                    UploadTask uploadTask = storageRef.putFile(image);
                    TaskSnapshot snapshot =
                        await uploadTask.whenComplete(() {});
                    imageUrl = await snapshot.ref.getDownloadURL();
                    log('อัพโหลดรูปภาพสำเร็จ: $imageUrl');
                  }

                  DocumentReference orderRef = await FirebaseFirestore.instance
                      .collection('orders')
                      .add({
                    'senderId': senderId,
                    'receiverId': receiverId,
                    'status': '1',
                    'Photopickup': null,
                    'senderPhoto': null,
                    'deliveredPhoto': null,
                    'riderId': '',
                    'pickupAddress': senderAddress,
                    'pickupLocation': senderGeolocation,
                    'deliveryAddress': receiverAddress,
                    'deliveryLocation': receiverGeolocation,
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                    'type': 'sender', // กำหนด type เป็น sender
                  });

                  String orderId = orderRef.id;
                  log('บันทึกคำสั่งซื้อสำเร็จ, Order ID: $orderId');

                  DocumentReference orderItemsRef = await FirebaseFirestore
                      .instance
                      .collection('orderItems')
                      .add({
                    'orderId': orderId,
                    'Photos': imageUrl ?? '',
                    'name': productName,
                    'description': productDetails,
                    'quantity': int.tryParse(productQuantity) ?? 1,
                    'receiverName': receiverName,
                    'type': 'receiver', // กำหนด type เป็น receiver
                  });

                  log('บันทึก orderItems สำเร็จ, Order Item ID: ${orderItemsRef.id}');
                } catch (e) {
                  log('เกิดข้อผิดพลาดในการบันทึกคำสั่งซื้อหรือ orderItems: $e');
                }
              }
            } else {
              log('ไม่พบผู้ใช้ที่มีหมายเลขโทรศัพท์: $phoneNumber');
            }
          } catch (e) {
            log('เกิดข้อผิดพลาดในการค้นหา receiverId หรือ geolocation: $e');
          }

          log('ชื่อสินค้า: $productName');
          log('จำนวนสินค้า: $productQuantity');
          log('รายละเอียดสินค้า: $productDetails');
          log('เบอร์โทรศัพท์: $phoneNumber');
          log('ที่อยู่: ${_shippingAddressController.text}');
          log('รูปภาพ: ${image?.path}');
        }
        Get.back(); // ปิดป็อปอัพหลังจากการทำงานเสร็จ
        Get.to(() => const HomeUserpage(),
            transition: Transition.rightToLeftWithFade,
            duration: const Duration(milliseconds: 300));
      } else {
        log('ไม่พบข้อมูลผู้ใช้ที่มี Sender ID: $senderId');
      }
    } catch (e) {
      log('เกิดข้อผิดพลาดในการดึงข้อมูล sender: $e');
    }
  }
}
