import 'package:flutter/material.dart';
import 'dart:math'; // Import the dart:math library

class CirclePainter extends CustomPainter {
  final List<String> words;

  CirclePainter(this.words);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    const textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
    );

    const radius = 20.0; // Radius of each circle
    final center = Offset(size.width / 2, size.height / 2); // Center point
    final angle = (2 * 3.141592653589793) / words.length; // Angle for each circle

    for (int i = 0; i < words.length; i++) {
      final offset = Offset(
        center.dx + (size.width / 3) * cos(angle * i), // X position
        center.dy + (size.height / 3) * sin(angle * i), // Y position
      );

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
