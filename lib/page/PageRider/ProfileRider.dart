import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickrider/page/ChangePage/NavigationBarRider.dart';
import 'package:quickrider/page/Login.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';

class ProfilePageRider extends StatefulWidget {
  const ProfilePageRider({super.key});

  @override
  State<ProfilePageRider> createState() => _ProfilePageRiderState();
}

class _ProfilePageRiderState extends State<ProfilePageRider>
    with TickerProviderStateMixin {
  late Map<String, dynamic>? user;
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final riderService = Get.find<RiderService>();
  File? _imageFile;

  // Function to mask the password
  String _maskPassword(String password) {
    if (password.length <= 3) {
      return password; // Return as is if length <= 3
    }
    return password.substring(0, 3) + '*' * (password.length - 3);
  }

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

  // Function to show edit profile dialog
  void _showEditProfileDialog() {
    final TextEditingController nameController =
        TextEditingController(text: riderService.name);
    final TextEditingController emailController =
        TextEditingController(text: riderService.email);
    final TextEditingController phoneController =
        TextEditingController(text: riderService.phone);
    final TextEditingController dateController =
        TextEditingController(text: riderService.date);
    final TextEditingController addressController =
        TextEditingController(text: riderService.registration);
    final TextEditingController passwordController =
        TextEditingController(text: riderService.password);

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
                                    : (riderService.url.isNotEmpty
                                        ? NetworkImage(riderService.url)
                                        : const AssetImage(
                                                'assets/img/default_profile.png')
                                            as ImageProvider),
                              ),
                            ),
                            const SizedBox(height: 15),
                            _buildTextFieldEdit(
                              label: 'Fullname',
                              controller: nameController,
                            ),
                            _buildTextFieldEdit(
                              label: 'Email',
                              controller: emailController,
                            ),
                            _buildTextFieldEdit(
                              label: 'Phone',
                              controller: phoneController,
                            ),
                            _buildTextFieldEdit(
                              label: 'Date of birth',
                              controller: dateController,
                            ),
                            _buildTextFieldEdit(
                              label: 'Estate & City',
                              controller: addressController,
                            ),
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
                        // Update user service
                        riderService.rider.updateAll((key, value) {
                          if (key == 'fullname') return nameController.text;
                          if (key == 'email') return emailController.text;
                          if (key == 'phone') return phoneController.text;
                          if (key == 'date') return dateController.text;
                          if (key == 'address') return addressController.text;
                          if (key == 'password') return passwordController.text;
                          return value;
                        });
                        Navigator.of(context).pop();
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
                        riderService.password) // Mask password for view only
                    : riderService.password, // Show full password in edit mode
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
            child: cycletopri(
              riderService.name,
              riderService.url,
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
                              backgroundImage: riderService.url.isNotEmpty
                                  ? NetworkImage(riderService.url)
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
                              controller: TextEditingController(
                                  text: riderService.name),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Email",
                              controller: TextEditingController(
                                  text: riderService.email),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Phone",
                              controller: TextEditingController(
                                  text: riderService.phone),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Date of birth",
                              controller: TextEditingController(
                                  text: riderService.date),
                              isEditable: false,
                            ),
                            _buildTextField(
                              label: "Estate & City",
                              controller: TextEditingController(
                                  text: riderService.registration),
                              isEditable: false,
                            ),
                            // Password field displaying masked password
                            _buildTextField(
                              label: "Password",
                              controller: TextEditingController(
                                  text: _maskPassword(riderService.password)),
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
      bottomNavigationBar: CustomBottomNavigationBarRider(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
