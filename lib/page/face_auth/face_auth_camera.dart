// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_home.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_ml_service.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';

List<CameraDescription>? cameras;

class FaceAuthCamera extends StatefulWidget {
  final bool isLogin;
  const FaceAuthCamera({
    super.key,
    this.isLogin = false,
  });

  @override
  State<FaceAuthCamera> createState() => _FaceAuthCameraState();
}

class _FaceAuthCameraState extends State<FaceAuthCamera> {
  TextEditingController controller = TextEditingController();
  late CameraController _cameraController;
  bool flash = false;
  bool isControllerInitialized = false;
  late FaceDetector _faceDetector;
  final FaceAuthMLService _mlService = FaceAuthMLService();
  List<Face> facesDetected = [];

  Future initializeCamera() async {
    await _cameraController.initialize();
    isControllerInitialized = true;
    _cameraController.setFlashMode(FlashMode.off);
    setState(() {});
  }

  Future<void> takePicture() async {
    XFile file = await _cameraController.takePicture();
    file = XFile(file.path);
    _cameraController.setFlashMode(FlashMode.off);
    final InputImage inputImage = InputImage.fromFile(File(file.path));

    final List<Face> faces = await _faceDetector.processImage(inputImage);
    if (faces.isNotEmpty) {
      final data = await _mlService.predict(
          File(file.path), faces[0], widget.isLogin, controller.text.trim());

      if (widget.isLogin && data != null) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return FaceAuthHome(
            user: data,
          );
        }), (route) => false);
      } else if (data != null) {
        Navigator.of(context).pop();
      } else {
       print('something went wrong!');
      }
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              const AlertDialog(content: Text('No face detected!')));
    }
  }

  @override
  void initState() {
    _cameraController =
        CameraController(cameras![1], ResolutionPreset.ultraHigh);
    initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: isControllerInitialized
                  ? CameraPreview(_cameraController)
                  : null),
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Lottie.asset("assets/loading.json",
                      width: MediaQuery.of(context).size.width * 0.7),
                ),
              ),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                    fillColor: Colors.white, filled: true),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 30,
                  ),

                  Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          // on capture image
                          takePicture();
                        },
                        child: const Text(
                          'Capture Face',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  //   IconButton(
                  //       icon: Icon(
                  //         flash ? Icons.flash_on : Icons.flash_off,
                  //         color: Colors.white,
                  //         size: 30,
                  //       ),
                  //       onPressed: () {
                  //         setState(() {
                  //           flash = !flash;
                  //         });
                  //         flash
                  //             ? _cameraController
                  //                 .setFlashMode(FlashMode.torch)
                  //             : _cameraController.setFlashMode(FlashMode.off);
                  //       }),
                  //  const SizedBox(width: 30,),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
