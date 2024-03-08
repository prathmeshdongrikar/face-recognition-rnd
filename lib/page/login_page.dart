import 'package:flutter/material.dart';

import '../utils/local_db.dart';
import '../utils/utils.dart';
import 'face_recognition/camera_page.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'face_recognition/helpers.dart';
import 'face_recognition/ml_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FaceDetector _faceDetector;
  final MLService _mlService = MLService();
  List<Face> facesDetected = [];

  @override
  void initState() {
    printIfDebug(LocalDB.getUser().name);
    _faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    super.initState();
  }

  Future<void> detectFacesFromImage() async {
    final file = await Helpers.getImageFileFromAssets('pd.png');

    final firebaseVisionImage = InputImage.fromFile(file);

    var result = await _faceDetector.processImage(firebaseVisionImage);
    if (result.isNotEmpty) {
      facesDetected = result;
      return;
    }

    // for (var plane in image.planes) {
    //   InputImageMetadata firebaseImageMetadata = InputImageMetadata(
    //     bytesPerRow: plane.bytesPerRow,
    //     rotation: InputImageRotation.rotation270deg,
    //     format: InputImageFormat.bgra8888,
    //     size: plane.width != null && plane.height != null
    //         ? Size(plane.width!.toDouble(), plane.height!.toDouble())
    //         : const Size(150,150),
    //   );

    //   InputImage firebaseVisionImage = InputImage.fromBytes(
    //     bytes: image.planes.first.bytes,
    //     metadata: firebaseImageMetadata,
    //   );
    //   var result = await _faceDetector.processImage(firebaseVisionImage);
    //   if (result.isNotEmpty) {
    //     facesDetected = result;
    //     return;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Face Authentication"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(
                  text: 'Register',
                  icon: Icons.app_registration_rounded,
                  onClicked: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FaceScanScreen()));
                  },
                ),
                const SizedBox(height: 24),
                buildButton(
                  text: 'Detect',
                  icon: Icons.app_registration_rounded,
                  onClicked: () async {
                  await  detectFacesFromImage();
                  },
                ),
                const SizedBox(height: 24),
                buildButton(
                  text: 'Login',
                  icon: Icons.login,
                  onClicked: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FaceScanScreen(
                                  user: LocalDB.getUser(),
                                )));
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );
}
