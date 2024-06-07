import 'package:flutter/material.dart';
import 'dart:math';
import 'circle_painter.dart';
import 'edges_painter.dart';
import 'draggable_node.dart';
import 'draggable_edge.dart';
import 'draggable_start.dart';


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
  late List<Edge> edges;
  late Set<int> startStates;
  final Map<Edge, GlobalKey<DraggableEdgeState>> edgeKeys = {};
  final Map<int, GlobalKey<DraggableStartState>> startStateKeys = {};

  @override
  void initState() {
    super.initState();
    nodes = [];
    edges = [];
    startStates = {};
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
        newNodes.add(Node(words[i], nodes[i].position, 21.0, startAngle: nodes[i].startAngle)); // Keep existing node positions
      } else {
        newNodes.add(Node(words[i], position, 21.0)); // Add new nodes with calculated positions
      }
    }

    setState(() {
      nodes = newNodes;
      final edgesClass = Edges(widget.lines, nodes.map((node) => node.label).toList());
      edges = edgesClass.edges;
      startStates = edgesClass.startStates;

      // Initialize bendAmount based on the edge conditions
      final edgeMap = <String, Edge>{};
      for (var edge in edges) {
        final key = '${edge.startIndex}-${edge.endIndex}';
        edgeMap[key] = edge;
      }

      for (var edge in edges) {
        final reverseKey = '${edge.endIndex}-${edge.startIndex}';
        if (edgeMap.containsKey(reverseKey)) {
          edge.bendAmount = 80.0;
          edgeMap[reverseKey]!.bendAmount = 80.0;
        } else {
          edge.bendAmount = 0.0;
        }
      }

      // Initialize control points and label positions
      _updateEdgeControlPoints();
    });
  }

  void _updateNodePosition(int index, Offset newPosition) {
    setState(() {
      nodes[index].position = newPosition;
      _updateEdgeControlPoints(); // Recalculate edge control points and labels
      _updateStartStatePositions(); // Recalculate start state positions
    });
  }

  void _updateEdgeControlPoints() {
    for (var edge in edges) {
      final midPoint = _calculateMidPoint(edge);
      final angle = _calculateAngle(edge);
      edge.controlPoint = Offset(midPoint.dx + edge.bendAmount * sin(angle), midPoint.dy - edge.bendAmount * cos(angle));
      edge.labelPosition = _calculateLabelPosition(edge, midPoint);

      // Update the position of the draggable edge
      if (edgeKeys.containsKey(edge)) {
        edgeKeys[edge]?.currentState?.updatePosition(edge.labelPosition!);
      }
    }
  }

  void _updateStartStatePositions() {
    for (var startIndex in startStates) {
      final key = startStateKeys[startIndex];
      if (key != null) {
        key.currentState?.updatePosition(nodes[startIndex].position, nodes[startIndex].startAngle);
      }
    }
  }

  void _updateControlPoint(Edge edge, double perpendicularMovement) {
    setState(() {
      // Clamp the bend amount to prevent excessive values
      edge.bendAmount = (edge.bendAmount + perpendicularMovement).clamp(-500.0, 500.0);
      final midPoint = _calculateMidPoint(edge);
      final angle = _calculateAngle(edge);
      edge.controlPoint = Offset(midPoint.dx + edge.bendAmount * sin(angle), midPoint.dy - edge.bendAmount * cos(angle));
      edge.labelPosition = _calculateLabelPosition(edge, midPoint); // Update label position
    });
  }

  Offset _calculateMidPoint(Edge edge) {
    final start = nodes[edge.startIndex].position;
    final end = nodes[edge.endIndex].position;
    return Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
  }

  double _calculateAngle(Edge edge) {
    final start = nodes[edge.startIndex].position;
    final end = nodes[edge.endIndex].position;
    return atan2(end.dy - start.dy, end.dx - start.dx);
  }

  Offset _calculateLabelPosition(Edge edge, Offset midPoint) {
    final angle = _calculateAngle(edge);
    return Offset(midPoint.dx + edge.bendAmount * sin(angle) / 2, midPoint.dy - edge.bendAmount * cos(angle) / 2);
  }

  void _updateStartAngle(int nodeIndex, double angle) {
    setState(() {
      nodes[nodeIndex].startAngle = angle;
    });
  }

  @override
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 1.25;
    double displayHeight = MediaQuery.of(context).size.height / 1.25;

    if (nodes.isEmpty) {
      _initializeNodes();
    }

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
              painter: CirclePainter(nodes, edges, startStates),
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
            for (final edge in edges)
              if (edge.labelPosition != null && edge.startIndex != edge.endIndex) // Exclude loop edges
                DraggableEdge(
                  key: edgeKeys.putIfAbsent(edge, () => GlobalKey<DraggableEdgeState>()),
                  labelPosition: edge.labelPosition!,
                  onControlPointChanged: (perpendicularMovement) => _updateControlPoint(edge, perpendicularMovement),
                  angle: _calculateAngle(edge),
                  label: edge.labels.join(', '),
                ),
            for (final startIndex in startStates)
              DraggableStart(
                key: startStateKeys.putIfAbsent(startIndex, () => GlobalKey<DraggableStartState>()),
                nodePosition: nodes[startIndex].position,
                nodeRadius: nodes[startIndex].radius,
                onAngleChanged: (newAngle) => _updateStartAngle(startIndex, newAngle),
                startAngle: nodes[startIndex].startAngle,
              ),
          ],
        ),
      ),
    );
  }
}
