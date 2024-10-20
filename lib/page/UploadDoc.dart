import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/page/PageRider/HomeRider.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';
import 'package:quickrider/page/PageUser/UserService.dart';
import 'package:quickrider/page/login.dart';
import 'package:uuid/uuid.dart';

class UploadDocumentsPage extends StatefulWidget {
  const UploadDocumentsPage({super.key});

  @override
  State<UploadDocumentsPage> createState() => _UploadDocumentsPageState();
}

class _UploadDocumentsPageState extends State<UploadDocumentsPage> {
  String fullname = '';
  String email = '';
  String password = '';
  String phone = '';
  String date = '';
  String estate = '';
  String registration = '';
  String type = '';
  bool isUploading = false; // ตัวแปรสำหรับการตรวจสอบสถานะการอัปโหลด
  final box = GetStorage();
  double? latitude; // เก็บ latitude เป็น double?
  double? longitude; // เก็บ longitude เป็น double?
  final ImagePicker picker = ImagePicker();
  File? imageFile; // ตัวแปรสำหรับเก็บไฟล์รูปภาพที่เลือก

  @override
  void initState() {
    super.initState();
    fullname = context.read<AppData>().fullname;
    email = context.read<AppData>().email;
    password = context.read<AppData>().password;
    phone = context.read<AppData>().phone;
    date = context.read<AppData>().date;
    type = context.read<AppData>().type;
    if (type == 'user') {
      estate = context.read<AppData>().estate;
      latitude = context.read<AppData>().latitude;
      longitude = context.read<AppData>().longitude;
    } else {
      registration = context.read<AppData>().registration;
      latitude = context.read<AppData>().latitude;
      longitude = context.read<AppData>().longitude;
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
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(17.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      const Text(
                        'Quick Ride',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Upload Documents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF412160),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                                : const Icon(
                                    Icons.person_add_alt_1,
                                    color: Color(0xFF412160),
                                    size: 50,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: isUploading
                              ? null
                              : () {
                                  uploadusersToFirebase();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF412160),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()),
                                );
                              },
                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF412160),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> uploadusersToFirebase() async {
    final userService = Get.find<UserService>();
    if (imageFile != null) {
      setState(() {
        isUploading = true; // เริ่มการอัปโหลด
      });
      try {
        String fileName = 'images/${const Uuid().v4()}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageReference.putFile(imageFile!);
        await uploadTask.whenComplete(() async {
          String downloadURL = await storageReference.getDownloadURL();
          Map<String, dynamic> userData = {
            'phone': phone,
            'password': password,
            'date': date,
            'email': email,
            'fullname': fullname,
            'img': downloadURL,
            'type': type,
          };
          if (type == 'user') {
            userData.addAll({
              'gpsLocation': {'latitude': latitude, 'longitude': longitude},
              'address': estate,
            });
          } else {
            userData.addAll({
              'currentJob': '0',
              'gpsLocation': {'latitude': latitude, 'longitude': longitude},
              'registration': registration,
            });
          }
          DocumentReference docRef = await FirebaseFirestore.instance
              .collection('Users')
              .add(userData);
          String docId = docRef.id; // ดึง docID จาก DocumentReference
          if (type == 'user') {
            userService.updateUserData(
              fullname: fullname,
              imgUrl: downloadURL, // อัปเดตด้วย URL ของภาพ
            );
            box.write('isLoggedIn', true);
            box.write('Userid', docId);
            Get.to(() => const HomeUserpage(),
                transition: Transition.cupertino, // Specify the transition here
                duration: const Duration(milliseconds: 300));
          } else {
            userService.updateUserData(
              fullname: fullname,
              imgUrl: downloadURL, // อัปเดตด้วย URL ของภาพ
            );
            box.write('isLoggedIn', true);
            box.write('Riderid', docId);
            Get.to(() => const HomeRiderPage(),
                transition: Transition.cupertino, // Specify the transition here
                duration: const Duration(milliseconds: 300));
          }
        });
      } catch (e) {
        log('Error uploading image: $e');
      } finally {
        setState(() {
          isUploading = false; // อัปโหลดเสร็จแล้ว
        });
      }
    } else {
      log('No image selected');
    }
  }
}
