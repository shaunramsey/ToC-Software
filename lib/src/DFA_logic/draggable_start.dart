import 'package:flutter/material.dart';
import 'dart:math';

class DraggableStart extends StatefulWidget {
  final Offset nodePosition;
  final double nodeRadius;
  final Function(double) onAngleChanged;
  final double startAngle;

  const DraggableStart({
    super.key,
    required this.nodePosition,
    required this.nodeRadius,
    required this.onAngleChanged,
    required this.startAngle,
  });

  @override
  State<DraggableStart> createState() => _DraggableStartState();

}

class _DraggableStartState extends State<DraggableStart> {
  late Offset position;
  late Size labelSize;

  @override
  void initState() {
    super.initState();
    _setPosition(widget.startAngle);

    // Calculate the initial label size
    final textPainter = TextPainter(
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
    textPainter.layout();
    labelSize = textPainter.size;
  }

  void _setPosition(double angle) {
    position = Offset(
      widget.nodePosition.dx + (widget.nodeRadius + 37) * cos(angle),
      widget.nodePosition.dy + (widget.nodeRadius + 37) * sin(angle),
    );
  }

  void _updatePosition(Offset newPosition) {
    final dx = newPosition.dx - widget.nodePosition.dx;
    final dy = newPosition.dy - widget.nodePosition.dy;
    final angle = atan2(dy, dx);
    widget.onAngleChanged(angle);
    _setPosition(angle); // Update position based on the new angle
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - labelSize.width / 2,
      top: position.dy - labelSize.height / 2,
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
            // Reset the position to align with the label after dragging
            _setPosition(widget.startAngle);
          });
        },
        child: Container(
          width: labelSize.width,
          height: labelSize.height,
          color: Colors.green,
        ),
      ),
    );
  }
}
