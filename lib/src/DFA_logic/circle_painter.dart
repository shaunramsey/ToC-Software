import 'package:flutter/material.dart';
import 'dart:math';
import 'edges_painter.dart';



class CirclePainter extends CustomPainter {
  final List<String> words;
  final List<Edge> edges;
  final List<Offset> positions;

  CirclePainter(this.words, this.edges, this.positions);

  @override
  void paint(Canvas canvas, Size size) {
    if (words.isEmpty) {
      return;
    }

    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 15,
    );

    const radius = 21.0; // Radius of each circle

    // Draw the circles and the words inside them
    for (int i = 0; i < words.length; i++) {
      final offset = positions[i];

      // Draw the circle
      canvas.drawCircle(offset, radius, paint);

      // Draw the word inside the circle
      final textSpan = TextSpan(text: words[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      final textOffset = Offset(
        offset.dx - textPainter.width / 2,
        offset.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, textOffset);
    }

    // Draw the edges
    for (final edge in edges) {
      final start = positions[edge.startIndex];
      final end = positions[edge.endIndex];
      final angle = atan2(end.dy - start.dy, end.dx - start.dx);

      // Calculate new start and end points that touch the circumference of the circles
      final startX = start.dx + radius * cos(angle);
      final startY = start.dy + radius * sin(angle);
      final endX = end.dx - radius * cos(angle);
      final endY = end.dy - radius * sin(angle);

      final startPoint = Offset(startX, startY);
      final endPoint = Offset(endX, endY);

      // Draw the line
      canvas.drawLine(startPoint, endPoint, paint);

      // Draw the arrowhead
      final arrowSize = 10.0;
      final arrowAngle = pi / 6;
      final path = Path();
      path.moveTo(endPoint.dx, endPoint.dy);
      path.lineTo(
        endPoint.dx - arrowSize * cos(angle - arrowAngle),
        endPoint.dy - arrowSize * sin(angle - arrowAngle),
      );
      path.moveTo(endPoint.dx, endPoint.dy);
      path.lineTo(
        endPoint.dx - arrowSize * cos(angle + arrowAngle),
        endPoint.dy - arrowSize * sin(angle + arrowAngle),
      );
      canvas.drawPath(path, paint);

      // Draw the label background
      final labelSpan = TextSpan(text: edge.label, style: textStyle);
      final labelPainter = TextPainter(
        text: labelSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(minWidth: 0, maxWidth: size.width);
      final labelOffset = Offset(
        (startPoint.dx + endPoint.dx) / 2 - labelPainter.width / 2,
        (startPoint.dy + endPoint.dy) / 2 - labelPainter.height / 2,
      );

      // Draw a background rectangle for the label
      final backgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final backgroundRect = Rect.fromLTWH(
        labelOffset.dx - 2,
        labelOffset.dy - 2,
        labelPainter.width + 4,
        labelPainter.height + 4,
      );

      canvas.drawRect(backgroundRect, backgroundPaint);
      canvas.drawRect(backgroundRect, paint); // Add a border to the rectangle

      // Draw the label
      labelPainter.paint(canvas, labelOffset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Ensure that the painter repaints when needed
  }
}

