import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/models/message_model.dart';

class ChatService extends ChangeNotifier {
  //get instant of auth and store
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //SEND MESSAGE
  Future<void> sendMessage(String receiverId, String message) async {
    //get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    Timestamp timestamp = Timestamp.now();

    //create a new message
    MessageModel messageModel = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );
    //construct chat room id from current userid and receiver id (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // sort ids to ensure the chat room id is always the same for any pair of peaple
    String chatRoomId = ids.join(
        "_"); // combine the ids into a single string to use as a chatRoomId

    //add a new message to database
    await _firestore
        .collection("chat_room")
        .doc(chatRoomId)
        .collection("messages")
        .add(messageModel.toMap());
  }

  //GET MESSAGE
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    //construct chat room id from current userid and receiver id (sorted to ensure uniqueness)
    List<String> ids = [userId, otherUserId];
    ids.sort(); // sort ids to ensure the chat room id is always the same for any pair of peaple
    String chatRoomId = ids.join(
        "_"); // combine the ids into a single string to use as a chatRoomId

    return _firestore
        .collection("chat_room")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy(
          "timestamp",
          descending: false,
        )
        .snapshots();
  }
}
