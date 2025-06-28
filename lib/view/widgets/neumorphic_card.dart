import 'package:flutter/material.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;

  const NeumorphicCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: Offset(5, 5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-5, -5),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
}