import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<String> getQrCode(String data) async {
  final image = await QrPainter(
    data: data,
    version: QrVersions.auto,
    gapless: false,
    color: Colors.black,
    emptyColor: Colors.white,
  ).toImageData(200.0); // Generate QR code image data

  const filename = 'qr_code.png';
  final tempDir = await getTemporaryDirectory(); // Get temporary directory to store the generated image
  final file = await File('${tempDir.path}/$filename').create(); // Create a file to store the generated image
  var bytes = image!.buffer.asUint8List(); // Get the image bytes
  await file.writeAsBytes(bytes); // Write the image bytes to the file
  return file.path;
}

bool checkFileExist(String s) {
  //check if the image file exists
  File file = File(s);
  return file.existsSync();
  //    Image.file(File(s))
}

Future<String?> pickAnImage(ImagePicker picker, ImageSource source, String folderName) async {
  final pickedFile = await picker.pickImage(
    source: source,
    imageQuality: 50,
  );

  if (pickedFile == null) {
    return null;
  }

  //copy image to app directory
  String cow = await createFolder(folderName);
  File file = File(pickedFile!.path);
  String fileName = basename(file.path);
  File newImage = await file.copy('$cow/$fileName');
  return newImage.path;
}

Future<String> createFolder(String cow) async {
  final dir = Directory('${(Platform.isAndroid
      ? await getExternalStorageDirectory() //FOR ANDROID
      : await getApplicationSupportDirectory() //FOR IOS
  )!
      .path}/$cow');
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
  if ((await dir.exists())) {
    return dir.path;
  } else {
    dir.create();
    return dir.path;
  }
}