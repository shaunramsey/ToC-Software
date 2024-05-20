import 'package:flutter/material.dart';
import 'note_pad.dart';
import 'dfa_display.dart';

//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';



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
        height: MediaQuery.of(context).size.height * 1.5,
        child: Stack(
          children: [
            NotePad(
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 3 / 2,
              top: MediaQuery.of(context).size.height / 6,
              onProcessInput: handleProcessInput,
            ),
            DFADisplay(
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 2 / 2,
              top: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * .25,
              lines: processedLines, // Pass the processed lines to DFADisplay
            ),
            // Add more NotePads as needed
          ],
        ),
      ),
    );
  }
}

