// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/data/data.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:the_governors/services/auth/auth_exception.dart';
import 'dart:developer' as devtools show log;

import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/hero_dialog.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';

class MemberReviewingWidget extends StatefulWidget {
  const MemberReviewingWidget({super.key});

  @override
  State<MemberReviewingWidget> createState() => _MemberReviewingWidgetState();
}

class _MemberReviewingWidgetState extends State<MemberReviewingWidget> {
  final Storage storage = Storage();
  final Stream<QuerySnapshot> users = FirebaseFirestore.instance
      .collection("Users")
      .orderBy('createdAt', descending: true)
      .snapshots();
  @override
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: users,
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "UserName: ${data.docs[index]['UserName']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Email: ${data.docs[index]['email']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "HeaderCode: ${data.docs[index]['headerCode']}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Created At: ${data.docs[index]['createdAt'].toDate().toString()}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: FutureBuilder(
                        future: storage.listImages(),
                        builder: (BuildContext context,
                            AsyncSnapshot<firebase_storage.ListResult>
                                snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return FutureBuilder(
                              future: storage
                                  .downloadImage(data.docs[index]['imageName']),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          HeroDialogRoute(
                                              builder: (context) {
                                                return Center(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            45.0),
                                                    child: Hero(
                                                      tag: "Payment Screenshot",
                                                      child: Material(
                                                        color: Colors.black45,
                                                        elevation: 2,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(32),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Image.network(
                                                              snapshot.data!),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              settings: const RouteSettings(
                                                  name: "setting")));
                                    },
                                    child: Hero(
                                      tag: "Payment Screenshot",
                                      child: Container(
                                        height: 350,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.amber,
                                            width: 2.0,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(snapshot.data!),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting &&
                                    !snapshot.hasData) {
                                  return Container(
                                      height: 50,
                                      width: 50,
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.amber),
                                      ));
                                }
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(15.0),
                                      child: Container(
                                        height: 350,
                                        width: 200,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.amber,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            "There is no image",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  child: const Text(
                                    "Failed in connection",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            );
                          }
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return Container(
                                height: 50,
                                width: 50,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.amber),
                                ));
                          }
                          return Container(
                            child: const Text(
                              "Failed in connection2",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          gradient: const LinearGradient(
                            colors: <Color>[
                              Color.fromARGB(255, 129, 127, 0),
                              Colors.amber,
                            ],
                          ),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: TextButton(
                              child: const Text(
                                "Send Verification",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () async {
                                try {
                                  await AuthService.firebase().logIn(
                                      email: data.docs[index]['email'],
                                      password: data.docs[index]['password']);
                                  final user =
                                      AuthService.firebase().currentUser;
                                  if (user?.isEmailVerified ?? false) {
                                    await showErrorDialog(
                                        context, "This account is verified");
                                  } else {
                                    await AuthService.firebase()
                                        .sendEmailVerification();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text(
                                        "Verification has been sent successfully",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ));
                                  }
                                } on UserIsDisabled {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 167, 11, 0),
                                    duration: Duration(milliseconds: 500),
                                    content: Text(
                                      "This account is Disabled",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ));
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      width: 140,
                      alignment: Alignment.bottomLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            Color.fromARGB(255, 129, 0, 0),
                            Color.fromARGB(255, 255, 52, 52)
                          ],
                        ),
                      ),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: TextButton(
                            child: const Text(
                              "Check Verification",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                              ),
                            ),
                            onPressed: () async {
                              try {
                                await AuthService.firebase().logIn(
                                    email: data.docs[index]['email'],
                                    password: data.docs[index]['password']);
                                final user = AuthService.firebase().currentUser;
                                if (user?.isEmailVerified ?? false) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 6, 180, 0),
                                    duration: Duration(milliseconds: 500),
                                    content: Text(
                                      "This account is verified",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor:
                                        Color.fromARGB(255, 167, 11, 0),
                                    duration: Duration(milliseconds: 500),
                                    content: Text(
                                      "This account is not verified",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ));
                                }
                              } on UserIsDisabled {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor:
                                      Color.fromARGB(255, 167, 11, 0),
                                  duration: Duration(milliseconds: 500),
                                  content: Text(
                                    "This account is Disabled",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ));
                              }
                            },
                          ),
                        ),
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
        });
  }

  Widget singleItemWidget(MemberInfo memberInfo, bool lastItem) {
    return StreamBuilder<QuerySnapshot>(
      stream: users,
      builder: (
        BuildContext context,
        AsyncSnapshot<QuerySnapshot> snapshot,
      ) {
        if (snapshot.hasError) {
          return const Text("Something went wrong.");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading.....");
        } else {
          final data = snapshot.requireData;
          return Container(
            width: MediaQuery.of(context).size.width,
            height: 170,
            margin: const EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                alignment: Alignment.centerRight,
                image: AssetImage(memberInfo.transferScreenShot),
                fit: BoxFit.fitHeight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
            child: ListView.builder(
              itemCount: data.size,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.docs[index]['UserName'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            data.docs[index]['email'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            data.docs[index]['headerCode'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25.0),
                            child: MaterialButton(
                              color: Colors.amber,
                              child: const Text(
                                "Send Verification",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
      },
    );
  }
}
