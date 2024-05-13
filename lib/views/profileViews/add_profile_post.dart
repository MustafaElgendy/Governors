import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:path/path.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'dart:developer' as devtools show log;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/profileViews/custom_video_player_widget.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;

class AddProfilePostWidget extends StatefulWidget {
  final String collectionName;
  const AddProfilePostWidget({super.key, required this.collectionName});

  @override
  State<AddProfilePostWidget> createState() => _AddProfilePostWidgetState();
}

class _AddProfilePostWidgetState extends State<AddProfilePostWidget> {
  File? _selectedImage;
  File? _selectedVideo;
  late final TextEditingController _caption;
  final Storage storage = Storage();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  double progress2 = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    _caption = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var imageCollection = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("Posts");
    var videoCollection = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("VideoPosts");
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _caption,
              enableSuggestions: true,
              autocorrect: true,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Add Caption",
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Center(
          child: SizedBox(
            height: 230,
            child: _selectedVideo != null
                ? CustomVideoPlayer(
                    vidoeFile: _selectedVideo,
                  )
                : _selectedImage != null
                    ? Image.file(_selectedImage!)
                    : Container(
                        color: const Color.fromARGB(132, 255, 255, 255),
                        child: const Padding(
                          padding: EdgeInsets.all(30.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 50.0,
                                  ),
                                  Icon(
                                    Icons.video_camera_back_outlined,
                                    size: 50.0,
                                  ),
                                ],
                              ),
                              Text(
                                "Add Media",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: MaterialButton(
                color: Colors.amber,
                child: const Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 30.0,
                ),
                onPressed: () {
                  _pickImageFromGallery();
                },
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: MaterialButton(
                color: Colors.amber,
                child: const Icon(
                  Icons.video_library_outlined,
                  size: 30.0,
                ),
                onPressed: () {
                  _pickVideoFromGallary(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20.0,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: MaterialButton(
            color: Colors.amber,
            child: const Text(
              "Post",
              style: TextStyle(
                fontSize: 35.0,
                fontFamily: "Spantaran",
              ),
            ),
            onPressed: () async {
              var caption = _caption.text.trim();
              Map<String, int> likedBy = {
                userId: -1,
              };
              if (_selectedImage != null) {
                final path2 = _selectedImage?.path;
                final fileName = basename(path2!);
                final uploadFile = await storage
                    .uploadProfileMedia(path2, fileName)
                    .then(
                        (value) => devtools.log("<<<<<Upload Image done>>>>"));

                await imageCollection.add({
                  "caption": caption,
                  "postImage": fileName,
                  "createdAt": Timestamp.now(),
                  "likedBy": likedBy,
                  "likes": 0,
                  "isLiked": false,
                }).then((value) async {
                  devtools.log(">>>>>Uploded Post");
                  await Navigator.of(context)
                      .pushNamedAndRemoveUntil(homeRoute, (route) => false);
                });
              } else if (_selectedVideo != null) {
                Map<String, int> likedBy = {
                  userId: -1,
                };
                final path2 = _selectedVideo?.path;
                final fileName = basename(path2!);
                await uploadProfileMediaVideos(context, path2, fileName);

                await videoCollection.add({
                  "caption": caption,
                  "postVideo": fileName,
                  "createdAt": Timestamp.now(),
                  "likedBy": likedBy,
                  "likes": 0,
                  "isLiked": false,
                });
              } else {
                await showErrorDialog(context, "You should pick Media File ");
              }
            },
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        (isLoading)
            ? SizedBox(
                height: 100,
                width: 100,
                child: LiquidCircularProgressIndicator(
                  value: progress2 / 100,
                  valueColor: const AlwaysStoppedAnimation(Colors.amberAccent),
                  backgroundColor: Colors.white,
                  direction: Axis.vertical,
                  center: Text(
                    "${progress2.toInt()}%",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 25.0,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
        content: Text(
          "No Image Selected!",
        ),
      ));
      return;
    }
    final data = await returnedImage.readAsBytes();
    final kb = data.length / 1024;
    final mb = kb / 1024;
    devtools.log("Oreginal Image : $mb");

    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = "${dir.absolute.path}/${returnedImage.name}.jpg";

    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      returnedImage.path,
      targetPath,
      minHeight: 1080,
      minWidth: 950,
      quality: 50,
    );
    final data2 = await compressedImage!.readAsBytes();
    final newKb = data2.length / 1024;
    final newMb = newKb / 1024;
    devtools.log("Compressed Image : $newMb");
    setState(() {
      _selectedImage = File(compressedImage.path);
    });
  }

  Future _pickVideoFromGallary(BuildContext context) async {
    final returnedVideo =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (returnedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "No Image Selected!",
        ),
      ));
      return;
    }

    setState(() {
      _selectedVideo = File(returnedVideo.path);
      isLoading = true;
    });
  }

  Future<void> uploadProfileMediaVideos(
    BuildContext context,
    String videoPath,
    String videoName,
  ) async {
    File video = File(videoPath);
    final metaData = SettableMetadata(contentType: "video/mp4");

    final uploadFile = FirebaseStorage.instance
        .ref("profileMedia")
        .child("videos/$videoName")
        .putFile(video, metaData);
    uploadFile.snapshotEvents.listen((TaskSnapshot snapshot) async {
      switch (snapshot.state) {
        case TaskState.running:
          final progress =
              100 * (snapshot.bytesTransferred / snapshot.totalBytes);
          setState(() {
            progress2 = progress.toDouble();
          });
          devtools.log("upload id $progress complete");
          break;
        case TaskState.paused:
          devtools.log("Upload Paused");
          break;
        case TaskState.canceled:
          devtools.log("Upload canceled");
          break;
        case TaskState.error:
          devtools.log("Upload error");
          setState(() {
            isLoading = false;
          });
          break;
        case TaskState.success:
          await FirebaseStorage.instance
              .ref("profileMedia")
              .child("videos/$videoName")
              .getDownloadURL()
              .then((value) {
            devtools.log(videoName);
            Navigator.of(context)
                .pushNamedAndRemoveUntil(homeRoute, (route) => false);
          });
          devtools.log("Upload Completed");
          setState(() {
            isLoading = true;
          });
          break;
      }
    });
  }
}
