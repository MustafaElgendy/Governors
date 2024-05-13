import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:the_governors/constants/routes.dart';
import 'package:the_governors/utilities/show_error_dialog.dart';
import 'package:the_governors/views/profileViews/custom_video_player_uri.dart';
import 'dart:developer' as devtools show log;

import 'package:video_player/video_player.dart';

class ProfileMediaViewVideoWidget extends StatefulWidget {
  const ProfileMediaViewVideoWidget({
    super.key,
    required this.userId,
    required this.data,
    required this.snapshot,
    required this.index,
    required this.currentUserId,
  });

  final String userId;
  final String currentUserId;
  final QuerySnapshot<Object?> data;
  final int index;
  final AsyncSnapshot<String> snapshot;

  @override
  State<ProfileMediaViewVideoWidget> createState() =>
      _ProfileMediaViewVideoWidgetState();
}

class _ProfileMediaViewVideoWidgetState
    extends State<ProfileMediaViewVideoWidget> {
  late VideoPlayerController controller;
  bool isPlaying = false;
  String videoURL = "";
  @override
  void initState() {
    controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.snapshot.data!));
    controller.initialize().then((_) {
      setState(() {
        controller.play();
        isPlaying = true;
      });
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
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Hero(
            tag: widget.userId,
            child: Material(
              color: Colors.black45,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(45.0),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(controller),
                          Positioned(
                            top: 5,
                            left: 5,
                            right: 5,
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
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                              Colors.black
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Text(
                        widget.data.docs[widget.index]["caption"],
                        maxLines: 3,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 30.0),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            "${widget.data.docs[widget.index]["likes"]}",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: widget.data.docs[widget.index]["likedBy"]
                                  [widget.currentUserId] ==
                              1
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                              size: 35.0,
                            )
                          : Container(
                              child: const Icon(
                                Icons.favorite_border,
                                color: Colors.amber,
                                size: 35.0,
                              ),
                            ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: (widget.userId == widget.currentUserId)
                          ? Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  final deleteDialog =
                                      await showDeletePostDialog(context);
                                  if (deleteDialog) {
                                    await FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(widget.userId)
                                        .collection("VideoPosts")
                                        .doc(widget.data.docs[widget.index].id)
                                        .delete()
                                        .then((value) {
                                      devtools.log("Video post deleted");
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              homeRoute, (route) => false);
                                    });
                                  }
                                },
                              ),
                            )
                          : Text(""),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
