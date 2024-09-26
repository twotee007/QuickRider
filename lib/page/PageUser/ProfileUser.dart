import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/Login.dart';
import 'package:quickrider/page/PageUser/HomeUser.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfilePageUser extends StatefulWidget {
  const ProfilePageUser({super.key});

  @override
  State<ProfilePageUser> createState() => _ProfilePageUserState();
}

class _ProfilePageUserState extends State<ProfilePageUser> {
  final userService = Get.find<UserService>();
  final ImagePicker picker = ImagePicker();
  File? imageFile; // ตัวแปรสำหรับเก็บไฟล์รูปภาพที่เลือก
  bool isUploading = false; // ตัวแปรสำหรับการตรวจสอบสถานะการอัปโหลด
  late Map<String, dynamic>? user;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  StreamSubscription? listener;
  // Function to mask the password
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController dateController;
  late TextEditingController addressController;
  late TextEditingController passwordController;
  String name = '';
  String email = '';
  String date = '';
  String phone = '';
  String address = '';
  String password = '';
  String url = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dateController = TextEditingController();
    addressController = TextEditingController();
    passwordController = TextEditingController();
    startRealtimeGet();
  }

  final box = GetStorage();
  String _maskPassword(String password) {
    if (password.length <= 3) {
      return password; // Return as is if length <= 3
    }
    return password.substring(0, 3) + '*' * (password.length - 3);
  }

  Future<void> _pickImage(ImageSource source, StateSetter setState) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path); // อัปเดตรูปภาพในสถานะ
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context, StateSetter setState) {
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
                  _pickImage(ImageSource.camera, setState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, setState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show edit profile dialog
  void _showEditProfileDialog() {
    bool isPasswordVisible = false; // ใช้สถานะภายใน popup dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('แก้ไขโปรไฟล์',
                            style: GoogleFonts.poppins(fontSize: 18)),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showImageSourceActionSheet(context, setState);
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
                                    : ClipOval(
                                        child: Image.network(
                                          url,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildTextFieldEdit(
                                label: 'Fullname', controller: nameController),
                            _buildTextFieldEdit(
                                label: 'Email', controller: emailController),
                            _buildTextFieldEdit(
                                label: 'Phone', controller: phoneController),
                            _buildTextFieldEdit(
                                label: 'Date of birth',
                                controller: dateController),
                            _buildTextFieldEdit(
                                label: 'Estate & City',
                                controller: addressController),
                            _buildTextFieldEdit(
                              label: "Password",
                              controller: passwordController,
                              isPasswordVisible: isPasswordVisible,
                              togglePasswordVisibility: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        uploadUsersToFirebase();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldEdit({
    required String label,
    TextEditingController? controller,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
  }) {
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
          obscureText: label == "Password" ? !isPasswordVisible : false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            suffixIcon: label == "Password"
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF412160),
                    ),
                    onPressed: togglePasswordVisibility,
                  )
                : null,
            isDense: true,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Function to build TextField widget
  Widget _buildTextField({
    required String label,
    TextEditingController? controller,
    bool isEditable = false,
  }) {
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
          readOnly: !isEditable,
          // Always obscure for password
          controller: controller ??
              TextEditingController(
                text: !isEditable && label == "Password"
                    ? _maskPassword(password) // Mask password for view only
                    : password, // Show full password in edit mode
              ),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            isDense: true,
          ),
        ),
        const SizedBox(height: 15),
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
              name,
              url,
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
                      width: MediaQuery.of(context).size.width * 1,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: url.isNotEmpty
                                  ? NetworkImage(url)
                                  : const AssetImage(
                                          'assets/img/default_profile.png')
                                      as ImageProvider,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _showEditProfileDialog,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF412160),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'แก้ไขโปรไฟล์',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Display user data
                            _buildTextField(
                              label: "Fullname",
                              controller: nameController,
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Email",
                              controller: emailController,
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Phone",
                              controller: phoneController,
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Date of birth",
                              controller: dateController,
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Estate & City",
                              controller: addressController,
                              isEditable: false,
                            ),
                            // Password field displaying masked password
                            _buildTextField(
                              label: "Password",
                              controller: passwordController,
                              isEditable: false,
                            ),
                            const SizedBox(height: 30),
                            Center(
                              child: ElevatedButton(
                                onPressed: _logout,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'ออกจากระบบ',
                                  style: GoogleFonts.poppins(
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          setState(() {
            listener!.cancel();
            log('cencle');
          });
        },
      ),
    );
  }

  String dowurl = '';
  Future<void> uploadUsersToFirebase() async {
    String userid = box.read('Userid');
    String currentImageUrl =
        url; // Assuming userService.url has the current image URL
    if (imageFile != null) {
      setState(() {
        isUploading = true; // เริ่มการอัปโหลด
      });
      try {
        if (currentImageUrl.isNotEmpty) {
          Reference storageReference =
              FirebaseStorage.instance.refFromURL(currentImageUrl);
          await storageReference.delete();
          log('Existing image deleted: $currentImageUrl');
        }
        String fileName = 'images/${const Uuid().v4()}.jpg';
        Reference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageReference.putFile(imageFile!);

        await uploadTask.whenComplete(() async {
          String downloadURL = await storageReference.getDownloadURL();

          log('ไม่ null');

          Map<String, dynamic> userData = {
            'fullname': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'date': dateController.text,
            'address': addressController.text,
            'password': passwordController.text,
            'img': downloadURL, // เพิ่ม URL ของภาพที่อัปโหลด
          };
          await db.collection('Users').doc(userid).update(userData);
          dowurl = downloadURL;
        });
      } catch (e) {
        log('Error uploading image: $e');
      } finally {
        userService.updateUserData(
          fullname: nameController.text,

          imgUrl: dowurl, // อัปเดตด้วย URL ของภาพ
        );
        Get.back();
        setState(() {
          isUploading = false; // อัปโหลดเสร็จแล้ว
        });
      }
    } else {
      setState(() {
        isUploading = true; // เริ่มการอัปโหลด
      });
      Map<String, dynamic> userData = {
        'fullname': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'date': dateController.text,
        'address': addressController.text,
        'password': passwordController.text,
      };
      await db.collection('Users').doc(userid).update(userData);
      userService.updateUserData(
        fullname: nameController.text,
        imgUrl: dowurl, // อัปเดตด้วย URL ของภาพ
      );
      Get.back();
      setState(() {
        isUploading = false; // เริ่มการอัปโหลด
      });
    }
  }

  void startRealtimeGet() {
    String userid = box.read('Userid');
    final collectionRef = db.collection('Users').doc(userid);

    listener = collectionRef.snapshots().listen(
      (documentSnapshot) {
        if (documentSnapshot.exists) {
          var data = documentSnapshot.data();

          // Use setState to update UI
          setState(() {
            nameController.text = data!['fullname'].toString();
            emailController.text = data['email'].toString();
            phoneController.text = data['phone'].toString();
            dateController.text = data['date'].toString();
            addressController.text = data['address'].toString();
            passwordController.text = _maskPassword(
                data['password'].toString()); // Mask the password here
            name = data['fullname'].toString();
            password = data['password'].toString();
            url = data['img'].toString(); // Update the URL if needed
          });

          log('Start Real Time'); // You can log the name here
        } else {
          log("Document does not exist");
        }
      },
      onError: (error) => log("Listen failed: $error"),
    );
  }

  void _logout() {
    final box = GetStorage();
    box.remove('isLoggedIn');
    box.remove('Userid');
    box.remove('Riderid');
    Get.off(() => const Login());
  }
}
