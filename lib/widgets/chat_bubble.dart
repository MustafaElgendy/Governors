import 'package:flutter/material.dart';

class ChatBubbleSender extends StatelessWidget {
  final String message;
  const ChatBubbleSender({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        color: Colors.amber,
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 16.0),
      ),
    );
  }
}
