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

      if (start == end) {
        // Draw a self-loop
        const loopRadius = 60.0; // Radius for the loop slightly larger than node's radius

        // Define start and end points on the circumference of the circle
        final startX = start.dx + radius * cos(-pi / 4);
        final startY = start.dy + radius * sin(-pi / 4);
        final endX = start.dx + radius * cos(-pi / 4 - pi / 2);
        final endY = start.dy + radius * sin(-pi / 4 - pi / 2);

        // Define control points for the Bezier curve
        final controlPoint1 = Offset(start.dx + loopRadius, start.dy - loopRadius);
        final controlPoint2 = Offset(start.dx - loopRadius, start.dy - loopRadius);

        final path = Path();
        path.moveTo(startX, startY);
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          endX, endY,
        );

        canvas.drawPath(path, paint);

        // Draw the arrowhead for the self-loop
        const arrowSize = 10.0;
        const arrowAngle = pi / 6; // Adjusted angle for a better arrowhead
        final pathArrow = Path();

        // First side of the arrowhead
        pathArrow.moveTo(endX, endY);
        pathArrow.lineTo(
          endX - arrowSize * cos(arrowAngle + pi / 4),
          endY - arrowSize * sin(arrowAngle + pi / 4),
        );

        // Second side of the arrowhead
        pathArrow.moveTo(endX, endY);
        pathArrow.lineTo(
          endX - arrowSize * cos(-arrowAngle + pi / 4),
          endY - arrowSize * sin(-arrowAngle + pi / 4),
        );
        canvas.drawPath(pathArrow, paint);

        // Draw the label for the self-loop
        final labelSpan = TextSpan(text: edge.labels.join(', '), style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout(minWidth: 0, maxWidth: size.width);
        final labelOffset = Offset(
          start.dx - labelPainter.width / 2,
          start.dy - loopRadius,
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
      } else {
        // Draw a normal edge with a slight bend
        final angle = atan2(end.dy - start.dy, end.dx - start.dx);

        // Calculate a perpendicular offset
        const perpendicularOffset = -5.0;
        final perpAngle = angle + pi / 2;
        final offsetX = perpendicularOffset * cos(perpAngle);
        final offsetY = perpendicularOffset * sin(perpAngle);

        // Calculate new start and end points that touch the circumference of the circles
        final startX = start.dx + radius * cos(angle) + offsetX;
        final startY = start.dy + radius * sin(angle) + offsetY;
        final endX = end.dx - radius * cos(angle) + offsetX;
        final endY = end.dy - radius * sin(angle) + offsetY;

        final startPoint = Offset(startX, startY);
        final endPoint = Offset(endX, endY);
        // Define control point for the Bezier curve
        final midPoint = Offset((startPoint.dx + endPoint.dx) / 2, (startPoint.dy + endPoint.dy) / 2);
        const double bendAmount = 80.0; // Adjust this value to increase or decrease the curvature
        final controlPoint = Offset(
          midPoint.dx + bendAmount * sin(angle), // Adjust the bend amount
          midPoint.dy - bendAmount * cos(angle),
        );

        final path = Path();
        path.moveTo(startPoint.dx, startPoint.dy);
        path.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy,
          endPoint.dx, endPoint.dy,
        );

        canvas.drawPath(path, paint);

        // Calculate the tangent at the end point of the Bezier curve
        const double t = 0.95; // Value close to 1 for point near the end
        final tangentPointX = (1 - t) * (1 - t) * startPoint.dx +
            2 * (1 - t) * t * controlPoint.dx +
            t * t * endPoint.dx;
        final tangentPointY = (1 - t) * (1 - t) * startPoint.dy +
            2 * (1 - t) * t * controlPoint.dy +
            t * t * endPoint.dy;
        final tangentAngle = atan2(endPoint.dy - tangentPointY, endPoint.dx - tangentPointX);

        // Draw the arrowhead
        const arrowSize = 10.0;
        const arrowAngle = pi / 6;
        final pathArrow = Path();
        pathArrow.moveTo(endPoint.dx, endPoint.dy);
        pathArrow.lineTo(
          endPoint.dx - arrowSize * cos(tangentAngle - arrowAngle),
          endPoint.dy - arrowSize * sin(tangentAngle - arrowAngle),
        );
        pathArrow.moveTo(endPoint.dx, endPoint.dy);
        pathArrow.lineTo(
          endPoint.dx - arrowSize * cos(tangentAngle + arrowAngle),
          endPoint.dy - arrowSize * sin(tangentAngle + arrowAngle),
        );
        canvas.drawPath(pathArrow, paint);

        // Draw the label background
        final labelSpan = TextSpan(text: edge.labels.join(', '), style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout(minWidth: 0, maxWidth: size.width);

        // Calculate label position along the curved edge
        final labelX = (startPoint.dx + endPoint.dx) / 2 - labelPainter.width / 2 + bendAmount / 2 * sin(angle);
        final labelY = (startPoint.dy + endPoint.dy) / 2 - labelPainter.height / 2 - bendAmount / 2 * cos(angle);
        final labelOffset = Offset(labelX, labelY);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Ensure that the painter repaints when needed
  }
}