import 'package:flutter/material.dart';
//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class DFADisplay extends StatelessWidget {
  final double left;
  final double top;

  const DFADisplay({
    super.key,
    required this.left,
    required this.top,
  });

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 2;
    double displayHeight = MediaQuery.of(context).size.height / 3;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: displayWidth,
        height: displayHeight,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: const Center(
          child: Text(
            'DFA Display',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
