import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:the_governors/utilities/hero_dialog.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/profileViews/custom_video_player_uri.dart';
import 'package:the_governors/widgets/profile_video_view_widget.dart';
import 'dart:developer' as devtools show log;

import 'package:video_player/video_player.dart';

class ProfileGridContent extends StatefulWidget {
  final String collectionName;
  final String userId;
  ProfileGridContent(
      {super.key, required this.collectionName, required this.userId});

  @override
  State<ProfileGridContent> createState() => _ProfileGridContentState();
}

class _ProfileGridContentState extends State<ProfileGridContent> {
  final Storage storage = Storage();

  @override
  Widget build(BuildContext context) {
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    var userId = widget.userId;
    final Stream<QuerySnapshot> posts = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("Posts")
        .orderBy('createdAt', descending: true)
        .snapshots();
    final posts2 = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("Posts")
        .count()
        .get()
        .then((value) {
      return value.count!;
    });
    final Stream<QuerySnapshot> videos = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("VideoPosts")
        .orderBy('createdAt', descending: true)
        .snapshots();
    CollectionReference updatePost = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("Posts");
    CollectionReference updateVideoPost = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(userId)
        .collection("VideoPosts");
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            indicatorColor: Colors.amber,
            tabs: [
              Tab(
                icon: Icon(Icons.grid_view_rounded, color: Colors.white),
              ),
              Tab(
                icon:
                    Icon(Icons.video_camera_back_outlined, color: Colors.white),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                //first tab
                FirstTabWidget(
                    posts: posts,
                    storage: storage,
                    updatePost: updatePost,
                    collectionName: widget.collectionName,
                    userId: userId,
                    currentUserId: currentUserId),
                //second tab
                SecondTabWidget(
                  videos: videos,
                  storage: storage,
                  updateVideoPost: updateVideoPost,
                  userId: userId,
                  collectionName: widget.collectionName,
                  currentUserId: currentUserId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FirstTabWidget extends StatefulWidget {
  const FirstTabWidget({
    super.key,
    required this.posts,
    required this.storage,
    required this.updatePost,
    required this.userId,
    required this.collectionName,
    required this.currentUserId,
  });

  final Stream<QuerySnapshot<Object?>> posts;
  final Storage storage;
  final CollectionReference<Object?> updatePost;
  final String userId;
  final String collectionName;
  final String currentUserId;

  @override
  State<FirstTabWidget> createState() => _FirstTabWidgetState();
}

class _FirstTabWidgetState extends State<FirstTabWidget> {
  late Future<int> getPostsSize;
  late int postsListSize;
  @override
  void initState() {
    super.initState();
    getPostsSize = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.userId)
        .collection("Posts")
        .count()
        .get()
        .then((value) {
      setState(() {
        postsListSize = value.count!;
        devtools.log("SizeFFF $postsListSize");
      });
      return value.count!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPostsSize,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 9 / 16,
                  ),
                  itemCount: postsListSize,
                  itemBuilder: (context, index) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: widget.posts,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text(
                              "Something went wrong.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.amber),
                                  )),
                            );
                          }
                          if (snapshot.connectionState ==
                                  ConnectionState.active &&
                              snapshot.hasData) {
                            final data = snapshot.requireData;
                            Map<String, dynamic> map =
                                data.docs[index]["likedBy"];
                            if (!map.containsKey(widget.currentUserId)) {
                              map.addAll({widget.currentUserId: -1});
                              widget.updatePost
                                  .doc(data.docs[index].id)
                                  .update({
                                "likedBy": map,
                              });
                            }

                            return FutureBuilder(
                                future: widget.storage.downloadprofileMedia(
                                    data.docs[index]["postImage"]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return GestureDetector(
                                      onDoubleTap: () async {
                                        String docId = data.docs[index].id;
                                        Map<String, dynamic> map =
                                            await data.docs[index]["likedBy"];
                                        if (map.containsKey(
                                            widget.currentUserId)) {
                                          int userliked = data.docs[index]
                                              ["likedBy"][widget.currentUserId];
                                          if (userliked == -1) {
                                            map.addAll(
                                                {widget.currentUserId: 1});
                                            widget.updatePost
                                                .doc(docId)
                                                .update({
                                              "likedBy": map,
                                              "likes":
                                                  data.docs[index]["likes"] + 1,
                                            });
                                          } else {
                                            map.addAll(
                                                {widget.currentUserId: -1});
                                            widget.updatePost
                                                .doc(docId)
                                                .update({
                                              "likedBy": map,
                                              "likes":
                                                  data.docs[index]["likes"] - 1,
                                            });
                                          }
                                        } else {
                                          map.addAll({widget.currentUserId: 1});
                                          widget.updatePost.doc(docId).update({
                                            "likedBy": map,
                                            "likes":
                                                data.docs[index]["likes"] + 1,
                                          });
                                        }
                                        // data.docs[index]["isLiked"]
                                        //     ? await widget.updatePost
                                        //         .doc(data.docs[index].id)
                                        //         .update({
                                        //         "isLiked": false,
                                        //         "likes": data.docs[index]
                                        //                 ["likes"] -
                                        //             1
                                        //       })
                                        //     : await widget.updatePost
                                        //         .doc(data.docs[index].id)
                                        //         .update({
                                        //         "isLiked": true,
                                        //         "likes": data.docs[index]
                                        //                 ["likes"] +
                                        //             1
                                        //       });
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          HeroDialogRoute(
                                            builder: (context) {
                                              return ProfileMediaViewWidget(
                                                userId: widget.userId,
                                                data: data,
                                                snapshot: snapshot,
                                                index: index,
                                                collectionName:
                                                    widget.collectionName,
                                                currentUserId:
                                                    widget.currentUserId,
                                              );
                                            },
                                            settings: const RouteSettings(
                                                name: "setting"),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            height: 250,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    snapshot.data!),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withOpacity(0.5),
                                                    Colors.black
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  stops: const [0.0, 0.6, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            left: 10,
                                            child: Text(
                                              data.docs[index]["caption"],
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                  size: 12.0,
                                                ),
                                                Text(
                                                  "${data.docs[index]["likes"]}",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: data.docs[index]["likedBy"][
                                                        widget.currentUserId] ==
                                                    1
                                                ? const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  )
                                                : Container(
                                                    child: const Icon(
                                                      Icons.favorite_border,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      !snapshot.hasData) {
                                    return Center(
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.amber),
                                          )),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.none) {
                                    return const Center(
                                      child: Text(
                                        "Failed in connection",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    devtools.log(
                                        "Connection Error ${snapshot.error}");
                                    return const Center(
                                      child: Text(
                                        "Connection Failed",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: Text(
                                      "Loading....",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                });
                          }
                          return Container(
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                          );
                        });
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Something went wrong.",
              style: TextStyle(
                color: Colors.white,
              ),
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
          return Container();
        }
      },
    );
  }
}

class ProfileMediaViewWidget extends StatefulWidget {
  const ProfileMediaViewWidget({
    super.key,
    required this.userId,
    required this.data,
    required this.snapshot,
    required this.index,
    required this.collectionName,
    required this.currentUserId,
  });

  final String userId;
  final String currentUserId;
  final QuerySnapshot<Object?> data;
  final int index;
  final AsyncSnapshot<String> snapshot;
  final String collectionName;

  @override
  State<ProfileMediaViewWidget> createState() => _ProfileMediaViewWidgetState();
}

class _ProfileMediaViewWidgetState extends State<ProfileMediaViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: Hero(
          tag: widget.userId,
          child: Material(
            color: Colors.black45,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            child: Padding(
              padding: const EdgeInsets.all(45.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber, width: 5.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.snapshot.data!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                            Colors.black
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Text(
                      widget.data.docs[widget.index]["caption"],
                      maxLines: 3,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 30.0),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        const SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          "${widget.data.docs[widget.index]["likes"]}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: widget.data.docs[widget.index]["likedBy"]
                                [widget.currentUserId] ==
                            1
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 35.0,
                          )
                        : Container(
                            child: const Icon(
                              Icons.favorite_border,
                              color: Colors.amber,
                              size: 35.0,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: (widget.userId == widget.currentUserId)
                        ? Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                final deleteDialog =
                                    await showDeletePostDialog(context);
                                if (deleteDialog) {
                                  await FirebaseFirestore.instance
                                      .collection(widget.collectionName)
                                      .doc(widget.userId)
                                      .collection("Posts")
                                      .doc(widget.data.docs[widget.index].id)
                                      .delete()
                                      .then((value) {
                                    devtools.log("post deleted");
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            homeRoute, (route) => false);
                                  });
                                }
                              },
                            ),
                          )
                        : const Text(""),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SecondTabWidget extends StatefulWidget {
  const SecondTabWidget({
    super.key,
    required this.videos,
    required this.storage,
    required this.updateVideoPost,
    required this.userId,
    required this.collectionName,
    required this.currentUserId,
  });

  final Stream<QuerySnapshot<Object?>> videos;
  final Storage storage;
  final CollectionReference<Object?> updateVideoPost;
  final String userId;
  final String collectionName;
  final String currentUserId;

  @override
  State<SecondTabWidget> createState() => _SecondTabWidgetState();
}

class _SecondTabWidgetState extends State<SecondTabWidget> {
  bool isPlaying = false;
  late Future<int> getSize;
  late int videoListSize;
  @override
  void initState() {
    super.initState();
    getSize = FirebaseFirestore.instance
        .collection(widget.collectionName)
        .doc(widget.userId)
        .collection("VideoPosts")
        .count()
        .get()
        .then((value) {
      setState(() {
        videoListSize = value.count!;
        devtools.log("SizeFFF $videoListSize");
      });
      return value.count!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getSize,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          devtools.log("message ${snapshot.data}");
          return SingleChildScrollView(
            child: Column(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 9 / 16,
                  ),
                  itemCount: videoListSize,
                  itemBuilder: (context, index) {
                    return StreamBuilder<QuerySnapshot>(
                        stream: widget.videos,
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text(
                              "Something went wrong.",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            devtools.log(">???>$videoListSize");
                            return Center(
                              child: Container(
                                  height: 50,
                                  width: 50,
                                  child: const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color.fromARGB(255, 255, 7, 7)),
                                  )),
                            );
                          }
                          if (snapshot.connectionState ==
                                  ConnectionState.active ||
                              snapshot.connectionState ==
                                      ConnectionState.done &&
                                  snapshot.hasData) {
                            final data = snapshot.requireData;
                            Map<String, dynamic> map =
                                data.docs[index]["likedBy"];
                            if (!map.containsKey(widget.currentUserId)) {
                              map.addAll({widget.currentUserId: -1});
                              widget.updateVideoPost
                                  .doc(data.docs[index].id)
                                  .update({
                                "likedBy": map,
                              });
                            }
                            return FutureBuilder(
                                future: widget.storage
                                    .downloadprofileMediaVideo(
                                        data.docs[index]["postVideo"]),
                                builder: (BuildContext context,
                                    AsyncSnapshot<String> snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.active ||
                                      snapshot.hasData) {
                                    return GestureDetector(
                                      onDoubleTap: () async {
                                        String docId = data.docs[index].id;
                                        Map<String, dynamic> map =
                                            await data.docs[index]["likedBy"];
                                        if (map.containsKey(
                                            widget.currentUserId)) {
                                          int userliked = data.docs[index]
                                              ["likedBy"][widget.currentUserId];
                                          if (userliked == -1) {
                                            map.addAll(
                                                {widget.currentUserId: 1});
                                            widget.updateVideoPost
                                                .doc(docId)
                                                .update({
                                              "likedBy": map,
                                              "likes":
                                                  data.docs[index]["likes"] + 1,
                                            });
                                          } else {
                                            map.addAll(
                                                {widget.currentUserId: -1});
                                            widget.updateVideoPost
                                                .doc(docId)
                                                .update({
                                              "likedBy": map,
                                              "likes":
                                                  data.docs[index]["likes"] - 1,
                                            });
                                          }
                                        } else {
                                          map.addAll({widget.currentUserId: 1});
                                          widget.updateVideoPost
                                              .doc(docId)
                                              .update({
                                            "likedBy": map,
                                            "likes":
                                                data.docs[index]["likes"] + 1,
                                          });
                                        }
                                        // data.docs[index]["isLiked"]
                                        //     ? await widget.updateVideoPost
                                        //         .doc(data.docs[index].id)
                                        //         .update({
                                        //         "isLiked": false,
                                        //         "likes": data.docs[index]
                                        //                 ["likes"] -
                                        //             1
                                        //       })
                                        //     : await widget.updateVideoPost
                                        //         .doc(data.docs[index].id)
                                        //         .update({
                                        //         "isLiked": true,
                                        //         "likes": data.docs[index]
                                        //                 ["likes"] +
                                        //             1
                                        //       });
                                      },
                                      onTap: () {
                                        Navigator.of(context).push(
                                          HeroDialogRoute(
                                            builder: (context) {
                                              return ProfileMediaViewVideoWidget(
                                                userId: widget.userId,
                                                data: data,
                                                snapshot: snapshot,
                                                index: index,
                                                currentUserId:
                                                    widget.currentUserId,
                                              );
                                            },
                                            settings: const RouteSettings(
                                                name: "setting"),
                                          ),
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          CustomVideoPlayerURI(
                                            videoURL: snapshot.data!,
                                            isPlaying: isPlaying,
                                          ),
                                          Positioned.fill(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black
                                                        .withOpacity(0.5),
                                                    Colors.black
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  stops: const [0.0, 0.6, 1.0],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            left: 10,
                                            child: Text(
                                              data.docs[index]["caption"],
                                              maxLines: 1,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.favorite,
                                                  color: Colors.red,
                                                  size: 12.0,
                                                ),
                                                Text(
                                                  "${data.docs[index]["likes"]}",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: data.docs[index]["likedBy"][
                                                        widget.currentUserId] ==
                                                    1
                                                ? const Icon(
                                                    Icons.favorite,
                                                    color: Colors.red,
                                                  )
                                                : Container(
                                                    child: const Icon(
                                                      Icons.favorite_border,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      !snapshot.hasData) {
                                    return Center(
                                      child: Container(
                                          height: 50,
                                          width: 50,
                                          child:
                                              const CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.amber),
                                          )),
                                    );
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.none) {
                                    return const Center(
                                      child: Text(
                                        "Failed in connection",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  if (snapshot.hasError) {
                                    devtools.log(
                                        "Connection Error ${snapshot.error}");
                                    return const Center(
                                      child: Text(
                                        "Connection Failed",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }
                                  return const Center(
                                    child: Text(
                                      "Loading....",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                });
                          }
                          if (!snapshot.hasData &&
                              snapshot.connectionState ==
                                  ConnectionState.waiting) {
                            // setState(() {});
                          }
                          return Container(
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                          );
                        });
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Something went wrong.",
              style: TextStyle(
                color: Colors.white,
              ),
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
          return Container();
        }
      },
    );
  }
}
