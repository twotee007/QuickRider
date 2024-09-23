import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
// import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:quickrider/config/shared/appData.dart';
import 'package:quickrider/firebase_options.dart';
import 'package:quickrider/page/Login.dart';

void main() async {
  // Connect firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //connect fireStore
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await GetStorage.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppData()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      home: Login(),
    );
  }
}
