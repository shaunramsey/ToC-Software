import 'package:flutter/material.dart';
import 'dfa_logic.dart';
import 'dart:math';
import 'main.dart';
import 'dragging.dart';
// import 'dfa_logic.dart';  // Import the DFA logic file
// import 'dart:math';
// import 'dragging.dart';
//
//

class ScreenSizeCondition {
  final void Function(List<Node> updatedNodes, List<Edge> updatedNonLoopedEdges, List<Edge> updatedLoopedEdges) onDFAUpdated;
  Size _oldSize = Size.zero;

  ScreenSizeCondition({required this.onDFAUpdated});

  void handleScreenSizeChange(BuildContext context) {
    final newSize = MediaQuery.of(context).size;
    ImportantStuff importantStuff = ImportantStuff();
    final oldSize = importantStuff.getOldCanvasSize();

    if (_oldSize == Size.zero) {
      _oldSize = newSize;
      importantStuff.setOldCanvasSize(newSize);
    } else if (oldSize != newSize) {
      _onScreenSizeChanged(oldSize, newSize);
      importantStuff.setOldCanvasSize(newSize);
      _oldSize = newSize;
    }
  }

  void _onScreenSizeChanged(Size oldSize, Size newSize) {
    final ratioX = oldSize.width / newSize.width;
    final ratioY = oldSize.height / newSize.height;

    // Get the current nodes and edges from ImportantStuff singleton
    ImportantStuff importantStuff = ImportantStuff();
    List<Node> nodes = importantStuff.getNodes();
    List<Edge> nonLoopedEdges = importantStuff.getNonLoopedEdges();
    List<Edge> loopedEdges = importantStuff.getLoopedEdges();

    // Update the nodes based on the ratio
    for (var node in nodes) {
      node.x /= ratioX;
      node.y /= ratioY;
    }

    // Debug print for node positions
    for (var node in nodes) {
      print('Node ${node.name}: (${node.x}, ${node.y})');
    }

    // Update the edges based on the updated nodes
    for (var edge in nonLoopedEdges) {
      edge.startNode = nodes.firstWhere((node) => node.name == edge.startNode.name);
      edge.endNode = nodes.firstWhere((node) => node.name == edge.endNode.name);
    }

    for (var edge in loopedEdges) {
      edge.startNode = nodes.firstWhere((node) => node.name == edge.startNode.name);
      edge.endNode = nodes.firstWhere((node) => node.name == edge.endNode.name);
    }

    // Update the ImportantStuff singleton with the new nodes and edges
    importantStuff.setNodes(nodes);
    importantStuff.setNonLoopedEdges(nonLoopedEdges);
    importantStuff.setLoopedEdges(loopedEdges);

    // Call the provided callback to redraw the canvas
    onDFAUpdated(nodes, nonLoopedEdges, loopedEdges);
  }
}


class DFACanvas extends StatefulWidget {
  final double left;
  final double top;
  final double sizeX;
  final double sizeY;
  final List<Node> nodes;
  final List<Edge> nonLoopedEdges;
  final List<Edge> loopedEdges;

  const DFACanvas({
    super.key,
    required this.left,
    required this.top,
    required this.sizeX,
    required this.sizeY,
    required this.nodes,
    required this.nonLoopedEdges,
    required this.loopedEdges,
  });

  @override
  _DFACanvasState createState() => _DFACanvasState();
}

class _DFACanvasState extends State<DFACanvas> {
  Node? draggingNode;
  Edge? draggingEdge;
  Offset? initialDragPosition;
  double initialBendAngle = 0.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: GestureDetector(
        onPanStart: (details) {
          final dx = details.localPosition.dx;
          final dy = details.localPosition.dy;

          for (var node in widget.nodes) {
            final distance = (node.x - dx) * (node.x - dx) + (node.y - dy) * (node.y - dy);
            if (distance <= node.radius * node.radius) {
              draggingNode = node;
              return;
            }
          }

          for (var edge in widget.nonLoopedEdges) {
            final angle = atan2(edge.endNode.y - edge.startNode.y, edge.endNode.x - edge.startNode.x);
            final startX = edge.startNode.x + edge.startNode.radius * cos(angle + edge.startAngleOffset);
            final startY = edge.startNode.y + edge.startNode.radius * sin(angle + edge.startAngleOffset);
            final endX = edge.endNode.x - edge.endNode.radius * cos(angle + edge.endAngleOffset);
            final endY = edge.endNode.y - edge.endNode.radius * sin(angle + edge.endAngleOffset);

            final midX = (startX + endX) / 2;
            final midY = (startY + endY) / 2;
            final controlX = midX + edge.bendAngle * sin(atan2(endY - startY, endX - startX));
            final controlY = midY - edge.bendAngle * cos(atan2(endY - startY, endX - startX));

            final midpointX = (startX + 2 * controlX + endX) / 4;
            final midpointY = (startY + 2 * controlY + endY) / 4;

            final dragDistance = sqrt((midpointX - dx) * (midpointX - dx) + (midpointY - dy) * (midpointY - dy));
            if (dragDistance < 20) { // Check if within the draggable area
              draggingEdge = edge;
              initialDragPosition = details.localPosition;
              initialBendAngle = edge.bendAngle;
              return;
            }
          }
        },
        onPanUpdate: (details) {
          if (draggingNode != null) {
            setState(() {
              draggingNode!.x += details.delta.dx;
              draggingNode!.y += details.delta.dy;
            });
          } else if (draggingEdge != null) {
            final dx = details.localPosition.dx - initialDragPosition!.dx;
            final dy = details.localPosition.dy - initialDragPosition!.dy;

            // Calculate original midpoint and angles
            final originalMidX = (draggingEdge!.startNode.x + draggingEdge!.endNode.x) / 2;
            final originalMidY = (draggingEdge!.startNode.y + draggingEdge!.endNode.y) / 2;
            final originalAngle = atan2(draggingEdge!.endNode.y - draggingEdge!.startNode.y, draggingEdge!.endNode.x - draggingEdge!.startNode.x);
            final perpendicularAngle = originalAngle - pi / 2;

            // Calculate new bend value along the perpendicular direction
            final sliderValue = dx * cos(perpendicularAngle) + dy * sin(perpendicularAngle);
            setState(() {
              draggingEdge!.bendAngle = initialBendAngle + sliderValue;
            });
          }
        },
        onPanEnd: (details) {
          draggingNode = null;
          draggingEdge = null;
          initialDragPosition = null;
        },
        child: Stack(
          children: [
            Container(
              width: widget.sizeX,
              height: widget.sizeY,
              decoration: BoxDecoration(
                color: Colors.grey[200], // Changed to light grey
                border: Border.all(color: Colors.black),
              ),
            ),
            ...widget.nodes.map((node) => Positioned(
              left: node.x - node.radius,
              top: node.y - node.radius,
              child: Container(
                width: node.radius * 2,
                height: node.radius * 2,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2), // Transparent color for debugging
                  shape: BoxShape.circle,
                ),
              ),
            )),
            CustomPaint(
              size: Size(widget.sizeX, widget.sizeY),
              painter: DFANodePainter(widget.nodes),
            ),
            CustomPaint(
              size: Size(widget.sizeX, widget.sizeY),
              painter: DFAEdgeNonloopPainter(widget.nonLoopedEdges),
            ),
            CustomPaint(
              size: Size(widget.sizeX, widget.sizeY),
              painter: DFAEdgeLoopPainter(widget.loopedEdges),
            ),
            CustomPaint(
              size: Size(widget.sizeX, widget.sizeY),
              painter: DFAStartNodePainter(widget.nodes),
            ),
            ...widget.nonLoopedEdges.map((edge) {
              // Calculate the midpoint of the Bezier curve
              final angle = atan2(edge.endNode.y - edge.startNode.y, edge.endNode.x - edge.startNode.x);
              final startX = edge.startNode.x + edge.startNode.radius * cos(angle + edge.startAngleOffset);
              final startY = edge.startNode.y + edge.startNode.radius * sin(angle + edge.startAngleOffset);
              final endX = edge.endNode.x - edge.endNode.radius * cos(angle + edge.endAngleOffset);
              final endY = edge.endNode.y - edge.endNode.radius * sin(angle + edge.endAngleOffset);

              final midX = (startX + endX) / 2;
              final midY = (startY + endY) / 2;
              final controlX = midX + edge.bendAngle * sin(atan2(endY - startY, endX - startX));
              final controlY = midY - edge.bendAngle * cos(atan2(endY - startY, endX - startX));

              final midpointX = (startX + 2 * controlX + endX) / 4;
              final midpointY = (startY + 2 * controlY + endY) / 4;

              return Positioned(
                left: midpointX - 20, // Adjust based on desired draggable area size
                top: midpointY - 20, // Adjust based on desired draggable area size
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2), // Transparent color for debugging
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}





class DFANodePainter extends CustomPainter {
  final List<Node> nodes;

  DFANodePainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke;

    final Paint outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint endStatePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    for (Node node in nodes) {
      // Draw the filled circle
      canvas.drawCircle(Offset(node.x, node.y), node.radius, nodePaint);

      // Draw the circle outline
      canvas.drawCircle(Offset(node.x, node.y), node.radius, outlinePaint);

      // Draw the node name
      TextSpan textSpan = TextSpan(text: node.name, style: textStyle);
      TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          node.x - textPainter.width / 2,
          node.y - textPainter.height / 2,
        ),
      );
    }

    // Draw smaller circle for end states
    for (Node node in nodes) {
      if (node.isEndState) {
        canvas.drawCircle(Offset(node.x, node.y), node.radius - 5, endStatePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}




class DFAEdgeNonloopPainter extends CustomPainter {
  final List<Edge> edges;

  DFAEdgeNonloopPainter(this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint edgePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint boxPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint boxOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    for (Edge edge in edges) {
      // Calculate the positions of the Bezier curve
      final angle = atan2(edge.endNode.y - edge.startNode.y, edge.endNode.x - edge.startNode.x);
      final startX = edge.startNode.x + edge.startNode.radius * cos(angle + edge.startAngleOffset);
      final startY = edge.startNode.y + edge.startNode.radius * sin(angle + edge.startAngleOffset);
      final endX = edge.endNode.x - edge.endNode.radius * cos(angle + edge.endAngleOffset);
      final endY = edge.endNode.y - edge.endNode.radius * sin(angle + edge.endAngleOffset);

      // Calculate control point for Bezier curve
      final midX = (startX + endX) / 2;
      final midY = (startY + endY) / 2;
      final controlX = midX + edge.bendAngle * sin(atan2(endY - startY, endX - startX));
      final controlY = midY - edge.bendAngle * cos(atan2(endY - startY, endX - startX));

      final Path path = Path()
        ..moveTo(startX, startY)
        ..quadraticBezierTo(controlX, controlY, endX, endY);

      // Draw the edge (Bezier curve)
      canvas.drawPath(path, edgePaint);

      // Calculate the midpoint for the label
      final midpointX = (startX + 2 * controlX + endX) / 4;
      final midpointY = (startY + 2 * controlY + endY) / 4;
      final labelPosition = Offset(midpointX, midpointY);

      // Prepare the weights text
      String weightsText = edge.weights.join(', ');

      // Draw the label
      TextSpan textSpan = TextSpan(text: weightsText, style: textStyle);
      TextPainter textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      // Calculate the dimensions of the box around the label
      final double boxPadding = 4.0;
      final double boxWidth = textPainter.width + boxPadding * 2;
      final double boxHeight = textPainter.height + boxPadding * 2;
      final Offset boxTopLeft = Offset(
        labelPosition.dx - boxWidth / 2,
        labelPosition.dy - boxHeight / 2,
      );

      // Draw the filled box behind the label
      canvas.drawRect(
        Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
        boxPaint,
      );

      // Draw the box outline
      canvas.drawRect(
        Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
        boxOutlinePaint,
      );

      // Draw the text over the box
      textPainter.paint(
        canvas,
        Offset(
          labelPosition.dx - textPainter.width / 2,
          labelPosition.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}






class DFAEdgeLoopPainter extends CustomPainter {
  final List<Edge> edges;

  DFAEdgeLoopPainter(this.edges);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint edgePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint boxPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint boxOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    const double arrowAdjustmentAngle = -.14; // Adjust this value as needed

    for (Edge edge in edges) {
      if (edge.startNode == edge.endNode) {
        // Calculate the angle from the center of the canvas to the node
        final angle = atan2(edge.startNode.y - size.height / 2, edge.startNode.x - size.width / 2);

        // Calculate start and end points based on angle offsets
        final startX = edge.startNode.x + edge.startNode.radius * cos(angle + edge.startAngleOffset);
        final startY = edge.startNode.y + edge.startNode.radius * sin(angle + edge.startAngleOffset);
        final endX = edge.endNode.x + edge.endNode.radius * cos(angle + edge.endAngleOffset);
        final endY = edge.endNode.y + edge.endNode.radius * sin(angle + edge.endAngleOffset);

        // Define the initial points
        final point1 = Offset(startX, startY);
        final point2 = Offset(endX, endY);

        // Ensure the circle radius is large enough
        final minRadius = (point1 - point2).distance / 2;
        const circleRadiusEdit = 30.0; // Edit this value to change the second circle size

        if (circleRadiusEdit >= minRadius) {
          // Calculate the mid-point between point1 and point2
          final midPoint = Offset((point1.dx + point2.dx) / 2, (point1.dy + point2.dy) / 2);

          // Calculate the perpendicular bisector's direction vector
          final directionVector = Offset(-(point2.dy - point1.dy), point2.dx - point1.dx);
          final normalizedDirection = Offset(directionVector.dx / directionVector.distance, directionVector.dy / directionVector.distance);

          // Calculate the center of the second circle (flip the direction by negating the perpendicular height)
          final halfDistance = (point1 - point2).distance / 2;
          final perpendicularHeight = sqrt(pow(circleRadiusEdit, 2) - pow(halfDistance, 2));
          final newCenter = Offset(midPoint.dx + normalizedDirection.dx * perpendicularHeight, midPoint.dy + normalizedDirection.dy * perpendicularHeight);

          // Draw an arc from point1 to point2
          final Path path = Path()
            ..moveTo(point1.dx, point1.dy)
            ..arcToPoint(
              point2,
              radius: Radius.circular(circleRadiusEdit),
              largeArc: true, // Draw the larger arc
              clockwise: false, // Ensure correct direction
            );

          canvas.drawPath(path, edgePaint);

          // Calculate the midpoint angle for the label
          final midAngle = angle + (edge.startAngleOffset + edge.endAngleOffset) / 2;

          // Calculate the position for the label on the arc
          final labelX = newCenter.dx + circleRadiusEdit * cos(midAngle);
          final labelY = newCenter.dy + circleRadiusEdit * sin(midAngle);
          final labelPosition = Offset(labelX, labelY);

          // Prepare the weights text
          String weightsText = edge.weights.join(', ');

          // Draw the weights
          TextSpan textSpan = TextSpan(text: weightsText, style: textStyle);
          TextPainter textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          // Draw the box around the weights
          final double boxPadding = 4.0;
          final double boxWidth = textPainter.width + boxPadding * 2;
          final double boxHeight = textPainter.height + boxPadding * 2;
          final Offset boxTopLeft = Offset(
            labelPosition.dx - boxWidth / 2,
            labelPosition.dy - boxHeight / 2,
          );

          // Draw the filled box
          canvas.drawRect(
            Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
            boxPaint,
          );

          // Draw the box outline
          canvas.drawRect(
            Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
            boxOutlinePaint,
          );

          // Draw the text over the box
          textPainter.paint(
            canvas,
            Offset(
              labelPosition.dx - textPainter.width / 2,
              labelPosition.dy - textPainter.height / 2,
            ),
          );

          // Draw arrowheads
          _drawArrowhead(canvas, point2, newCenter, edgePaint, circleRadiusEdit, angle, edge.endAngleOffset, arrowAdjustmentAngle);
        } else {
          // Draw a message indicating the circle radius is too small
          final textPainter = TextPainter(
            text: TextSpan(
              text: 'Radius too small',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
        }
      }
    }
  }

  void _drawArrowhead(Canvas canvas, Offset end, Offset center, Paint paint, double radius, double angle, double angleOffset, double adjustmentAngle) {
    const double arrowSize = 10.0;
    final arrowAngle = pi / 6;

    // Calculate the tangent at the end of the arc
    final tangentAngle = angle + angleOffset + adjustmentAngle;

    final arrowPoint1 = Offset(
      end.dx + arrowSize * cos(tangentAngle - arrowAngle),
      end.dy + arrowSize * sin(tangentAngle - arrowAngle),
    );
    final arrowPoint2 = Offset(
      end.dx + arrowSize * cos(tangentAngle + arrowAngle),
      end.dy + arrowSize * sin(tangentAngle + arrowAngle),
    );

    final Path arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}





class DFAStartNodePainter extends CustomPainter {
  final List<Node> nodes;

  DFAStartNodePainter(this.nodes);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint arrowPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint boxPaint = Paint()
      ..color = Colors.green[200]!
      ..style = PaintingStyle.fill;

    final Paint boxOutlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    const double largerCircleRadius = 50.0; // Radius of the larger circle

    for (var node in nodes) {
      if (node.isStartState) {
        final angle = node.arrowAngle; // Use the arrowAngle variable

        // Calculate the point on the larger circle at the calculated angle
        final startX = node.x + (node.radius + largerCircleRadius) * cos(angle);
        final startY = node.y + (node.radius + largerCircleRadius) * sin(angle);

        // Calculate the point on the node's circumference at the same angle
        final endX = node.x + node.radius * cos(angle);
        final endY = node.y + node.radius * sin(angle);

        // Draw the line from the larger circle to the node
        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), arrowPaint);

        // Draw the label "Start" with a box around it
        const String labelText = 'Start';
        TextSpan textSpan = TextSpan(text: labelText, style: textStyle);
        TextPainter textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Draw the filled box
        const double boxPadding = 4.0;
        final double boxWidth = textPainter.width + boxPadding * 2;
        final double boxHeight = textPainter.height + boxPadding * 2;
        final Offset boxTopLeft = Offset(startX - boxWidth / 2, startY - boxHeight / 2);

        // Draw the filled box
        canvas.drawRect(
          Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
          boxPaint,
        );

        // Draw the box outline
        canvas.drawRect(
          Rect.fromLTWH(boxTopLeft.dx, boxTopLeft.dy, boxWidth, boxHeight),
          boxOutlinePaint,
        );

        // Draw the text over the box
        textPainter.paint(
          canvas,
          Offset(
            startX - textPainter.width / 2,
            startY - textPainter.height / 2,
          ),
        );

        // Draw the arrowhead
        const double arrowSize = 10.0;
        final double arrowAngle = pi / 6; // Angle of the arrowhead

        final path = Path()
          ..moveTo(endX, endY)
          ..lineTo(
            endX + arrowSize * cos(angle - arrowAngle),
            endY + arrowSize * sin(angle - arrowAngle),
          )
          ..moveTo(endX, endY)
          ..lineTo(
            endX + arrowSize * cos(angle + arrowAngle),
            endY + arrowSize * sin(angle + arrowAngle),
          );

        canvas.drawPath(path, arrowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}



class DFANodePainterSetter {
  final double canvasWidth;
  final double canvasHeight;
  final double margin;

  DFANodePainterSetter({
    required this.canvasWidth,
    required this.canvasHeight,
    this.margin = 40,
  });

  void setNodePositions(List<Node> nodes) {
    final double centerX = canvasWidth / 2;
    final double centerY = canvasHeight / 2;
    final double radiusX = (canvasWidth - 2 * margin) / 2;
    final double radiusY = (canvasHeight - 2 * margin) / 2;
    final double angleStep = 2 * pi / nodes.length;

    for (int i = 0; i < nodes.length; i++) {
      double angle = i * angleStep;
      nodes[i].x = centerX + radiusX * cos(angle);
      nodes[i].y = centerY + radiusY * sin(angle);
      nodes[i].radius = 21; // Default radius
    }
  }
}






class DFAEdgeNonloopSetter {
  static const double defaultBendAngle = -60.0; // Default bend angle
  static const double defaultAngleOffset = pi / 12; // Default angle offset for separating overlapping edges

  void setEdgePaths(List<Edge> edges) {
    for (Edge edge in edges) {
      if (_hasReverseEdge(edges, edge)) {
        edge.bendAngle = defaultBendAngle; // Set the bend angle for bidirectional edges
        edge.startAngleOffset = defaultAngleOffset;
        edge.endAngleOffset = -defaultAngleOffset;
      } else {
        edge.bendAngle = 0.0; // Set the bend angle for unidirectional edges
        edge.startAngleOffset = 0.0;
        edge.endAngleOffset = 0.0;
      }
    }
  }

  bool _hasReverseEdge(List<Edge> edges, Edge edge) {
    for (Edge e in edges) {
      if (e.startNode == edge.endNode && e.endNode == edge.startNode) {
        return true;
      }
    }
    return false;
  }
}


class DFAEdgeLoopSetter {
  void setEdgeLoops(List<Edge> edges) {
    for (Edge edge in edges) {
      if (edge.startNode == edge.endNode) {
        // Set start and end angle offsets
        edge.startAngleOffset = pi / 4;
        edge.endAngleOffset = -pi / 4;
      }
    }
  }
}


class DFAStartNodeSetter {
  final List<Node> nodes;

  DFAStartNodeSetter(this.nodes);

  void setStartNodeAngles(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var node in nodes) {
      if (node.isStartState) {
        final angle = atan2(node.y - centerY, node.x - centerX) + pi; // Calculate and flip the angle
        node.arrowAngle = angle; // Set the arrowAngle variable
      }
    }
  }
}


class DFAEdgeBuilderForPainter {
  final List<Node> nodes;

  DFAEdgeBuilderForPainter(this.nodes);

  Map<String, List<Edge>> getEdges(List<List<String>> parsedData) {
    List<Edge> edges = [];

    for (int i = 1; i < parsedData.length; i++) { // Start from index 1 to process edges
      List<String> line = parsedData[i];
      if (line.length == 3) {
        Node? startNode;
        Node? endNode;
        int neededNodes = 0;

        // Find the start and end nodes in the nodes list
        for (Node node in nodes) {
          if (line[0] == node.name) {
            startNode = node;
            neededNodes++;
          }
          if (line[2] == node.name) {
            endNode = node;
            neededNodes++;
          }
          if (neededNodes == 2) {
            break;
          }
        }

        if (neededNodes == 2) { // If both nodes are found
          String weight = line[1];
          bool edgeExists = false;

          // Check if an edge with the same start and end nodes already exists
          for (Edge edge in edges) {
            if (edge.startNode == startNode && edge.endNode == endNode) {
              edgeExists = true;
              edge.addWeight(weight); // Add the weight to the existing edge
              break;
            }
          }

          // If no such edge exists, create a new edge
          if (!edgeExists) {
            edges.add(Edge(startNode!, endNode!, weight));
          }
        }
      }
    }

    // Organize edges into looped and non-looped edges
    List<Edge> loopedEdges = [];
    List<Edge> nonLoopedEdges = [];

    for (Edge edge in edges) {
      if (edge.startNode.name == edge.endNode.name) {
        loopedEdges.add(edge);
      } else {
        nonLoopedEdges.add(edge);
      }
    }

    return {
      'loopedEdges': loopedEdges,
      'nonLoopedEdges': nonLoopedEdges,
    };
  }
}


class DFAStartEndBuilderForPainter {
  final List<Node> nodes;

  DFAStartEndBuilderForPainter(this.nodes);

  void setStartEndStates(List<List<String>> parsedData) {
    bool hasStartState = false;
    bool hasEndState = false;

    for (int i = 1; i < parsedData.length; i++) { // Start from index 1 (line 2)
      List<String> line = parsedData[i];
      if (line.length == 2) {
        Node? node = _getNodeByName(line[0]);
        if (node != null) {
          if (line[1] == 'start' && !hasStartState) {
            node.isStartState = true;
            hasStartState = true;
          } else if (line[1] == 'end' && !hasEndState) {
            node.isEndState = true;
            hasEndState = true;
          }
        }
      }
    }
  }

  Node? _getNodeByName(String name) {
    for (Node node in nodes) {
      if (node.name == name) {
        return node;
      }
    }
    return null;
  }
}


class DFAResizer {
  final double originalCanvasWidth;
  final double originalCanvasHeight;

  DFAResizer({
    required this.originalCanvasWidth,
    required this.originalCanvasHeight,
  });

  void resizeNodes(List<Node> nodes, double newCanvasWidth, double newCanvasHeight) {
    double widthRatio = newCanvasWidth / originalCanvasWidth;
    double heightRatio = newCanvasHeight / originalCanvasHeight;

    for (Node node in nodes) {
      node.x *= widthRatio;
      node.y *= heightRatio;
    }
  }

  void resizeEdges(List<Edge> edges, double newCanvasWidth, double newCanvasHeight) {
    double widthRatio = newCanvasWidth / originalCanvasWidth;
    double heightRatio = newCanvasHeight / originalCanvasHeight;

    for (Edge edge in edges) {
      edge.startNode.x *= widthRatio;
      edge.startNode.y *= heightRatio;
      edge.endNode.x *= widthRatio;
      edge.endNode.y *= heightRatio;
    }
  }

  void resizeDFA(List<Node> nodes, List<Edge> edges, double newCanvasWidth, double newCanvasHeight) {
    resizeNodes(nodes, newCanvasWidth, newCanvasHeight);
    resizeEdges(edges, newCanvasWidth, newCanvasHeight);
  }
}



//
//
// class DFACanvas extends StatelessWidget {
//   final double left;
//   final double top;
//   final double sizeX;
//   final double sizeY;
//   final List<Node> nodes;
//   final List<Edge> nonLoopedEdges;
//   final List<Edge> loopedEdges;
//   final double bendAngle; // Add a parameter for the bend angle
//   final double offsetAngle; // Add a parameter for the offset angle
//   final Function(List<Node>, List<Edge>, List<Edge>) updateNodes; // Updated to include looped and non-looped edges
//
//   const DFACanvas({
//     super.key,
//     required this.left,
//     required this.top,
//     required this.sizeX,
//     required this.sizeY,
//     required this.nodes,
//     required this.nonLoopedEdges,
//     required this.loopedEdges,
//     this.bendAngle = -45.0, // Default value for bend angle
//     this.offsetAngle = .3 , // Default value for offset angle
//     required this.updateNodes,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: left,
//       top: top,
//       child: Container(
//         width: sizeX,
//         height: sizeY,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(
//             color: Colors.black,
//             width: 2.0,
//           ),
//         ),
//         child: Stack(
//           children: [
//             CustomPaint(
//               painter: DFANodePainter(nodes),
//               size: Size(sizeX, sizeY),
//             ),
//             CustomPaint(
//               painter: DFANonLoopedEdgePainter(
//                 nodes,
//                 nonLoopedEdges,
//                 bendAngle: bendAngle,
//                 offsetAngle: offsetAngle,
//               ),
//               size: Size(sizeX, sizeY),
//             ),
//             CustomPaint(
//               painter: DFALoopedEdgePainter(nodes, loopedEdges),
//               size: Size(sizeX, sizeY),
//             ),
//             DFANodeDragging(
//               nodes: nodes,
//               updateNodes: (updatedNodes) => updateNodes(updatedNodes, nonLoopedEdges, loopedEdges),
//               canvasWidth: sizeX,
//               canvasHeight: sizeY,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
// class DFANodePainter extends CustomPainter {
//   final List<Node> nodes;
//
//   DFANodePainter(this.nodes);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//
//     final textPainter = TextPainter(
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );
//
//     for (Node node in nodes) {
//       final offset = Offset(node.x, node.y);
//       canvas.drawCircle(offset, node.radius, paint);
//
//       final textSpan = TextSpan(
//         text: node.name,
//         style: TextStyle(
//           color: Colors.black,
//           fontSize: 15,
//           fontWeight: FontWeight.bold, // Make the text bold
//         ),
//       );
//
//       textPainter.text = textSpan;
//       textPainter.layout();
//       textPainter.paint(
//           canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
//
//
//
//
//
//
// class DFANonLoopedEdgePainter extends CustomPainter {
//   final List<Node> nodes;
//   final List<Edge> nonLoopedEdges;
//   final double bendAngle; // Add a parameter for the bend angle
//   final double offsetAngle; // Add a parameter for the offset angle
//
//   DFANonLoopedEdgePainter(this.nodes, this.nonLoopedEdges, {this.bendAngle = 0, this.offsetAngle = 0});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//
//     final textPainter = TextPainter(
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );
//
//     for (Edge edge in nonLoopedEdges) {
//       final startNode = nodes.firstWhere((node) => node.name == edge.startNode.name);
//       final endNode = nodes.firstWhere((node) => node.name == edge.endNode.name);
//
//       final startOffset = Offset(startNode.x, startNode.y);
//       final endOffset = Offset(endNode.x, endNode.y);
//
//       final angle = atan2(endOffset.dy - startOffset.dy, endOffset.dx - startOffset.dx);
//
//       bool isReciprocal = nonLoopedEdges.any((e) =>
//       e.startNode.name == edge.endNode.name &&
//           e.endNode.name == edge.startNode.name);
//
//       final adjustedStartOffset = isReciprocal
//           ? Offset(
//         startOffset.dx + startNode.radius * cos(angle + offsetAngle),
//         startOffset.dy + startNode.radius * sin(angle + offsetAngle),
//       )
//           : Offset(
//         startOffset.dx + startNode.radius * cos(angle),
//         startOffset.dy + startNode.radius * sin(angle),
//       );
//
//       final adjustedEndOffset = isReciprocal
//           ? Offset(
//         endOffset.dx - endNode.radius * cos(angle - offsetAngle),
//         endOffset.dy - endNode.radius * sin(angle - offsetAngle),
//       )
//           : Offset(
//         endOffset.dx - endNode.radius * cos(angle),
//         endOffset.dy - endNode.radius * sin(angle),
//       );
//
//       Offset midPoint;
//
//       if (isReciprocal) {
//         // Calculate perpendicular offset
//         final perpendicularOffset = Offset(
//           bendAngle * sin(angle),
//           -bendAngle * cos(angle),
//         );
//
//         // Draw curved edge
//         final controlPoint = Offset(
//           (adjustedStartOffset.dx + adjustedEndOffset.dx) / 2 + perpendicularOffset.dx,
//           (adjustedStartOffset.dy + adjustedEndOffset.dy) / 2 + perpendicularOffset.dy,
//         );
//
//         final path = Path()
//           ..moveTo(adjustedStartOffset.dx, adjustedStartOffset.dy)
//           ..quadraticBezierTo(
//             controlPoint.dx,
//             controlPoint.dy,
//             adjustedEndOffset.dx,
//             adjustedEndOffset.dy,
//           );
//
//         canvas.drawPath(path, paint);
//
//         // Calculate the midpoint of the Bezier curve
//         midPoint = _calculateBezierMidpoint(adjustedStartOffset, controlPoint, adjustedEndOffset);
//
//         // Draw arrowhead for curved edge
//         _drawCurvedArrowhead(canvas, adjustedEndOffset, controlPoint, adjustedStartOffset, paint);
//       } else {
//         // Draw straight edge
//         final path = Path()
//           ..moveTo(adjustedStartOffset.dx, adjustedStartOffset.dy)
//           ..lineTo(adjustedEndOffset.dx, adjustedEndOffset.dy);
//
//         canvas.drawPath(path, paint);
//
//         // Calculate the midpoint of the straight line
//         midPoint = Offset(
//           (adjustedStartOffset.dx + adjustedEndOffset.dx) / 2,
//           (adjustedStartOffset.dy + adjustedEndOffset.dy) / 2,
//         );
//
//         // Draw arrowhead for straight edge
//         _drawStraightArrowhead(canvas, adjustedEndOffset, angle, paint);
//       }
//
//       // Draw the weight at the midpoint with a background box
//       final textSpan = TextSpan(
//         text: edge.weights.join(", "),
//         style: const TextStyle(color: Colors.black, fontSize: 15),
//       );
//
//       textPainter.text = textSpan;
//       textPainter.layout();
//
//       // Draw the background box
//       final textBackgroundRect = Rect.fromLTWH(
//         midPoint.dx - textPainter.width / 2 - 4,
//         midPoint.dy - textPainter.height / 2 - 4,
//         textPainter.width + 8,
//         textPainter.height + 8,
//       );
//
//       final backgroundPaint = Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.fill;
//
//       canvas.drawRect(textBackgroundRect, backgroundPaint);
//
//       // Draw the text
//       textPainter.paint(
//         canvas,
//         midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
//       );
//
//       // Draw border for the text box
//       final borderPaint = Paint()
//         ..color = Colors.black
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1.0;
//
//       canvas.drawRect(textBackgroundRect, borderPaint);
//     }
//   }
//
//   Offset _calculateBezierMidpoint(Offset start, Offset control, Offset end) {
//     final t = 0.5; // Midpoint parameter
//     final x = (1 - t) * (1 - t) * start.dx + 2 * (1 - t) * t * control.dx + t * t * end.dx;
//     final y = (1 - t) * (1 - t) * start.dy + 2 * (1 - t) * t * control.dy + t * t * end.dy;
//     return Offset(x, y);
//   }
//
//   void _drawCurvedArrowhead(Canvas canvas, Offset endOffset, Offset controlPoint, Offset startOffset, Paint paint) {
//     const arrowSize = 10.0;
//     final arrowAngle = pi / 6;
//
//     final tangent = _calculateTangent(endOffset, controlPoint, startOffset);
//
//     final arrowPath = Path()
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(tangent - arrowAngle),
//         endOffset.dy - arrowSize * sin(tangent - arrowAngle),
//       )
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(tangent + arrowAngle),
//         endOffset.dy - arrowSize * sin(tangent + arrowAngle),
//       );
//
//     canvas.drawPath(arrowPath, paint);
//   }
//
//   void _drawStraightArrowhead(Canvas canvas, Offset endOffset, double angle, Paint paint) {
//     const arrowSize = 10.0;
//     final arrowAngle = pi / 6;
//
//     final arrowPath = Path()
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(angle - arrowAngle),
//         endOffset.dy - arrowSize * sin(angle - arrowAngle),
//       )
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(angle + arrowAngle),
//         endOffset.dy - arrowSize * sin(angle + arrowAngle),
//       );
//
//     canvas.drawPath(arrowPath, paint);
//   }
//
//   double _calculateTangent(Offset endOffset, Offset controlPoint, Offset startOffset) {
//     final t = 0.95; // A value close to 1 gives us a tangent near the end point
//     final dx = 2 * (1 - t) * (controlPoint.dx - startOffset.dx) + 2 * t * (endOffset.dx - controlPoint.dx);
//     final dy = 2 * (1 - t) * (controlPoint.dy - startOffset.dy) + 2 * t * (endOffset.dy - controlPoint.dy);
//     return atan2(dy, dx);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
//
//
//
//
//
//
//
//
//
// class DFALoopedEdgePainter extends CustomPainter {
//   final List<Node> nodes;
//   final List<Edge> loopedEdges;
//   final double loopRadius = 80.0; // Radius for the loop
//
//   DFALoopedEdgePainter(this.nodes, this.loopedEdges);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 2.0;
//
//     final screenCenterX = size.width / 2;
//     final screenCenterY = size.height / 2;
//
//     for (Edge edge in loopedEdges) {
//       final node = nodes.firstWhere((n) => n.name == edge.startNode.name);
//
//       final nodeCenterX = node.x;
//       final nodeCenterY = node.y;
//
//       // Calculate the angle from the node to the center of the screen and add π to flip
//       final angleToCenter = atan2(screenCenterY - nodeCenterY, screenCenterX - nodeCenterX) + pi;
//
//       // Calculate start and end points on the node's circumference
//       final startAngle = angleToCenter - pi / 5; // 45 degrees in radians
//       final endAngle = angleToCenter + pi / 5; // -45 degrees in radians
//
//       final startX = nodeCenterX + node.radius * cos(startAngle);
//       final startY = nodeCenterY + node.radius * sin(startAngle);
//
//       final endX = nodeCenterX + node.radius * cos(endAngle);
//       final endY = nodeCenterY + node.radius * sin(endAngle);
//
//       // Calculate control points for the Bezier curve to create the loop
//       final controlX1 = nodeCenterX + (node.radius + loopRadius) * cos(startAngle);
//       final controlY1 = nodeCenterY + (node.radius + loopRadius) * sin(startAngle);
//
//       final controlX2 = nodeCenterX + (node.radius + loopRadius) * cos(endAngle);
//       final controlY2 = nodeCenterY + (node.radius + loopRadius) * sin(endAngle);
//
//       final path = Path()
//         ..moveTo(startX, startY)
//         ..cubicTo(controlX1, controlY1, controlX2, controlY2, endX, endY);
//
//       canvas.drawPath(path, paint);
//
//       // Draw arrowhead at the end of the loop
//       _drawArrowhead(canvas, Offset(endX, endY), endAngle, paint);
//     }
//   }
//
//   void _drawArrowhead(Canvas canvas, Offset endOffset, double angle, Paint paint) {
//     const arrowSize = 11.0;
//     final arrowAngle = pi / 6 + pi;
//
//     final arrowPath = Path()
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(angle - arrowAngle),
//         endOffset.dy - arrowSize * sin(angle - arrowAngle),
//       )
//       ..moveTo(endOffset.dx, endOffset.dy)
//       ..lineTo(
//         endOffset.dx - arrowSize * cos(angle + arrowAngle),
//         endOffset.dy - arrowSize * sin(angle + arrowAngle),
//       );
//
//     canvas.drawPath(arrowPath, paint);
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
//
//
//
//
//
//
//
//
// class DFANodePainterInitializer {
//   final List<Node> nodes;
//
//   DFANodePainterInitializer(this.nodes);
//
//   void initializeNodes(Size size) {
//     const double margin = 40.0; // Margin space around the ellipse
//     final double centerX = size.width / 2;
//     final double centerY = size.height / 2;
//     final double ellipseRadiusX = (size.width / 2) - margin;
//     final double ellipseRadiusY = (size.height / 2) - margin;
//
//     for (int i = 0; i < nodes.length; i++) {
//       final double angle = (2 * pi * i) / nodes.length;
//       nodes[i].x = centerX + ellipseRadiusX * cos(angle);
//       nodes[i].y = centerY + ellipseRadiusY * sin(angle);
//       nodes[i].radius = 25.0; // Default radius value
//     }
//   }
// }
//
//
//
// class DFAEdgePainterInitializer {
//   // final List<Edge> edges;
//   //
//   // DFAEdgePainterInitializer(this.edges);
//   //
//   // Map<String, List<Edge>> splitEdges() {
//     List<Edge> loopedEdges = [];
//     List<Edge> nonLoopedEdges = [];
//
//     for (Edge edge in edges) {
//       if (edge.startNode.name == edge.endNode.name) {
//         loopedEdges.add(edge);
//       } else {
//         nonLoopedEdges.add(edge);
//       }
//   //   }
//   //
//   //   return {
//   //     'loopedEdges': loopedEdges,
//   //     'nonLoopedEdges': nonLoopedEdges,
//   //   };
//   // }
// }
//
