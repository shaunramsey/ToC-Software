import 'package:flutter/material.dart';
//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class DFADisplay extends StatelessWidget {
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
  Widget build(BuildContext context) {
    double displayWidth = MediaQuery.of(context).size.width / 2;
    double displayHeight = MediaQuery.of(context).size.height / 1.5;

    return Positioned(
      left: left,
      top: top,
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < lines.length; i++)
                Text(
                  lines[i],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}