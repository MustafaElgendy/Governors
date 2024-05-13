import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/emums/menu_action.dart';
import 'package:the_governors/services/auth/auth_exception.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/login_screen.dart';
import 'package:the_governors/views/menuViews/menu_screen.dart';
import 'dart:developer' as devtools show log;
import 'package:the_governors/views/payment_screen.dart';
import 'package:the_governors/views/profileViews/profile_screen.dart';
import 'package:the_governors/views/userViews/news_user_screen.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    String userId = _firebaseAuth.currentUser!.uid;
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
                      backgroundColor: Colors.black,
                      centerTitle: true,
                      title: const Text(
                        "The Governors",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: "KdamThmorPro",
                            fontWeight: FontWeight.bold,
                            fontSize: 25.0),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
                    body: TabBarView(
                      children: [
                        ProfilScreen(collectionName: "Users", userId: userId),
                        NewsUserScreen(),
                        MenuScreen(),
                      ],
                    ),
                  ),
                );
              } on UserIsDisabled {
                return const PaymentPage();
              }
            } else {
              devtools.log(">>>>>>hasNOOOOOOData>>>>>");
              return const LoginPage();
            }
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
      },
    );
  }
}
