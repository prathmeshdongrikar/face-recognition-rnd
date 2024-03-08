import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_camera.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_login.dart';
import 'package:face_detection_rnd/page/face_auth/user_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  final Directory appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  Hive.registerAdapter(UserDtoAdapter());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Face Auth",
        // home: FaceDetectionFromImage(title: 'Detect Face',),
        // home: LoginPage(),
        // my version below
        home: FaceAuthLogin(),
      );
}
