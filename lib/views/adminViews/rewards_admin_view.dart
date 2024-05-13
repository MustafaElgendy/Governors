import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class AdminRewardsView extends StatefulWidget {
  const AdminRewardsView({super.key});

  @override
  State<AdminRewardsView> createState() => _AdminRewardsViewState();
}

class _AdminRewardsViewState extends State<AdminRewardsView> {
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
    var addRewards = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Rewards");
    final Stream<QuerySnapshot> adminRewards = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Rewards")
        .orderBy('createdAt', descending: true)
        .snapshots();

    CollectionReference updateRewards = FirebaseFirestore.instance
        .collection("Admin")
        .doc("@dm!n3000")
        .collection("Rewards");
    DocumentReference adminNameDocument =
        FirebaseFirestore.instance.collection("Admin").doc(userId);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Rewards",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "KdamThmorPro",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: adminRewards,
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.hasError || !snapshot.hasData) {
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
                  updateRewards.doc(data.docs[index].id).update({
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
                                                            "Rewards",
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
                                                            "Rewards",
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
                                      updateRewards.doc(docId).update({
                                        "likedBy": map,
                                        "likes": data.docs[index]["likes"] + 1,
                                      });
                                    } else {
                                      map.addAll({userId: -1});
                                      updateRewards.doc(docId).update({
                                        "likedBy": map,
                                        "likes": data.docs[index]["likes"] - 1,
                                      });
                                    }
                                  } else {
                                    map.addAll({userId: 1});
                                    updateRewards.doc(docId).update({
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
                                        .collection("Rewards")
                                        .doc(data.docs[index].id)
                                        .delete()
                                        .then((value) {});
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
      floatingActionButton: FloatingActionButton.large(
        heroTag: "addBT",
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
                        collectionReference: "Rewards",
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
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add_circle_outline_sharp,
          size: 65,
          color: Color.fromARGB(255, 255, 172, 18),
        ),
      ),
    );
  }
}
