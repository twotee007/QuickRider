import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/ChangePage/NavigationBarUser.dart';
import 'package:quickrider/page/Login.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';
import 'package:quickrider/page/PageUser/UserService.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePageUser extends StatefulWidget {
  const ProfilePageUser({super.key});

  @override
  State<ProfilePageUser> createState() => _ProfilePageUserState();
}

class _ProfilePageUserState extends State<ProfilePageUser> {
  final userService = Get.find<UserService>();
  File? _imageFile;
  String downloadUrl = '';

  // Function to mask the password
  String _maskPassword(String password) {
    if (password.length <= 3) {
      return password; // Return as is if length <= 3
    }
    return password.substring(0, 3) + '*' * (password.length - 3);
  }

  // Function for selecting an image from Gallery
  // Function for selecting an image from Gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(XFile pickedFile) async {
    try {
      // Create a reference to Firebase Storage
      final storageRef =
          FirebaseStorage.instance.ref().child('images/${pickedFile.name}');

      // Upload the file
      await storageRef.putFile(File(pickedFile.path));

      // Get the download URL
      downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl; // Return the download URL
    } catch (e) {
      print('Error uploading image: $e');
      return null; // Return null if there was an error
    }
  }

  // Function to show edit profile dialog
  void _showEditProfileDialog() {
    final TextEditingController nameController =
        TextEditingController(text: userService.name);
    final TextEditingController emailController =
        TextEditingController(text: userService.email);
    final TextEditingController phoneController =
        TextEditingController(text: userService.phone);
    final TextEditingController dateController =
        TextEditingController(text: userService.date);
    final TextEditingController addressController =
        TextEditingController(text: userService.address);
    final TextEditingController passwordController =
        TextEditingController(text: userService.password);

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
                            InkWell(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _imageFile != null
                                    ? FileImage(_imageFile!)
                                    : (userService.url.isNotEmpty
                                        ? NetworkImage(userService.url)
                                        : const AssetImage(
                                                'assets/url/default_profile.png')
                                            as ImageProvider),
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
                      onPressed: () async {
                        // อัปโหลดภาพถ้ามี
                        String? imgUrl;
                        if (_imageFile != null) {
                          imgUrl = await _uploadImageToFirebase(
                              XFile(_imageFile!.path));
                        }

                        // อัปเดตข้อมูลผู้ใช้
                        userService
                            .updateUserData(
                          fullname: nameController.text,
                          email: emailController.text,
                          phone: phoneController.text,
                          date: dateController.text,
                          address: addressController.text,
                          password: passwordController.text,
                          imgUrl: downloadUrl, // อัปเดตด้วย URL ของภาพ
                        )
                            .then((_) {
                          // ปิด dialog หลังจากอัปเดตข้อมูลเสร็จ
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          // แสดงข้อความแจ้งเตือนหากเกิดข้อผิดพลาด
                          print('Error updating profile: $error');
                        });
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
                    ? _maskPassword(
                        userService.password) // Mask password for view only
                    : userService.password, // Show full password in edit mode
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
              userService.name,
              userService.url,
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
                              backgroundImage: userService.url.isNotEmpty
                                  ? NetworkImage(userService.url)
                                  : const AssetImage(
                                          'assets/images/default_profile.png')
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
                              controller:
                                  TextEditingController(text: userService.name),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Email",
                              controller: TextEditingController(
                                  text: userService.email),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Phone",
                              controller: TextEditingController(
                                  text: userService.phone),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Date of birth",
                              controller:
                                  TextEditingController(text: userService.date),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Estate & City",
                              controller: TextEditingController(
                                  text: userService.address),
                              isEditable: false,
                            ),
                            // Password field displaying masked password
                            _buildTextField(
                              label: "Password",
                              controller: TextEditingController(
                                  text: _maskPassword(userService.password)),
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
            // Update selected navigation bar
          });
        },
      ),
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
