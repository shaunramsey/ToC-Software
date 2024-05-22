import 'package:flutter/material.dart';
//import 'note_pad.dart';
//import 'scroll_controller.dart';
//import 'website_appbar.dart';
//import 'website_background.dart';


class NotePad extends StatefulWidget {
  final double left;
  final double top;
  final Function(List<String>) onProcessInput;

  const NotePad({
    super.key,
    required this.left,
    required this.top,
    required this.onProcessInput,
  });

  @override
  State<NotePad> createState() => _NotePadState();
}

class _NotePadState extends State<NotePad> {
  final TextEditingController _controller = TextEditingController();
  List<String> lines = [];

  void _processInput() {
    String input = _controller.text;
    lines = input.split('\n');
    widget.onProcessInput(lines); // Call the callback with the processed lines
  }

  @override
  Widget build(BuildContext context) {
    double notePadWidth = MediaQuery.of(context).size.width / 3;
    double notePadHeight = MediaQuery.of(context).size.height / 3;

    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Container(
        width: notePadWidth,
        height: notePadHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF6E0D25),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter DFA code here...',
                  ),
                  maxLines: null,
                ),
              ),
              ElevatedButton(
                onPressed: _processInput,
                child: const Text('Process Input'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


