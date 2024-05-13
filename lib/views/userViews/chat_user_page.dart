import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/services/chatServices/chat_service.dart';
import 'package:the_governors/views/profileViews/profile_screen.dart';
import 'package:the_governors/widgets/chat_bubble.dart';
import 'package:the_governors/widgets/chat_bubble_receiver.dart';

class ChatUserPage extends StatefulWidget {
  final String UserName;
  final String UserUid;
  final String collectionName;
  const ChatUserPage(
      {super.key,
      required this.UserName,
      required this.UserUid,
      required this.collectionName});

  @override
  State<ChatUserPage> createState() => _ChatUserPageState();
}

class _ChatUserPageState extends State<ChatUserPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(widget.UserUid, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.amber,
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilScreen(
                    collectionName: widget.collectionName,
                    userId: widget.UserUid),
              ),
            );
          },
          child: Text(
            widget.UserName,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  //build message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.UserUid, _firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "Something went wrong.",
            style: TextStyle(
              color: Colors.white,
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Container(
                height: 50,
                width: 50,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                )),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: snapshot.data!.docs
                .map((document) => _buildMessageItem(document))
                .toList(),
          ),
        );
      },
    );
  }

  //build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //align the message to the right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            (data['senderId'] == _firebaseAuth.currentUser!.uid)
                ? ChatBubbleSender(message: data["message"])
                : ChatBubbleReceiver(message: data["message"]),
          ],
        ),
      ),
    );
  }

  //build message input

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextField(
                autofocus: false,
                controller: _messageController,
                cursorColor: Colors.amber,
                textInputAction: TextInputAction.newline,
                minLines: 1,
                maxLines: 5,
                enableSuggestions: true,
                autocorrect: true,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Message",
                    contentPadding: EdgeInsets.all(8)),
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 40.0,
              color: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
