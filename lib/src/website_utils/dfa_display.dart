import 'package:flutter/material.dart';
import 'circle_painter.dart';

//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class DFADisplay extends StatelessWidget {
  final double left;
  final double top;
  final List<String> lines;

  const DFADisplay({
    super.key,
    required this.left,
    required this.top,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 2;
    double displayHeight = MediaQuery.of(context).size.height / 1.5;

    // Get the words from the first line
    List<String> words = lines.isNotEmpty ? lines[0].split(' ') : [];

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: displayWidth,
        height: displayHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: CustomPaint(
          painter: CirclePainter(words),
        ),
      ),
    );
  }
}