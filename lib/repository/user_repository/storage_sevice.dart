import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class Storage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  DocumentReference documentReference =
      FirebaseFirestore.instance.collection("Users").doc();
  Future<void> uploadImage(
    String imagePath,
    String imageName,
  ) async {
    File image = File(imagePath);
    try {
      await storage.ref("paymentScreenshot/$imageName").putFile(image);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> uploadProfileMedia(
    String imagePath,
    String imageName,
  ) async {
    File image = File(imagePath);
    try {
      await storage.ref("profileMedia/$imageName").putFile(image);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> uploadProfilePhoto(
    String imagePath,
    String imageName,
  ) async {
    File image = File(imagePath);
    try {
      await storage.ref("profilePhotos/$imageName").putFile(image);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> uploadAdminMedia(
    String imagePath,
    String imageName,
  ) async {
    File image = File(imagePath);
    try {
      await storage.ref("adminMedia/$imageName").putFile(image);
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  Future<firebase_storage.ListResult> listImages() async {
    firebase_storage.ListResult result =
        await storage.ref("paymentScreenshot").listAll();
    result.items.forEach((firebase_storage.Reference ref) {});
    return result;
  }

  Future<firebase_storage.ListResult> listProfileMedia() async {
    firebase_storage.ListResult result =
        await storage.ref("profileMedia").listAll();
    result.items.forEach((firebase_storage.Reference ref) {});
    return result;
  }

  Future<String> downloadImage(String imageName) async {
    String downloadUrl =
        await storage.ref("paymentScreenshot/$imageName").getDownloadURL();
    return downloadUrl;
  }

  Future<String> downloadprofileMedia(String imageName) async {
    String downloadUrl =
        await storage.ref("profileMedia/$imageName").getDownloadURL();
    return downloadUrl;
  }

  Future<String> downloadprofileMediaVideo(String videoName) async {
    String downloadUrl = await storage
        .ref("profileMedia")
        .child("videos/$videoName")
        .getDownloadURL();
    return downloadUrl;
  }

  Future<String> downloadAdminMedia(String imageName) async {
    String downloadUrl =
        await storage.ref("adminMedia/$imageName").getDownloadURL();
    return downloadUrl;
  }

  Future<String> downloadprofilePhoto(String imageName) async {
    String downloadUrl =
        await storage.ref("profilePhotos/$imageName").getDownloadURL();
    return downloadUrl;
  }

  Future<DocumentReference> getDocumenrID() async {
    DocumentReference docID = await documentReference;
    return docID;
  }
}
