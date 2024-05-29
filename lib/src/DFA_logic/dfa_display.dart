import 'package:flutter/material.dart';
import 'dart:math';
import 'circle_painter.dart';
import 'edges_painter.dart';
import 'draggable_node.dart';





class DFADisplay extends StatefulWidget {
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
  State<DFADisplay> createState() => _DFADisplayState();
}

class _DFADisplayState extends State<DFADisplay> {
  late List<Node> nodes;

  @override
  void initState() {
    super.initState();
    nodes = [];
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeNodes());
  }

  @override
  void didUpdateWidget(covariant DFADisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lines != oldWidget.lines) {
      _initializeNodes();
    }
  }

  void _initializeNodes() {
    List<String> wordsSplit = widget.lines.isNotEmpty ? widget.lines[0].trim().split(' ') : [];
    List<String> words = [];
    for (int i = 0; i < wordsSplit.length; i++) {
      String s = wordsSplit[i].trim();
      if (s.isNotEmpty) {
        words.add(s);
      }
    }

    final displayWidth = MediaQuery.of(context).size.width / 1.25;
    final displayHeight = MediaQuery.of(context).size.height / 1.25;
    final center = Offset(displayWidth / 2, displayHeight / 2);
    final radiusX = (displayWidth / 2) - 100;
    final radiusY = (displayHeight / 2) - 100;
    final angleIncrement = (2 * pi) / words.length;

    List<Node> newNodes = [];
    for (int i = 0; i < words.length; i++) {
      final angle = angleIncrement * i;
      final position = Offset(
        center.dx + radiusX * cos(angle),
        center.dy + radiusY * sin(angle),
      );
      if (i < nodes.length) {
        newNodes.add(Node(words[i], nodes[i].position, 21.0)); // Keep existing node positions
      } else {
        newNodes.add(Node(words[i], position, 21.0)); // Add new nodes with calculated positions
      }
    }

    setState(() {
      nodes = newNodes;
    });
  }

  void _updateNodePosition(int index, Offset newPosition) {
    setState(() {
      nodes[index].position = newPosition;
    });
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 1.25;
    double displayHeight = MediaQuery.of(context).size.height / 1.25;

    if (nodes.isEmpty) {
      _initializeNodes();
    }

    final edges = Edges(widget.lines, nodes.map((node) => node.label).toList()).edges;

    return Positioned(
      left: widget.left,
      top: widget.top,
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
        child: Stack(
          children: [
            CustomPaint(
              painter: CirclePainter(nodes, edges),
              child: Container(), // Add this to ensure child is not null
            ),
            for (int i = 0; i < nodes.length; i++)
              Positioned(
                left: nodes[i].position.dx - nodes[i].radius,
                top: nodes[i].position.dy - nodes[i].radius,
                child: DraggableNode(
                  node: nodes[i],
                  onPositionChanged: (newPosition) => _updateNodePosition(i, newPosition),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


