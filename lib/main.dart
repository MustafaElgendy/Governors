import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/services/notificationServices/push_notification.dart';
import 'package:the_governors/views/adminViews/add_news_media.dart';
import 'package:the_governors/views/adminViews/admin_profile.dart';
import 'package:the_governors/views/adminViews/charity_admin_view.dart';
import 'package:the_governors/views/adminViews/chat_admin_view.dart';
import 'package:the_governors/views/adminViews/copy_paste_admin.dart';
import 'package:the_governors/views/adminViews/discount_admin_view.dart';
import 'package:the_governors/views/adminViews/gallery_admin_view.dart';
import 'package:the_governors/views/adminViews/home_admin_screen.dart';
import 'package:the_governors/views/adminViews/news_admin_screen.dart';
import 'package:the_governors/views/adminViews/rewards_admin_view.dart';
import 'package:the_governors/views/adminViews/sign_up_as_admin.dart';
import 'package:the_governors/views/adminReviewing/admin_screen.dart';
import 'package:the_governors/views/userViews/charity_user_view.dart';
import 'package:the_governors/views/userViews/chat_user_view.dart';
import 'package:the_governors/views/userViews/copy_paste_user_view.dart';
import 'package:the_governors/views/userViews/discount_user_view.dart';
import 'package:the_governors/views/userViews/gallery_user_view.dart';
import 'package:the_governors/views/userViews/home_screen.dart';
import 'package:the_governors/views/login_screen.dart';
import 'package:the_governors/views/payment_screen.dart';
import 'package:the_governors/views/profileViews/profile_screen.dart';
import 'package:the_governors/views/signup_screen.dart';
import 'package:the_governors/views/splash_screen.dart';
import 'dart:developer' as devtools show log;

import 'package:the_governors/views/userViews/rewards_user_view.dart';

Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    devtools.log("HHHHHHHHHHHHHHHHHHHH");
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.amber,
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Colors.grey,
          cursorColor: Colors.amber,
          selectionHandleColor: Colors.amberAccent,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          focusColor: Color.fromARGB(255, 46, 46, 46),
          splashColor: Color.fromARGB(255, 109, 109, 109),
        ),
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          dividerColor: Color.fromARGB(146, 255, 255, 255),
          overlayColor:
              MaterialStatePropertyAll(Color.fromARGB(106, 255, 193, 7)),
          indicatorSize: TabBarIndicatorSize.tab,
        ),
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: Colors.white)
            .copyWith(background: const Color.fromARGB(255, 37, 37, 37)),
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginPage(),
        signUpRoute: (context) => const SignUpPage(),
        splashRoute: (context) => const SplashPage(),
        paymentRoute: (context) => const PaymentPage(),
        homeRoute: (context) => const HomePage(),
        adminRoute: (context) => const AdminPage(),
        profileRoute: (context) =>
            const ProfilScreen(collectionName: "", userId: ""),
        signUpAdminRoute: (context) => const SignUpAsAdmin(),
        adminProfileRoute: (context) => const AdminProfileScreen(),
        adminHomeRoute: (context) => const AdminHomePage(),
        userHomeRoute: (context) => const HomePageView(),
        adminNewsRoute: (context) => const AdminNewsPage(),
        rewardsAdminRoute: (context) => const AdminRewardsView(),
        rewardsUserRoute: (context) => const UserRewardsView(),
        discountUserRoute: (context) => const UserDiscountsView(),
        discountAdminRoute: (context) => const AdminDiscountsView(),
        charityAdminRoute: (context) => const AdminCharityView(),
        charityUserRoute: (context) => const UserCharityView(),
        copyPasteAdminRoute: (context) => const AdminCopyPastePage(),
        copyPasteUserRoute: (context) => const UserCopyPasteView(),
        galleryAdminRoute: (context) => const AdminGalleryPage(),
        galleryUserRoute: (context) => const UserGalleryView(),
        chatUserRoute: (context) => const UserChatView(),
        chatAdminRoute: (context) => const AdminChatView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (BuildContext context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              devtools.log(">>>>>>>$user");
              if (user != null) {
                FirebaseMessaging.instance.getInitialMessage();
                PushNotification.init();
                FirebaseMessaging.onBackgroundMessage(
                    _firebaseBackgroundMessage);
                final userId = FirebaseAuth.instance.currentUser!.uid;
                devtools.log(">>>>>>>$userId");
                final admin = FirebaseFirestore.instance
                    .collection("Admin")
                    .where("userCode", isEqualTo: userId)
                    .get()
                    .then((value) async {
                  devtools.log(">>>>>>>${value.docs.isNotEmpty}");
                  if (value.docs.isNotEmpty) {
                    if (user.isEmailVerified) {
                      devtools.log(">>>>>>>$userId");
                      //Successfully login as Admin
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          adminHomeRoute, (route) => false);
                    } else {
                      //Successfully login as Admin
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          splashRoute, (route) => false);
                    }
                  } else {
                    if (user.isEmailVerified) {
                      //Successfully login
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          userHomeRoute, (route) => false);
                    } else {
                      await Navigator.of(context).pushNamedAndRemoveUntil(
                          splashRoute, (route) => false);
                    }
                  }
                });
              } else {
                return const SplashPage();
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
        },
      ),
    );
  }
}
