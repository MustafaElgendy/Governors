// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/models/argument_model.dart';
import 'package:the_governors/services/auth/auth_exception.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as devtools show log;

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmedPasswod;
  late final TextEditingController _headerPassCode;
  late final TextEditingController _userName;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmedPasswod = TextEditingController();
    _headerPassCode = TextEditingController();
    _userName = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmedPasswod.dispose();
    _headerPassCode.dispose();
    _userName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    CollectionReference users = FirebaseFirestore.instance.collection("Users");

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
                "Be Part Of THE GOVERNORS",
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
                "Sign Up",
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
                    controller: _userName,
                    cursorColor: Colors.amber,
                    enableSuggestions: true,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "User Name",
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
                    controller: _headerPassCode,
                    cursorColor: Colors.amber,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Header Code",
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
                  color: Colors.white,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: TextField(
                    controller: _confirmedPasswod,
                    cursorColor: Colors.amber,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: "Confirm Password"),
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
                      final confirmedPassword = _confirmedPasswod.text.trim();
                      final userName = _userName.text.trim();
                      final headerCode = _headerPassCode.text.trim();
                      if (confirmedPassword != password) {
                        await showErrorDialog(
                            context, "Password is not matching");
                      } else if (confirmedPassword == password &&
                          email != "" &&
                          userName != "" &&
                          headerCode != "") {
                        final usersWithHeaderCode = FirebaseFirestore.instance
                            .collection("Users")
                            .where('userCode', isEqualTo: headerCode)
                            .get()
                            .then((value) async {
                          if (value.docs.isNotEmpty) {
                            try {
                              await AuthService.firebase()
                                  .createUser(email: email, password: password);
                              var userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              final firebaseMessaging =
                                  FirebaseMessaging.instance;
                              await firebaseMessaging.getToken().then((value) {
                                devtools.log("Token2: $value");
                                users.doc(userId).set({
                                  'UserName': userName,
                                  'password': password,
                                  'headerCode': headerCode,
                                  'email': email,
                                  'imageName': "",
                                  'token': value,
                                  'createdAt': Timestamp.now(),
                                  'userCode': userId,
                                  'profileImage': ""
                                });
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    paymentRoute, (route) => false);
                              });
                            } on WeakPasswordAuthException {
                              await showErrorDialog(context, "Weak Password");
                            } on EmailAlreadyInUseAuthException {
                              await showErrorDialog(
                                  context, "Email already in use");
                            } on InvalidEmailAuthException {
                              await showErrorDialog(context, "Invalid Email");
                            } on OperationNotAllowedAuthException {
                              await showErrorDialog(
                                  context, "Operation Not Allowed");
                            } on GenericAuthException catch (e) {
                              await showErrorDialog(context,
                                  "Authentication Error\n" + e.toString());
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0)),
                              ),
                              showCloseIcon: true,
                              backgroundColor: Color.fromARGB(255, 167, 11, 0),
                              content: Text(
                                "Header Code is not exist",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ));
                          }
                        }, onError: (e) => devtools.log("<<<<Error>>>> $e"));
                        devtools.log("<headerCode> $usersWithHeaderCode");
                      } else {
                        await showErrorDialog(
                            context, "You should fill all fields");
                      }
                    },
                    child: const Text(
                      "Next Step",
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
                    "Have you already registered?",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    },
                    child: const Text(
                      "Sign In",
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
