import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

Future pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();
  XFile? _file = await imagePicker.pickImage(source: source);
  _file = await _cropImage(imageFile: _file!);
  if (_file != null) {
    return await _file.readAsBytes();
  } else {
    print("No Image selected");
  }
}

Future<XFile?> _cropImage({required XFile imageFile}) async {
  CroppedFile? croppedImage =
      await ImageCropper().cropImage(sourcePath: imageFile.path);
  if (croppedImage == null) return null;
  return XFile(croppedImage.path);
}
