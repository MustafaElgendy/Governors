import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/emums/menu_action.dart';
import 'package:the_governors/services/auth/auth_service.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/profileViews/profile_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    var userId = FirebaseAuth.instance.currentUser?.uid;
    return ProfilScreen(
      collectionName: "Admin",
      userId: userId!,
    );
  }
}
