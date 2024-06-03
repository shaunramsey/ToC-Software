import 'package:flutter/material.dart';

class StringInput extends StatefulWidget {
  const StringInput({super.key});

  @override
  State<StringInput> createState() => _StringInputState();
}

class _StringInputState extends State<StringInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - MediaQuery.of(context).size.width / 3 / 2,
      top: MediaQuery.of(context).size.height / 3,
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF6E0D25),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(1.0),
        ),
        child: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a string...',
          ),
        ),
      ),
    );
  }
}
