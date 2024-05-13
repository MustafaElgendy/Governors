import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MediaImageViewWidget extends StatefulWidget {
  const MediaImageViewWidget({
    super.key,
    required this.userId,
    required this.data,
    required this.snapshot,
    required this.index,
    required this.collectionName,
    required this.textTitle,
  });

  final String userId;
  final QuerySnapshot<Object?> data;
  final int index;
  final AsyncSnapshot<String> snapshot;
  final String collectionName;
  final String textTitle;

  @override
  State<MediaImageViewWidget> createState() => _MediaImageViewWidgetState();
}

class _MediaImageViewWidgetState extends State<MediaImageViewWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber, width: 5.0),
                      image: DecorationImage(
                        image: NetworkImage(widget.snapshot.data!),
                        fit: BoxFit.contain,
                      ),
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
                      widget.data.docs[widget.index][widget.textTitle],
                      maxLines: 3,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
