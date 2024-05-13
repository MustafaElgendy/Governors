import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/services/auth/auth_exception.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'dart:developer' as devtools show log;

import 'package:the_governors/utilities/show_error_dialog.dart';

class SignUpAsAdmin extends StatefulWidget {
  const SignUpAsAdmin({super.key});

  @override
  State<SignUpAsAdmin> createState() => _SignUpAsAdminState();
}

class _SignUpAsAdminState extends State<SignUpAsAdmin> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmedPasswod;
  late final TextEditingController _userName;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmedPasswod = TextEditingController();
    _userName = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmedPasswod.dispose();
    _userName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference admin = FirebaseFirestore.instance.collection("Admin");
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
                height: 5.0,
              ),
              const Text(
                "THE GOVERNORS",
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
                "Admin Sign Up",
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
                      if (confirmedPassword != password) {
                        await showErrorDialog(
                            context, "Password is not matching");
                      } else if (confirmedPassword == password &&
                          email != "" &&
                          userName != "") {
                        try {
                          await AuthService.firebase()
                              .createUser(email: email, password: password);
                          await AuthService.firebase().sendEmailVerification();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Verification has been sent to $email",
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ));
                          var userId = FirebaseAuth.instance.currentUser?.uid;
                          admin.doc(userId).set({
                            'UserName': userName,
                            'password': password,
                            'email': email,
                            'createdAt': Timestamp.now(),
                            'userCode': userId,
                            'rank': "Admin",
                            'profileImage': ""
                          }).then((value) => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                  loginRoute, (route) => false));
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
                          await showErrorDialog(
                              context, "Authentication Error\n" + e.toString());
                        }
                      } else {
                        await showErrorDialog(
                            context, "You should fill all fields");
                      }
                    },
                    child: const Text(
                      "Sign Up",
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
