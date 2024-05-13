import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

import 'package:the_governors/views/adminViews/admin_profile.dart';
import 'package:the_governors/views/adminViews/news_admin_screen.dart';
import 'package:the_governors/views/login_screen.dart';
import 'package:the_governors/views/menuViews/menu_admin_screen.dart';
import 'package:the_governors/views/menuViews/menu_screen.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _firebaseAuth.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                try {
                  _firebaseAuth.currentUser!.reload();
                  devtools.log(">>>>>>hasData>>>>>");
                  return DefaultTabController(
                    initialIndex: 1,
                    length: 3,
                    child: Scaffold(
                      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
                      appBar: AppBar(
                        centerTitle: true,
                        backgroundColor: Colors.black,
                        title: const Text(
                          "The Governors",
                          style: TextStyle(
                              color: Colors.amber,
                              fontFamily: "KdamThmorPro",
                              fontWeight: FontWeight.bold,
                              fontSize: 25.0),
                        ),
                        bottom: const TabBar(
                          indicatorColor: Colors.amber,
                          dividerHeight: 0.0,
                          tabs: <Widget>[
                            Tab(
                              icon: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              // text: "Profile",
                            ),
                            Tab(
                              icon: Icon(
                                Icons.home_filled,
                                color: Colors.white,
                              ),
                              // text: "Home",
                            ),
                            Tab(
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                              // text: "Menu",
                            ),
                          ],
                        ),
                      ),
                      body: const TabBarView(
                        children: [
                          AdminProfileScreen(),
                          AdminNewsPage(),
                          AdminMenuScreen(),
                        ],
                      ),
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  showErrorDialog(context, "$e");
                }
              } else {
                devtools.log(">>>>>>hasNOOOOOOData>>>>>");
                return const LoginPage();
              }
              return Container();
            default:
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ),
              );
          }
        });
  }
}
