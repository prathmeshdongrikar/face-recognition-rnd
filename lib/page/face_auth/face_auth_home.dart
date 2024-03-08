import 'package:face_detection_rnd/page/face_auth/face_auth_login.dart';
import 'package:flutter/material.dart';

import 'user_dto.dart';
class FaceAuthHome extends StatefulWidget {
  final UserDto user;
  const FaceAuthHome({super.key, required this.user});

  @override
  State<FaceAuthHome> createState() => _FaceAuthHomeState();
}

class _FaceAuthHomeState extends State<FaceAuthHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Text('hello ${widget.user.name} 👋🏻'),
    

           ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                    return const FaceAuthLogin();
                  }),(route) => false,);
                },
                child: const Text('Logout')),
        ],
      ),
    );
  }
}