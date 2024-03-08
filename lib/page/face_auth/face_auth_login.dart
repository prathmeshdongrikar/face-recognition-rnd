import 'package:face_detection_rnd/page/face_auth/face_auth_camera.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_db.dart';
import 'package:flutter/material.dart';

import 'user_dto.dart';

class FaceAuthLogin extends StatefulWidget {
  const FaceAuthLogin({super.key});

  @override
  State<FaceAuthLogin> createState() => _FaceAuthLoginState();
}

class _FaceAuthLoginState extends State<FaceAuthLogin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Auth'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const FaceAuthCamera();
                  }));
                },
                child: const Text('Register')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const FaceAuthCamera(
                      isLogin: true,
                    );
                  }));
                },
                child: const Text('Login'))
          ],
        ),
      ),
    );
  }
}
