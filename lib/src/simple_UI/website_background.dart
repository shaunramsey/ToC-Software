import 'package:flutter/material.dart';
//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class WebsiteBackground extends StatelessWidget {
  const WebsiteBackground({super.key});

  static const Color customRed = Color.fromARGB(255, 229, 115, 115);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            customRed,
            Colors.white,
          ],
        ),
      ),
    );
  }
}