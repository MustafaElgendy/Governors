import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:the_governors/utilities/hero_dialog.dart';
import 'package:the_governors/views/profileViews/custom_video_player_uri.dart';
import 'package:the_governors/views/profileViews/profile_grid_content_widget.dart';
import 'package:the_governors/widgets/image_view_widget.dart';
import 'package:the_governors/widgets/video_view_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as devtools show log;

class NewsUserScreen extends StatefulWidget {
  const NewsUserScreen({super.key});

  @override
  State<NewsUserScreen> createState() => _NewsUserScreenState();
}

class _NewsUserScreenState extends State<NewsUserScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final Storage storage = Storage();
  final Stream<QuerySnapshot> adminsNews = FirebaseFirestore.instance
      .collection("Admin")
      .doc("@dm!n3000")
      .collection("News")
      .orderBy('createdAt', descending: true)
      .snapshots();
  CollectionReference updateNews = FirebaseFirestore.instance
      .collection("Admin")
      .doc("@dm!n3000")
      .collection("News");
  String? mToken = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestPermission();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      setState(() {
        mToken = value;
        devtools.log("Token: $mToken");
      });
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      devtools.log("User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      devtools.log("User granted provisional permission");
    } else {
      devtools.log("User declined");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: adminsNews,
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
            return RefreshIndicator(
              color: Colors.black,
              backgroundColor: Colors.amber,
              onRefresh: _refresh,
              child: ListView.separated(
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
                    updateNews.doc(data.docs[index].id).update({
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
                            color: const Color.fromARGB(255, 255, 255, 255),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: data.docs[index]['newsMedia'] != ""
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                            data.docs[index]["newsMedia"]),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState.done &&
                                              snapshot.hasData) {
                                            String x =
                                                data.docs[index]['newsMedia'];

                                            if (x.endsWith("jpg")) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                    HeroDialogRoute(
                                                      builder: (context) {
                                                        return MediaImageViewWidget(
                                                          userId: userId,
                                                          data: data,
                                                          snapshot: snapshot,
                                                          index: index,
                                                          collectionName:
                                                              "Admin",
                                                          textTitle:
                                                              "createdBy",
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
                                                        return MediaViewVideoWidget(
                                                          userId: userId,
                                                          data: data,
                                                          snapshot: snapshot,
                                                          index: index,
                                                          textTitle:
                                                              "createdBy",
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
                                                  child: CustomVideoPlayerURI(
                                                    videoURL: snapshot.data!,
                                                    isPlaying: false,
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
                                                                Color>(
                                                            Colors.amber),
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
                                              style: TextStyle(
                                                  color: Colors.white),
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
                                        text: "${data.docs[index]['newsText']}",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        text: "${data.docs[index]['newsText']}",
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
                      Center(
                        child: Container(
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
                                    updateNews.doc(docId).update({
                                      "likedBy": map,
                                      "likes": data.docs[index]["likes"] + 1,
                                    });
                                  } else {
                                    map.addAll({userId: -1});
                                    updateNews.doc(docId).update({
                                      "likedBy": map,
                                      "likes": data.docs[index]["likes"] - 1,
                                    });
                                  }
                                } else {
                                  map.addAll({userId: 1});
                                  updateNews.doc(docId).update({
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
                                    color:
                                        data.docs[index]["likedBy"][userId] == 1
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
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future _refresh() {
    setState(() {});
    return Future.delayed(
      Duration(seconds: 0),
    );
  }
}
