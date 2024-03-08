import 'dart:io';

import 'package:image/image.dart' as img_lib;


Future<img_lib.Image?> convertToImage(File file) async {
  try {
    final bytes = await file.readAsBytes();
    final img_lib.Image? image = img_lib.decodeImage(bytes);

    return image;
  } catch (e) {
      print(e);
  }
  return null;
}
