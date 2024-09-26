class User {
  final String date;
  final double latitude;
  final double longitude;
  final String password;
  final String img;
  final String address;
  final String phone;
  final String fullname;
  final String type;
  final String email;

  User({
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.password,
    required this.img,
    required this.address,
    required this.phone,
    required this.fullname,
    required this.type,
    required this.email,
  });

  // ฟังก์ชันสำหรับสร้าง User จาก Map
  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      date: data['date'],
      latitude: data['gpsLocation']['latitude'],
      longitude: data['gpsLocation']['longitude'],
      password: data['password'],
      img: data['img'],
      address: data['address'],
      phone: data['phone'],
      fullname: data['fullname'],
      type: data['type'],
      email: data['email'],
    );
  }

  // ฟังก์ชันเพื่อแสดงข้อมูล
  @override
  String toString() {
    return 'User(fullname: $fullname, email: $email, phone: $phone, address: $address, img: $img)';
  }
}
