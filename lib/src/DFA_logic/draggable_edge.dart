import 'package:flutter/material.dart';
import 'dart:math';

class DraggableEdge extends StatefulWidget {
  final Offset labelPosition;
  final Function(double) onControlPointChanged;
  final double angle;
  final String label;

  const DraggableEdge({
    super.key,
    required this.labelPosition,
    required this.onControlPointChanged,
    required this.angle,
    required this.label,
  });

  @override
  DraggableEdgeState createState() => DraggableEdgeState();
}

class DraggableEdgeState extends State<DraggableEdge> {
  late Offset position;
  late Size labelSize;

  @override
  void initState() {
    super.initState();
    position = widget.labelPosition;

    // Calculate the label size based on the actual label text
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.label,
        style: const TextStyle(
          color: Colors.transparent,
          fontSize: 15,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    labelSize = textPainter.size;
  }

  void _updatePosition(Offset newPosition) {
    final dx = newPosition.dx - widget.labelPosition.dx;
    final dy = newPosition.dy - widget.labelPosition.dy;

    // Calculate the perpendicular movement relative to the edge's angle
    final perpendicularMovement = dx * sin(widget.angle) - dy * cos(widget.angle);

    // Update the bend amount
    widget.onControlPointChanged(perpendicularMovement);
  }

  void updatePosition(Offset newPosition) {
    setState(() {
      position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double xOffset = -8; // Adjust this value as needed
    const double yOffset = -8; // Adjust this value as needed

    return Positioned(
      left: position.dx - labelSize.width / 2 + xOffset,
      top: position.dy - labelSize.height / 2 + yOffset,
      child: GestureDetector(
        onPanUpdate: (details) {
          final newPosition = position + details.delta;
          _updatePosition(newPosition);
          setState(() {
            position = newPosition;
          });
        },
        onPanEnd: (details) {
          setState(() {
            position = widget.labelPosition; // Reset the position to align with the label after dragging
          });
        },
        child: Container(
          width: labelSize.width + 16,  // Increase width to match label size
          height: labelSize.height + 16, // Increase height to match label size
          color: Colors.green,
        ),
      ),
    );
  }
}
