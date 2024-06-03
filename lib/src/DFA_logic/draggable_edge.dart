import 'package:flutter/material.dart';

class DraggableEdge extends StatelessWidget {
  final Offset labelPosition;
  final Function(double) onControlPointChanged;
  final double angle;

  const DraggableEdge({
    super.key,
    required this.labelPosition,
    required this.onControlPointChanged,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: labelPosition.dx - 20, // Center the draggable area on the label position
      top: labelPosition.dy - 10,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Adjust the bend amount based on vertical dragging
          final deltaY = details.delta.dy;
          onControlPointChanged(deltaY);
        },
        child: Container(
          width: 50,
          height: 30,
          color: Colors.transparent, // Make the dragging area transparent but responsive to touch
        ),
      ),
    );
  }
}
