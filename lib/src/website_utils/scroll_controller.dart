import 'package:flutter/material.dart';
import 'note_pad.dart';
import 'dfa_display.dart';

//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class ScrollableNotePads extends StatelessWidget {
  const ScrollableNotePads({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 1.5 , // Arbitrary large height to allow scrolling
        child: Stack(
          children: [
            NotePad(
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 3 / 2,
              top: MediaQuery.of(context).size.height / 6,
            ),
            DFADisplay(
              left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 3 / 2,
              top: MediaQuery.of(context).size.height ,
            ),
            // Add more NotePads as needed
          ],
        ),
      ),
    );
  }
}
