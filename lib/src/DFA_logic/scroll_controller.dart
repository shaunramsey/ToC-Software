import 'package:flutter/material.dart';
import 'note_pad.dart';
import 'dfa_display.dart';

class ScrollableNotePads extends StatefulWidget {
  const ScrollableNotePads({super.key});

  @override
  State<ScrollableNotePads> createState() => _ScrollableNotePadsState();
}

class _ScrollableNotePadsState extends State<ScrollableNotePads> {
  List<String> processedLines = [];

  void handleProcessInput(List<String> lines) {
    setState(() {
      processedLines = lines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 2,
        child: Stack(
          children: [
            NotePad(
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 3 / 2,
              top: MediaQuery.of(context).size.height / 6,
              onProcessInput: handleProcessInput, // eat input from notepad
            ),
            DFADisplay(
              left: MediaQuery.of(context).size.width / 1.25 - MediaQuery.of(context).size.width / 1.5,
              top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.25,
              lines: processedLines, // Pass the processed lines to DFADisplay
            ),
            // Add more NotePads as needed
          ],
        ),
      ),
    );
  }
}


