import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickrider/page/PageRider/RiderService.dart';
import 'package:quickrider/page/PageRider/widgetRider.dart';
import 'package:quickrider/page/PageUser/SharedWidget.dart';

class JobdscriptionriderPage extends StatefulWidget {
  const JobdscriptionriderPage({super.key});

  @override
  State<JobdscriptionriderPage> createState() => _JobdscriptionriderPageState();
}

class _JobdscriptionriderPageState extends State<JobdscriptionriderPage> {
  final riderService = Get.find<RiderService>();

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
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back,
                                        color: Colors.black),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const Expanded(
                                    child: Center(
                                      child: Text(
                                        'รายละเอียดออเดอร์',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Image.network(
                                    'https://winedailybkk.com/wp-content/uploads/2021/12/JOHNNIE-WALKER-Black-Label-1-L.jpg',
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ชื่อสินค้า : น้ำพิเศษ',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'จำนวน : 100 x',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'รายละเอียดสินค้า : น้ำพิเศษทำจากป่าอเมซอลที่กลั่นมาจากน้ำลายของไดโนเสาร์เอาไปหลอมที่นรกเอาไปผสมยาแก้ปวด ยาแก้มะเร็ง ยาแก้เอ๋อ ยาแก้ไอ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft, // จัดแนวชิดซ้าย
                                child: Text(
                                  'รับออเดอร์จาก:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft, // จัดแนวชิดซ้าย
                                child: Text(
                                  'คุณ: อัครผล\n'
                                  'ที่อยู่: 999 หมู่ 99 บ้านใหญ่จุ๊ย\n'
                                  'เบอร์โทร: 0999636933',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Divider(),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft, // จัดแนวชิดซ้าย
                                child: Text(
                                  'จัดส่งคุณ:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment:
                                    Alignment.centerLeft, // จัดแนวชิดซ้าย
                                child: Text(
                                  'คุณ: ชัชวาล\n'
                                  'ที่อยู่: 555 หมู่ 55 บ้านเล็กน้อย\n'
                                  'เบอร์โทร: 0963214568',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 18, 172, 82),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'รับงาน',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
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
    );
  }
}
