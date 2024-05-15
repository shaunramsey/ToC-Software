import 'package:flutter/material.dart';


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
            WebsiteBase(), // Your existing WebsiteBase widget
            LeftHandBox(), // Include LeftHandBox in the widget tree
          ],
        ),
      ),
    );
  }
}


class WebsiteBase extends StatelessWidget {
  const WebsiteBase({super.key});


  static const Color customRed = Color.fromARGB(255, 229, 115, 115);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
      body: Container(
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
      ),
    );
  }
}


class LeftHandBox extends StatefulWidget {
  const LeftHandBox({super.key});


  @override
  //https://stackoverflow.com/questions/72545964/avoid-using-library-private-types-in-public-apis-lint-warning-even-in-in-co
  //I looked somewhere for helped, followed how to do this a certain way, but apparently it...
  //...was outdated.
  State<LeftHandBox> createState() => _LeftHandBoxState();
}


class _LeftHandBoxState extends State<LeftHandBox> {
  //Not sure what "final" does, the text editor gave back a warning and said "Could be final"
  final TextEditingController _textController = TextEditingController();
  bool _isEditing = false;


  static const Color customRed = Color(0xFF6E0D25);


  @override
  Widget build(BuildContext context) {

    Size screenSize = MediaQuery.of(context).size;
    double boxWidth = screenSize.width / 4 ; // Adjust the division factor as needed
    double boxHeight = screenSize.height / 3; // Adjust the division factor as needed
    double boxVertical = screenSize.width / 6 ; // Adjust the division factor as needed
    double boxHorizontal = screenSize.height / 3; // Adjust the division factor as needed


    return Positioned(
      left: boxVertical,
      top: boxHorizontal,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isEditing = true;
          });
        },
        child: Container(
          width: boxWidth,
          height: boxHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: customRed,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _isEditing
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: boxWidth * 9, // Make the container wider than the visible box
              child: TextField(
                controller: _textController,
                autofocus: true,
                maxLines: null, // Allow multiple lines of text
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
          )
              : const Center(
            child: Text(
              'Click to Edit',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}








