import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:face_detection_rnd/page/face_auth/face_auth_db.dart';
import 'package:face_detection_rnd/page/face_auth/face_auth_utils.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import 'user_dto.dart';

class FaceAuthMLService {
  late Interpreter interpreter;
  List? predictedArray;

  Future<UserDto?> predict(
      File imageFile, Face face, bool loginUser, String name) async {
    List input = await _preProcess(imageFile, face);
    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    await initializeInterpreter();

    interpreter.run(input, output);
    output = output.reshape([192]);

    predictedArray = List.from(output);

    if (!loginUser) {
      final newUser = UserDto(name: name, faceData: predictedArray!);
      FaceAuthDB.addNewUser(newUser: newUser);
      return newUser;
    } else {
      List<UserDto> users = await FaceAuthDB.getUsersData();

      for (var user in users) {
        List userArray = user.faceData ?? [];
        int minDist = 999;
        double threshold = 1;
        var dist = euclideanDistance(predictedArray!, userArray);

        print(dist);
      }

      return null;

      // if (dist <= threshold && dist < minDist) {
      //   return user;
      // } else {
      //   return null;
      // }
    }
  }

  // euclideanDistance(List l1, List l2) {
  //   double sum = 0;
  //   for (int i = 0; i < l1.length; i++) {
  //     sum += pow((l1[i] - l2[i]), 2);
  //   }

  //   return pow(sum, 0.5);
  // }

  euclideanDistance(List l1, List l2) {
    var sum = 0.0;
    for (int i = 0; i < l1.length; i++) {
      sum += pow((l1[i] - l2[i]).abs(), 2);
    }

    return sqrt(sum);
  }

  initializeInterpreter() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
          isPrecisionLossAllowed: false,
          // experimentalFlags: ,
          // inferencePreference: 0,
          // inferencePriority1: 1,
          // inferencePriority2: 2,
          // inferencePriority3: 3,
        ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
            allowPrecisionLoss: true,
            // waitType: 0,
          ),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      print('$e');
    }
  }

  Future<List> _preProcess(File image, Face faceDetected) async {
    imglib.Image croppedImage = await _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, size: 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  Future<imglib.Image> _cropFace(File image, Face faceDetected) async {
    imglib.Image convertedImage = await _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(convertedImage,
        x: x.round(), y: y.round(), width: w.round(), height: h.round());
  }

  Future<imglib.Image> _convertCameraImage(File image) async {
    var img = await convertToImage(image);
    var img1 = imglib.copyRotate(img!, angle: -90);
    return img1;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    int inputSize = image.width;
    double mean = 127.5;
    double std = 127.5;
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r - mean) / std;
        buffer[pixelIndex++] = (pixel.g - mean) / std;
        buffer[pixelIndex++] = (pixel.b - mean) / std;
      }
    }

    return convertedBytes.buffer.asFloat32List();
    // var convertedBytes = Float32List(1 * 112 * 112 * 3);
    // var buffer = Float32List.view(convertedBytes.buffer);
    // int pixelIndex = 0;

    // for (var i = 0; i < 112; i++) {
    //   for (var j = 0; j < 112; j++) {
    //     var pixel = image.getPixel(j, i);
    //     buffer[pixelIndex++] = ((imglib.uint32ToRed(pixel.x) - 128) +
    //             (imglib.uint32ToRed(pixel.y) - 128)) /
    //         128;
    //     buffer[pixelIndex++] = ((imglib.uint32ToGreen(pixel.x) - 128) +
    //             (imglib.uint32ToGreen(pixel.x) - 128)) /
    //         128;
    //     buffer[pixelIndex++] = ((imglib.uint32ToBlue(pixel.x) - 128) +
    //             (imglib.uint32ToBlue(pixel.y) - 128)) /
    //         128;
    //   }
    // }
    // return convertedBytes.buffer.asFloat32List();
  }
}
