import 'package:flutter/material.dart';
//import 'src/website_utils/note_pad.dart';
import 'src/website_utils/scroll_controller.dart';
import 'src/website_utils/website_appbar.dart';
import 'src/website_utils/website_background.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      home: Scaffold(
        body: Stack(
          children: [
            WebsiteBackground(),
            ScrollableNotePads(), // Wrap NotePads in a scrollable widget
            WebsiteAppBar(), // Your existing WebsiteBase widget

          ],
        ),
      ),
    );
  }
}

















