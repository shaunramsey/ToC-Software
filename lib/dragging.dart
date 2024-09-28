import 'package:flutter/material.dart';
import 'dfa_logic.dart';
import 'dart:math';
import 'main.dart';






//
// import 'package:flutter/material.dart';
// import 'dfa_logic.dart'; // Import the Node class
//
// class DFANodeDragging extends StatefulWidget {
//   final List<Node> nodes;
//   final Function(List<Node>) updateNodes;
//   final double canvasWidth;
//   final double canvasHeight;
//
//   const DFANodeDragging({
//     super.key,
//     required this.nodes,
//     required this.updateNodes,
//     required this.canvasWidth,
//     required this.canvasHeight,
//   });
//
//   @override
//   _DFANodeDraggingState createState() => _DFANodeDraggingState();
// }
//
// class _DFANodeDraggingState extends State<DFANodeDragging> {
//   Node? _draggingNode;
//   Offset _dragStartOffset = Offset.zero;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanStart: (details) {
//         setState(() {
//           _draggingNode = _getNodeAtPosition(details.localPosition);
//           if (_draggingNode != null) {
//             _dragStartOffset = details.localPosition;
//           }
//         });
//       },
//       onPanUpdate: (details) {
//         if (_draggingNode != null) {
//           setState(() {
//             final dx = details.localPosition.dx - _dragStartOffset.dx;
//             final dy = details.localPosition.dy - _dragStartOffset.dy;
//             _draggingNode!.x += dx;
//             _draggingNode!.y += dy;
//
//             // Constrain node within canvas bounds
//             _draggingNode!.x = _draggingNode!.x.clamp(_draggingNode!.radius, widget.canvasWidth - _draggingNode!.radius);
//             _draggingNode!.y = _draggingNode!.y.clamp(_draggingNode!.radius, widget.canvasHeight - _draggingNode!.radius);
//
//             _dragStartOffset = details.localPosition;
//           });
//           widget.updateNodes(widget.nodes);
//         }
//       },
//       onPanEnd: (details) {
//         setState(() {
//           _draggingNode = null;
//         });
//       },
//       child: Stack(
//         children: [
//           Container(
//             color: Colors.transparent, // Transparent container to capture gestures
//           ),
//           if (_draggingNode != null)
//             CustomPaint(
//               painter: _DraggingAreaPainter(_draggingNode!),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Node? _getNodeAtPosition(Offset position) {
//     for (var node in widget.nodes) {
//       final nodeCenter = Offset(node.x, node.y);
//       if ((nodeCenter - position).distance <= node.radius) {
//         return node;
//       }
//     }
//     return null;
//   }
// }
//
// class _DraggingAreaPainter extends CustomPainter {
//   final Node node;
//
//   _DraggingAreaPainter(this.node);
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.red.withOpacity(0.2) // Slight transparent red color
//       ..style = PaintingStyle.fill;
//
//     final offset = Offset(node.x, node.y);
//     canvas.drawCircle(offset, node.radius, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
//
