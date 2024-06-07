import 'package:flutter/material.dart';
import 'dart:math';

class Node {
  final String label;
  Offset position;
  final double radius;
  double startAngle; // Add this property

  Node(this.label, this.position, this.radius, {this.startAngle = -pi / 2});
}





class DraggableNode extends StatefulWidget {
  final Node node;
  final Function(Offset) onPositionChanged;

  const DraggableNode({super.key, required this.node, required this.onPositionChanged});

  @override
  State<DraggableNode> createState() => _DraggableNodeState();

}

class _DraggableNodeState extends State<DraggableNode> {
  Offset position = Offset.zero;

  @override
  void initState() {
    super.initState();
    position = widget.node.position;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          position += details.delta;
        });
        widget.onPositionChanged(position);
      },
      child: Container(
        width: widget.node.radius * 2,
        height: widget.node.radius * 2,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
      ),
    );
  }
}
