import 'package:flutter/material.dart';

class ChatBubbleReceiver extends StatelessWidget {
  final String message;
  const ChatBubbleReceiver({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}
