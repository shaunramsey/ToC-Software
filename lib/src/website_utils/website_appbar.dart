import 'package:flutter/material.dart';
//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class WebsiteAppBar extends StatelessWidget {
  const WebsiteAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          border: const Border(
            bottom: BorderSide(
              color: Colors.black, // Border color
              width: 1.0, // Border width
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Test Build",
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }
}