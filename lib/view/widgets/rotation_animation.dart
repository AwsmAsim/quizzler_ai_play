import 'package:flutter/material.dart';

class RotationAnimation extends StatefulWidget {
  @override
  _EarthRotationState createState() => _EarthRotationState();
}

class _EarthRotationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController with a duration of 5 seconds
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely

    // Define the animation to go from 0 to 2π (full circle)
    _animation = Tween(begin: 0.0, end: 2 * 3.141592653589793).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              alignment: FractionalOffset.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Add perspective
                ..rotateY(_animation.value), // Rotate around Y-axis
              child: Image.asset(
                'assets/images/qizzler-play-logo-no-play-icon.png',
                width: 100,
                height: 100,
              ),
            );
          },
        ),
      );
  }
}