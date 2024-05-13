import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  final File? vidoeFile;
  const CustomVideoPlayer({super.key, required this.vidoeFile});

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController controller;
  bool isPlaying = false;

  @override
  void initState() {
    controller = VideoPlayerController.file(widget.vidoeFile!);
    controller.initialize().then((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (controller.value.isPlaying) {
            controller.pause();
            isPlaying = false;
          } else {
            controller.play();
            isPlaying = true;
          }
        });
      },
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          children: [
            VideoPlayer(controller),
            Positioned(
              top: 5,
              left: 5,
              child: !isPlaying
                  ? const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.pause,
                      color: Colors.white,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
