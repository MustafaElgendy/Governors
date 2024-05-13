import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  StreamSubscription<User?> get user {
    return _firebaseAuth
        .authStateChanges()
        .listen((User? user) => (user != null) ? user.uid : null);
  }
}
