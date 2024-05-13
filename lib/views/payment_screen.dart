import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/emums/menu_action.dart';
import 'package:the_governors/models/argument_model.dart';
import 'package:the_governors/repository/user_repository/user_repository.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/repository/user_repository/storage_sevice.dart';
import 'dart:developer' as devtools show log;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  File? _selectedIamge;
  final Storage storage = Storage();
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  DocumentReference documentReference =
      FirebaseFirestore.instance.collection("Users").doc();
  @override
  Widget build(BuildContext context) {
    var docArgumentID =
        ModalRoute.of(context)!.settings.arguments as FormArgumentData?;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Payment Page",
          style: TextStyle(color: Colors.white, fontFamily: "Spantaran"),
        ),
        actions: [
          PopupMenuButton<MenuAction>(
            color: Colors.amber,
            iconColor: Colors.white,
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogOut = await showLogOutDialog(context);
                  if (shouldLogOut) {
                    await AuthService.firebase().logOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  }
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text("Log Out"),
                )
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10.0,
              ),
              Center(
                child: Image.asset(
                  "assets/images/qrcode.png",
                  height: 150.0,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Container(
                width: size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 15.0,
                    right: 15.0,
                    bottom: 15.0,
                    top: 5.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Transfer Address",
                        style: TextStyle(
                          color: Color.fromARGB(255, 150, 150, 150),
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      SelectableText(
                        'TRhVZp7xt37pi9v4cPvZpp9R1iM6pb2FJ8',
                        style: TextStyle(fontSize: 17.0),
                        showCursor: true,
                        cursorColor: Colors.amber,
                        cursorWidth: 5,
                        cursorRadius: Radius.circular(12),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(
                        color: Colors.black,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "Transfer Email",
                        style: TextStyle(
                          color: Color.fromARGB(255, 150, 150, 150),
                        ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      SelectableText(
                        'disha.elgendy97@gmail.com',
                        style: TextStyle(fontSize: 17.0),
                        showCursor: true,
                        cursorColor: Colors.amber,
                        cursorWidth: 5,
                        cursorRadius: Radius.circular(12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: MaterialButton(
                    color: Colors.amber,
                    child: const Text(
                      "Pick Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Center(
                child: SizedBox(
                  height: 200,
                  child: _selectedIamge != null
                      ? Image.file(_selectedIamge!)
                      : const Text(
                          "Please select your payment screenshot",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(
                height: 15.0,
              ),
              Center(
                child: Container(
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
                    borderRadius: BorderRadius.circular(25.0),
                    child: MaterialButton(
                      child: const Text(
                        "Send Request",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      onPressed: () async {
                        if (_selectedIamge != null) {
                          // AuthService.firebase().sendEmailVerification();
                          final path2 = _selectedIamge?.path;
                          final fileName = basename(path2!);
                          // final docID = documentReference.id;
                          var userId = FirebaseAuth.instance.currentUser?.uid;
                          devtools.log("A7A ${docArgumentID?.data}");
                          await users.doc(userId).update({
                            "imageName": fileName,
                            "createdAt": Timestamp.now()
                          }).then(
                              (value) => devtools.log(">>>>update Done<<<<"));
                          storage.uploadImage(path2, fileName).then((value) =>
                              devtools.log("<<<<<Upload Image done>>>>"));
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (route) => false);
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              "No Image Selected!",
                              style: TextStyle(
                                color: Colors.red,
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
            ],
          ),
        ),
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
        content: Text(
          "No Image Selected!",
        ),
      ));
      return;
    }
    // final path = returnedImage.path;
    // final fileName = returnedImage.name;
    // storage.uploadImage(path, fileName).then((value) => print("done>>>>"));
    setState(() {
      _selectedIamge = File(returnedImage.path);
    });
  }
}
