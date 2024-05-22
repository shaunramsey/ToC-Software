import 'package:flutter/material.dart';
import 'dart:math';
import 'circle_painter.dart';
import 'edges_painter.dart';



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

  List<Offset> _calculatePositions(Size size, int count) {
    final center = Offset(size.width / 2, size.height / 2);
    final positions = <Offset>[];

    // Calculate the radius to fit within the rectangle, leaving some margin
    final radiusX = (size.width / 2) - 40; // Leave some margin on the sides
    final radiusY = (size.height / 2) - 40; // Leave some margin on the top and bottom
    final angleIncrement = (2 * pi) / count;

    for (int i = 0; i < count; i++) {
      final angle = angleIncrement * i;
      positions.add(Offset(
        center.dx + radiusX * cos(angle),
        center.dy + radiusY * sin(angle),
      ));
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 1.25;
    double displayHeight = MediaQuery.of(context).size.height / 1.25;

    // Get the words from the first line
    List<String> wordsSplit = lines.isNotEmpty ? lines[0].trim().split(' ') : [];
    List<String> words = [];
    for (int i = 0; i < wordsSplit.length; i++) {
      String s = wordsSplit[i].trim();
      if(s.isNotEmpty) {
        words.add(s);
      }
    }

    // Calculate positions for circles
    List<Offset> positions = _calculatePositions(Size(displayWidth, displayHeight), words.length);

    // Create edges
    final edges = Edges(lines, words).edges;

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
          painter: CirclePainter(words, edges, positions),
        ),
      ),
    );
  }
}

