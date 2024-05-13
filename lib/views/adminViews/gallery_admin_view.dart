import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:the_governors/utilities/hero_dialog.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/adminViews/add_news_media.dart';
import 'package:the_governors/views/profileViews/custom_video_player_uri.dart';
import 'package:the_governors/widgets/admin_image_view_widget.dart';
import 'package:the_governors/widgets/admin_video_view_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminGalleryPage extends StatefulWidget {
  const AdminGalleryPage({super.key});

  @override
  State<AdminGalleryPage> createState() => _AdminGalleryPageState();
}

class _AdminGalleryPageState extends State<AdminGalleryPage> {
  late final TextEditingController _text;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  bool isLiked = false;
  final Storage storage = Storage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _text = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _text.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var addGallery = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Gallery");
    final Stream<QuerySnapshot> adminsGallery = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Gallery")
        .orderBy('createdAt', descending: true)
        .snapshots();

    CollectionReference updateGallery = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Gallery");
    DocumentReference adminNameDocument =
        FirebaseFirestore.instance.collection("Admin").doc(userId);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          "Gallery",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "KdamThmorPro",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: adminsGallery,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError) {
            return const Text(
              "Something went wrong.",
              style: TextStyle(
                color: Colors.white,
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                  height: 50,
                  width: 50,
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  )),
            );
          } else {
            final data = snapshot.requireData;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              itemCount: data.size,
              shrinkWrap: true,
              separatorBuilder: (context, index) => const Divider(
                height: 40.0,
                color: Colors.white,
              ),
              itemBuilder: (context, index) {
                Map<String, dynamic> map = data.docs[index]["likedBy"];
                if (!map.containsKey(userId)) {
                  map.addAll({userId: -1});
                  updateGallery.doc(data.docs[index].id).update({
                    "likedBy": map,
                  });
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: data.docs[index]['Media'] != ""
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data.docs[index]['createdBy']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "IndieFlower",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    FutureBuilder(
                                      future: storage.downloadAdminMedia(
                                          data.docs[index]["Media"]),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                                ConnectionState.done &&
                                            snapshot.hasData) {
                                          String x = data.docs[index]['Media'];
                                          devtools
                                              .log("XXXX ${x.endsWith("jpg")}");
                                          if (x.endsWith("jpg")) {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  HeroDialogRoute(
                                                    builder: (context) {
                                                      return AdminImageViewWidget(
                                                        userId: userId,
                                                        data: data,
                                                        snapshot: snapshot,
                                                        index: index,
                                                        collectionName: "Admin",
                                                        textTitle: "Text",
                                                        collectionReference:
                                                            "Gallery",
                                                      );
                                                    },
                                                    settings:
                                                        const RouteSettings(
                                                            name: "setting"),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: size.width,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey,
                                                  image: DecorationImage(
                                                    image: NetworkImage(
                                                        snapshot.data!),
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  HeroDialogRoute(
                                                    builder: (context) {
                                                      return AdminVideoViewWidget(
                                                        userId: userId,
                                                        data: data,
                                                        snapshot: snapshot,
                                                        index: index,
                                                        collectionReference:
                                                            "Gallery",
                                                        textTitle: "Text",
                                                      );
                                                    },
                                                    settings:
                                                        const RouteSettings(
                                                            name: "setting"),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                height: 220.0,
                                                child: Stack(
                                                  children: [
                                                    CustomVideoPlayerURI(
                                                      videoURL: snapshot.data!,
                                                      isPlaying: false,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: Container(
                                                height: 50,
                                                width: 50,
                                                child:
                                                    const CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.amber),
                                                )),
                                          );
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.none) {
                                          return const Center(
                                            child: Text(
                                              "Failed in connection",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }
                                        if (snapshot.hasError) {
                                          return const Center(
                                            child: Text(
                                              "Connection Failed",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }
                                        return const Center(
                                          child: Text(
                                            "Loading....",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Linkify(
                                      onOpen: (link) async {
                                        if (!await launchUrl(
                                            Uri.parse(link.url))) {
                                          throw Exception(
                                              'Could not launch ${link.url}');
                                        }
                                      },
                                      text: "${data.docs[index]['Text']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data.docs[index]['createdBy']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "IndieFlower",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    SelectableLinkify(
                                      onOpen: (link) async {
                                        if (!await launchUrl(
                                            Uri.parse(link.url))) {
                                          throw Exception(
                                              'Could not launch ${link.url}');
                                        }
                                      },
                                      text: "${data.docs[index]['Text']}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Likes ${data.docs[index]["likes"]}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: "Anta",
                            ),
                          ),
                          Text(
                            data.docs[index]["createdAt"].toDate().toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: size.width * 0.27,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: MaterialButton(
                                onPressed: () async {
                                  String docId = data.docs[index].id;
                                  Map<String, dynamic> map =
                                      await data.docs[index]["likedBy"];
                                  if (map.containsKey(userId)) {
                                    int userliked =
                                        data.docs[index]["likedBy"][userId];
                                    if (userliked == -1) {
                                      map.addAll({userId: 1});
                                      updateGallery.doc(docId).update({
                                        "likedBy": map,
                                        "likes": data.docs[index]["likes"] + 1,
                                      });
                                    } else {
                                      map.addAll({userId: -1});
                                      updateGallery.doc(docId).update({
                                        "likedBy": map,
                                        "likes": data.docs[index]["likes"] - 1,
                                      });
                                    }
                                  } else {
                                    map.addAll({userId: 1});
                                    updateGallery.doc(docId).update({
                                      "likedBy": map,
                                      "likes": data.docs[index]["likes"] + 1,
                                    });
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.thumb_up,
                                      color: data.docs[index]["likedBy"]
                                                  [userId] ==
                                              1
                                          ? Colors.amber
                                          : Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      "Like",
                                      style: TextStyle(
                                        color: data.docs[index]["likedBy"]
                                                    [userId] ==
                                                1
                                            ? Colors.amber
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: size.width * 0.3,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.amber),
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(5.0),
                              child: MaterialButton(
                                onPressed: () async {
                                  final deleteDialog =
                                      await showDeletePostDialog(context);
                                  if (deleteDialog) {
                                    await FirebaseFirestore.instance
                                        .collection("Admin")
                                        .doc("@dm!n3000")
                                        .collection("Gallery")
                                        .doc(data.docs[index].id)
                                        .delete()
                                        .then((value) {
                                      // Navigator.of(context).pushNamedAndRemoveUntil(
                                      //     adminHomeRoute, (route) => false);
                                    });
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      "Delete",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: index == snapshot.data!.size - 1
                          ? MediaQuery.of(context).size.height * 0.2
                          : 0,
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: TextField(
                  autofocus: false,
                  controller: _text,
                  cursorColor: Colors.amber,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 5,
                  enableSuggestions: true,
                  autocorrect: true,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Text",
                      contentPadding: EdgeInsets.all(8)),
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    HeroDialogRoute(
                      builder: (context) {
                        return Hero(
                          tag: userId,
                          child: Material(
                            color: Colors.black45,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const AddAdminMedia(
                                collectionReference: "Gallery",
                                mediaTag: "Media",
                                textTag: "Text",
                                routeName: adminHomeRoute),
                          ),
                        );
                      },
                      settings: const RouteSettings(name: "setting"),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.attach_file_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 5.0,
              ),
              Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.amber),
                child: IconButton(
                  onPressed: () async {
                    var snapshot = await adminNameDocument.get();
                    final text = _text.text.trim();
                    if (text != "") {
                      Map<String, int> likedBy = {
                        userId: -1,
                      };
                      await addGallery.add({
                        "Text": text,
                        "Media": "",
                        "createdAt": Timestamp.now(),
                        "likes": 0,
                        "likedBy": likedBy,
                        "createdBy": snapshot["UserName"],
                        "isLiked": false,
                      }).then((value) {
                        _text.text = "";
                      });
                    } else {
                      await showErrorDialog(context, "You should add text");
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
