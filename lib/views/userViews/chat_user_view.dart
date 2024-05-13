import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:the_governors/views/userViews/chat_user_page.dart';

class UserChatView extends StatefulWidget {
  const UserChatView({super.key});

  @override
  State<UserChatView> createState() => _UserChatViewState();
}

class _UserChatViewState extends State<UserChatView> {
  Storage storage = Storage();
  var userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    var friends = FirebaseFirestore.instance
        .collection("Users")
        .where("headerCode", isEqualTo: userId)
        .snapshots();
    var mySnapshot =
        FirebaseFirestore.instance.collection("Users").doc(userId).get();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Chat Room",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "KdamThmorPro",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder(
        future: mySnapshot,
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Text(
              "Something went wrong.",
              style: TextStyle(
                color: Colors.white,
              ),
            );
          }
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
          var data = snapshot.requireData;
          var headerSnap = FirebaseFirestore.instance
              .collection("Users")
              .doc(data["headerCode"])
              .snapshots();
          return StreamBuilder(
            stream: headerSnap,
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                return const Text(
                  "Something went wrong.",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                );
              }
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
              final data = snapshot.requireData;
              String userName = data["UserName"];
              var futurephoto = data["profileImage"];

              if (snapshot.connectionState == ConnectionState.active) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatUserPage(
                              UserName: userName,
                              UserUid: data["userCode"],
                              collectionName: "Users",
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber,
                              ),
                              child: Center(
                                child: Text(
                                  userName[0],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              data["UserName"],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    friendsUseMyCodeWidget(
                        friends: friends,
                        storage: storage,
                        collectionName: "Users"),
                  ],
                );
              } else {
                return const Text(
                  "Error",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}

class friendsUseMyCodeWidget extends StatefulWidget {
  const friendsUseMyCodeWidget({
    super.key,
    required this.friends,
    required this.storage,
    required this.collectionName,
  });

  final Stream<QuerySnapshot<Map<String, dynamic>>> friends;
  final Storage storage;
  final String collectionName;

  @override
  State<friendsUseMyCodeWidget> createState() => _friendsUseMyCodeWidgetState();
}

class _friendsUseMyCodeWidgetState extends State<friendsUseMyCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.friends,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            "Something went wrong.",
            style: TextStyle(
              color: Colors.white,
            ),
          );
        }
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
        final data = snapshot.requireData;
        if (snapshot.connectionState == ConnectionState.active) {
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 5,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemCount: data.size,
            itemBuilder: (context, index) {
              String userName = data.docs[index]["UserName"];
              var futurephoto = data.docs[index]["profileImage"];

              if (futurephoto == "") {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatUserPage(
                          UserName: userName,
                          UserUid: data.docs[index]["userCode"],
                          collectionName: widget.collectionName,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.amber,
                          ),
                          child: Center(
                            child: Text(
                              userName[0],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          data.docs[index]["UserName"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return FutureBuilder(
                  future: widget.storage.downloadprofilePhoto(futurephoto),
                  builder: (context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return Center(
                        child: Container(
                            height: 50,
                            width: 50,
                            child: const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.amber),
                            )),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.none) {
                      return const Center(
                        child: Text(
                          "Failed in connection",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      devtools.log("Connection Error ${snapshot.error}");
                      return const Center(
                        child: Text(
                          "Connection Failed",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatUserPage(
                                UserName: userName,
                                UserUid: data.docs[index]["userCode"],
                                collectionName: widget.collectionName,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.amber),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(snapshot.data!),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                data.docs[index]["UserName"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 25.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        "Loading....",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              }
            },
          );
        } else {
          return const Text(
            "Error",
            style: TextStyle(
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
