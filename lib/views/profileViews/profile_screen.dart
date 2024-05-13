import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:the_governors/models/argument_model.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:the_governors/utilities/hero_dialog.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/profileViews/add_profile_post.dart';
import 'package:the_governors/views/profileViews/profile_grid_content_widget.dart';
import 'package:the_governors/widgets/flip_image_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:developer' as devtools show log;

class ProfilScreen extends StatefulWidget {
  final String collectionName;
  final String userId;
  const ProfilScreen(
      {super.key, required this.collectionName, required this.userId});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  late final TextEditingController _searchText;
  File? _image;
  File? _imageCropped;
  CroppedFile? _croppedImage;

  final Storage storage = Storage();
  AsyncSnapshot snapshotData = AsyncSnapshot.nothing();

  DocumentReference documentReference =
      FirebaseFirestore.instance.collection("Users").doc();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchText = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchText.dispose();
  }

  Future selectImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
        content: Text(
          "No Image Selected!",
        ),
      ));
      return;
    }
    setState(() {
      _image = File(img.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference users =
        FirebaseFirestore.instance.collection(widget.collectionName);
    var userId = widget.userId;
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var data = users.doc(userId).get();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      appBar: (currentUserId != userId)
          ? AppBar(
              backgroundColor: Colors.black,
              title: Text(
                "Friend Profile",
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
            )
          : null,
      body: FutureBuilder(
        future: data,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  )),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "There is no profile with this code",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          snapshotData = snapshot;
          return RefreshIndicator(
            color: Colors.black,
            backgroundColor: Colors.amber,
            onRefresh: _refresh,
            child: ListView(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/profileBanner1.png"),
                    fit: BoxFit.fill,
                  )),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FutureBuilder(
                              future: storage.downloadprofilePhoto(
                                  snapshotData.data["profileImage"]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Stack(
                                    children: [
                                      snapshot.hasData
                                          ? Container(
                                              width: 114,
                                              height: 114,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.amber,
                                                  width: 2.0,
                                                ),
                                                color: const Color.fromARGB(
                                                    255, 37, 37, 37),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        300.0),
                                                child: FlipImageWidget(
                                                  front: Image.network(
                                                    snapshot.data!,
                                                  ),
                                                  back: widget.collectionName
                                                          .endsWith("in")
                                                      ? Image.asset(
                                                          "assets/images/adminLogo2.png")
                                                      : Image.asset(
                                                          "assets/images/logo5.png"),
                                                ),
                                              ),
                                            )
                                          : const CircleAvatar(
                                              radius: 60,
                                              backgroundColor: Color.fromARGB(
                                                  255, 37, 37, 37),
                                              backgroundImage: AssetImage(
                                                  "assets/images/profilIcon.png"),
                                            ),
                                      Positioned(
                                        bottom: -15,
                                        left: 70,
                                        child: IconButton(
                                          onPressed: () async {
                                            await selectImage();
                                            await _cropImage(context);
                                            if (_imageCropped != null) {
                                              final path = _imageCropped?.path;
                                              final imageName = basename(path!);
                                              await users.doc(userId).update({
                                                "profileImage": imageName,
                                              }).then((value) {
                                                devtools
                                                    .log(">>>>update Done<<<<");
                                              });
                                              await storage
                                                  .uploadProfilePhoto(
                                                      path, imageName)
                                                  .then((value) {
                                                devtools.log(
                                                    "<<<<<Upload Image done>>>>");
                                                setState(() {});
                                              });
                                            } else {
                                              ScaffoldMessenger.of(
                                                      context as BuildContext)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                  "No Image Selected!",
                                                ),
                                              ));
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.add_a_photo,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 60,
                                        backgroundColor:
                                            Color.fromARGB(255, 37, 37, 37),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.amber),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return Container(
                                  child: const Text(
                                    "Failed in connection2",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            top: 15.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data["UserName"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ProfileGridContent(
                    collectionName: widget.collectionName, userId: userId),
              ],
            ),
          );
        },
      ),
      floatingActionButton: (currentUserId == userId)
          ? Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "detailsBT",
                    onPressed: () {
                      Navigator.of(context).push(
                        HeroDialogRoute(
                          builder: (context) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: Hero(
                                  tag: userId!,
                                  child: Material(
                                    color: Colors.black45,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: _profileDetailsBody(context,
                                          snapshotData, widget.collectionName),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          settings: const RouteSettings(name: "setting"),
                        ),
                      );
                    },
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    label: const Row(
                      children: [
                        Text(
                          "User Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.keyboard_control_key_sharp,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: "searchBT",
                    onPressed: () {
                      Navigator.of(context).push(
                        HeroDialogRoute(
                          builder: (context) {
                            return Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                child: Hero(
                                  tag: userId,
                                  child: Material(
                                    color: Colors.black45,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: _searckWidget(context, _searchText,
                                          userId, widget.collectionName),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          settings: const RouteSettings(name: "setting"),
                        ),
                      );
                    },
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: "addBT",
                    onPressed: () {
                      Navigator.of(context).push(
                        HeroDialogRoute(
                          builder: (context) {
                            return Hero(
                              tag: userId!,
                              child: Material(
                                color: Colors.black45,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: AddProfilePostWidget(
                                  collectionName: widget.collectionName,
                                ),
                              ),
                            );
                          },
                          settings: const RouteSettings(name: "setting"),
                        ),
                      );
                    },
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline_sharp,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Future _refresh() {
    setState(() {});
    return Future.delayed(
      Duration(seconds: 0),
    );
  }

  Future<void> _cropImage(BuildContext context) async {
    if (_image != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _image!.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Color.fromARGB(255, 206, 221, 0),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _croppedImage = croppedFile;
          _imageCropped = File(_croppedImage!.path);
        });
      }
    }
  }
}

Widget _profileDetailsBody(
    BuildContext context, AsyncSnapshot snapshot, String collectionName) {
  Size size = MediaQuery.of(context).size;
  return SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.amber),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 15.0,
              right: 15.0,
              bottom: 15.0,
              top: 5.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "User Rank",
                  style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                SelectableText(
                  collectionName.endsWith("n") ? "Admin" : "Diamond",
                  style: const TextStyle(
                      fontSize: 25.0, fontFamily: "Heartjungle"),
                  showCursor: true,
                  cursorColor: Colors.amber,
                  cursorWidth: 5,
                  cursorRadius: const Radius.circular(12),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Divider(
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  "User Email",
                  style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                SelectableText(
                  snapshot.data["email"],
                  style: const TextStyle(fontSize: 17.0),
                  showCursor: true,
                  cursorColor: Colors.amber,
                  cursorWidth: 5,
                  cursorRadius: Radius.circular(12),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Divider(
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  "User Code",
                  style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                SelectableText(
                  snapshot.data["userCode"],
                  style: const TextStyle(fontSize: 17.0),
                  showCursor: true,
                  cursorColor: Colors.amber,
                  cursorWidth: 5,
                  cursorRadius: const Radius.circular(12),
                ),
                const Divider(
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  "Account created at:",
                  style: TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150),
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                SelectableText(
                  snapshot.data["createdAt"].toDate().toString(),
                  style: const TextStyle(fontSize: 17.0),
                  showCursor: true,
                  cursorColor: Colors.amber,
                  cursorWidth: 5,
                  cursorRadius: const Radius.circular(12),
                ),
                const Divider(
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _searckWidget(BuildContext context, TextEditingController text,
    String userId, String collectionName) {
  Size size = MediaQuery.of(context).size;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        width: size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: text,
            cursorColor: Colors.amber,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "Search Profile",
              icon: Icon(Icons.search_sharp),
            ),
          ),
        ),
      ),
      const SizedBox(
        height: 15.0,
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Colors.amber),
          borderRadius: BorderRadius.circular(32),
        ),
        child: IconButton(
          onPressed: () {
            if (text.text != "") {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilScreen(
                        collectionName: collectionName,
                        userId: text.text.trim()),
                  ));
            } else {
              showErrorDialog(context, "Enter User Code To Search");
            }
          },
          icon: const Icon(
            Icons.search_sharp,
            size: 50.0,
          ),
          color: Colors.amber,
        ),
      ),
    ],
  );
}
