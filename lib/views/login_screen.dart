// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/models/argument_model.dart';
import 'package:the_governors/services/auth/auth_exception.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'dart:developer' as devtools show log;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo.png",
                height: 150.0,
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Welcome To THE GOVERNORS",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Spantaran',
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              const Text(
                "Sign In",
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Spantaran',
                  fontSize: 30.0,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
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
                    controller: _email,
                    cursorColor: Colors.amber,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Email",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
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
                    controller: _password,
                    cursorColor: Colors.amber,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Password"),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Container(
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  gradient: const LinearGradient(
                    colors: <Color>[
                      Color.fromARGB(255, 129, 127, 0),
                      Colors.amber
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TextButton(
                    onPressed: () async {
                      final email = _email.text.trim();
                      final password = _password.text.trim();
                      if (email == "mustafa.elgendy97@admin.com" &&
                          password == "M05t@f@1997") {
                        Navigator.pushNamed(context, adminRoute);
                      } else if (email == "admin@thegovernors.com" &&
                          password == "TheGovernors2024") {
                        Navigator.pushNamed(context, signUpAdminRoute);
                      } else {
                        try {
                          await AuthService.firebase()
                              .logIn(email: email, password: password);
                          final user = AuthService.firebase().currentUser;
                          final userId = FirebaseAuth.instance.currentUser!.uid;
                          final admin = await FirebaseFirestore.instance
                              .collection("Admin")
                              .where("userCode", isEqualTo: userId)
                              .get()
                              .then((value) async {
                            if (value.docs.isNotEmpty) {
                              if (user?.isEmailVerified ?? false) {
                                //Successfully login as Admin
                                await Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                        adminHomeRoute, (route) => false);
                              } else {
                                await showErrorDialog(context,
                                    "Your account is not verified yet check email inbox.");
                              }
                            } else {
                              if (user?.isEmailVerified ?? false) {
                                //Successfully login as User
                                await Navigator.of(context)
                                    .pushNamedAndRemoveUntil(
                                        homeRoute, (route) => false);
                              } else {
                                await showErrorDialog(context,
                                    "Your account is not verified yet.\nWe are reviewing your account and will send you the activation link as soon as possible.\nThank you.");
                              }
                            }
                          });
                        } on UserNotFoundAuthExceotion {
                          await showErrorDialog(context, "User Not Found");
                        } on WrongPasswordFoundAuthException {
                          await showErrorDialog(context, "Wrong password");
                        } on GenericAuthException {
                          await showErrorDialog(
                              context, "Authentication Error");
                        } on UserIsDisabled {
                          final showDisabledDialog2 =
                              await showDisabledDialog(context);
                          if (showDisabledDialog2) {
                            FirebaseFirestore.instance
                                .collection("Users")
                                .where("email", isEqualTo: email)
                                .get()
                                .then((value) {
                              if (value.docs.isNotEmpty) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    paymentRoute, (route) => false,
                                    arguments:
                                        FormArgumentData(value.docs.first.id));
                              }
                            });
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Sing In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Not Registered Yet!",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          signUpRoute, (route) => false);
                    },
                    child: const Text(
                      "Register Now",
                      style: TextStyle(
                        color: Color.fromARGB(255, 180, 135, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
