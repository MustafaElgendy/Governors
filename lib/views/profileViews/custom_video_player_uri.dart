import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayerURI extends StatefulWidget {
  final String videoURL;
  final bool isPlaying;
  const CustomVideoPlayerURI(
      {super.key, required this.videoURL, required this.isPlaying});

  @override
  State<CustomVideoPlayerURI> createState() => _CustomVideoPlayerURIState();
}

class _CustomVideoPlayerURIState extends State<CustomVideoPlayerURI> {
  late VideoPlayerController controller;

  @override
  void initState() {
    controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoURL));
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
    bool isPlaying = widget.isPlaying;
    return Scaffold(
      body: Center(
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
      ),
    );
  }
}
