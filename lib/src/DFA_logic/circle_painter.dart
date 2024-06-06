import 'package:flutter/material.dart';
import 'dart:math';
import 'edges_painter.dart';
import 'draggable_node.dart';



class CirclePainter extends CustomPainter {
  final List<Node> nodes;
  final List<Edge> edges;
  final Set<int> startStates;

  CirclePainter(this.nodes, this.edges, this.startStates);

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) {
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

    for (final node in nodes) {
      final offset = node.position;
      canvas.drawCircle(offset, node.radius, paint);

      final textSpan = TextSpan(text: node.label, style: textStyle);
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

    for (final edge in edges) {
      final start = nodes[edge.startIndex].position;
      final end = nodes[edge.endIndex].position;
      final radius = nodes[edge.startIndex].radius;


      if (start == end) {
        // Draw a self-loop
        const loopRadius = 111.0; // Radius for the loop slightly larger than node's radius

        // Calculate the angle from the center of the container to the node
        final containerCenter = Offset(size.width / 2, size.height / 2);
        final angleToCenter = atan2(start.dy - containerCenter.dy, start.dx - containerCenter.dx);

        // Define start and end points on the circumference of the circle
        final startX = start.dx + radius * cos(angleToCenter - pi / 6);
        final startY = start.dy + radius * sin(angleToCenter - pi / 6);
        final endX = start.dx + radius * cos(angleToCenter + pi / 6);
        final endY = start.dy + radius * sin(angleToCenter + pi / 6);

        // Define control points for the Bezier curve
        final controlPoint1 = Offset(start.dx + loopRadius * cos(angleToCenter - pi / 4), start.dy + loopRadius * sin(angleToCenter - pi / 4));
        final controlPoint2 = Offset(start.dx + loopRadius * cos(angleToCenter + pi / 4), start.dy + loopRadius * sin(angleToCenter + pi / 4));

        final path = Path();
        path.moveTo(startX, startY);
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          endX, endY,
        );

        canvas.drawPath(path, paint);

        // Calculate the tangent at the end point of the Bezier curve
        const double t = 0.95; // Value close to 1 for point near the end
        final tangentPointX = (1 - t) * (1 - t) * startX +
            2 * (1 - t) * t * controlPoint2.dx +
            t * t * endX;
        final tangentPointY = (1 - t) * (1 - t) * startY +
            2 * (1 - t) * t * controlPoint2.dy +
            t * t * endY;
        final tangentAngle = atan2(endY - tangentPointY, endX - tangentPointX);

        // Draw the arrowhead for the self-loop
        const arrowSize = 10.0;
        const arrowAngle = pi / 6; // Adjusted angle for a better arrowhead
        final pathArrow = Path();

        // First side of the arrowhead
        pathArrow.moveTo(endX, endY);
        pathArrow.lineTo(
          endX - arrowSize * cos(tangentAngle - arrowAngle),
          endY - arrowSize * sin(tangentAngle - arrowAngle),
        );

        // Second side of the arrowhead
        pathArrow.moveTo(endX, endY);
        pathArrow.lineTo(
          endX - arrowSize * cos(tangentAngle + arrowAngle),
          endY - arrowSize * sin(tangentAngle + arrowAngle),
        );
        canvas.drawPath(pathArrow, paint);


        // Calculate the midpoint of the Bezier curve for the label
        const double tLabel = 0.5; // Value for midpoint
        final double labelMidPointX = (1 - tLabel) * (1 - tLabel) * (1 - tLabel) * startX +
            3 * (1 - tLabel) * (1 - tLabel) * tLabel * controlPoint1.dx +
            3 * (1 - tLabel) * tLabel * tLabel * controlPoint2.dx +
            tLabel * tLabel * tLabel * endX;
        final double labelMidPointY = (1 - tLabel) * (1 - tLabel) * (1 - tLabel) * startY +
            3 * (1 - tLabel) * (1 - tLabel) * tLabel * controlPoint1.dy +
            3 * (1 - tLabel) * tLabel * tLabel * controlPoint2.dy +
            tLabel * tLabel * tLabel * endY;

        // Draw the label for the self-loop
        final labelSpan = TextSpan(text: edge.labels.join(', '), style: textStyle);
        final labelPainter = TextPainter(
          text: labelSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout(minWidth: 0, maxWidth: size.width);
        final labelOffset = Offset(
          labelMidPointX - labelPainter.width / 2,
          labelMidPointY - labelPainter.height / 2,
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

      } else  {
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
        double bendAmount = edge.bendAmount; // Use the edge's bendAmount

        Offset controlPoint = Offset(
          midPoint.dx + bendAmount * sin(angle),
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


        // Calculate label position along the curved edge
        final labelPainter = TextPainter(
          text: TextSpan(text: edge.labels.join(', '), style: textStyle),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout(minWidth: 0, maxWidth: size.width);

        final labelX = (startPoint.dx + endPoint.dx) / 2 - labelPainter.width / 2 + bendAmount / 2 * sin(angle);
        final labelY = (startPoint.dy + endPoint.dy) / 2 - labelPainter.height / 2 - bendAmount / 2 * cos(angle);
        final labelOffset = Offset(labelX, labelY);

        // Store the label position in the edge object
        edge.labelPosition = labelOffset;

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

// Draw start arrows
    for (final startIndex in startStates) {
      final node = nodes[startIndex];
      final offset = node.position;
      final radius = node.radius;
      final angle = node.startAngle; // Use the start angle

      final startX = offset.dx + (radius + 50) * cos(angle); // Increase arrow length
      final startY = offset.dy + (radius + 50) * sin(angle); // Increase arrow length
      final endX = offset.dx + radius * cos(angle);
      final endY = offset.dy + radius * sin(angle);

      final path = Path();
      path.moveTo(startX, startY);
      path.lineTo(endX, endY);

      canvas.drawPath(path, paint);

      // Draw the arrowhead
      const arrowSize = 10.0;
      const arrowAngle = pi / 6;
      final pathArrow = Path();
      pathArrow.moveTo(endX, endY);
      pathArrow.lineTo(
        endX + arrowSize * cos(angle - arrowAngle), // Inversed arrowhead direction
        endY + arrowSize * sin(angle - arrowAngle), // Inversed arrowhead direction
      );
      pathArrow.moveTo(endX, endY);
      pathArrow.lineTo(
        endX + arrowSize * cos(angle + arrowAngle), // Inversed arrowhead direction
        endY + arrowSize * sin(angle + arrowAngle), // Inversed arrowhead direction
      );
      canvas.drawPath(pathArrow, paint);

      // Calculate the label position for the start arrow
      final labelPainter = TextPainter(
        text: const TextSpan(
          text: 'start',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout(minWidth: 0, maxWidth: size.width);

      final labelOffset = Offset(
        startX + (endX - startX) * 0.25 - labelPainter.width / 2, // Adjust to 1/4 from the start
        startY + (endY - startY) * 0.25 - labelPainter.height / 2, // Adjust to 1/4 from the start
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