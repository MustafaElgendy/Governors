import 'dart:math';

import 'package:flutter/material.dart';

class FlipImageWidget extends StatefulWidget {
  final Image front;
  final Image back;
  const FlipImageWidget({Key? key, required this.front, required this.back})
      : super(key: key);

  @override
  State<FlipImageWidget> createState() => _FlipImageWidgetState();
}

class _FlipImageWidgetState extends State<FlipImageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  bool isFront = true;
  bool isFrontStart = true;
  double dragPosition = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    controller.addListener(() {
      setState(() {
        dragPosition = animation.value;
        setImageSide();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angle2 = dragPosition / 180 * pi;
    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(angle2);
    return GestureDetector(
      onHorizontalDragStart: (details) {
        controller.stop();
        isFrontStart = isFront;
      },
      onHorizontalDragUpdate: (details) => setState(() {
        dragPosition -= details.delta.dx;
        dragPosition %= 360;
        setImageSide();
      }),
      onHorizontalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx.abs();
        if (velocity >= 100) {
          isFront = !isFrontStart;
        }
        final double end = isFront ? (dragPosition > 180 ? 360 : 0) : 180;
        animation = Tween<double>(
          begin: dragPosition,
          end: end,
        ).animate(controller);
        controller.forward(from: 0);
      },
      child: Transform(
        transform: transform,
        alignment: Alignment.center,
        child: isFront
            ? widget.front
            : Transform(
                transform: Matrix4.identity()..rotateY(pi),
                alignment: Alignment.center,
                child: widget.back,
              ),
      ),
    );
  }

  void setImageSide() {
    if (dragPosition <= 90 || dragPosition >= 270) {
      isFront = true;
    } else {
      isFront = false;
    }
  }
}
