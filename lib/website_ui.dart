import 'package:flutter/material.dart';

class WebsiteBackground extends StatefulWidget {
  const WebsiteBackground({super.key});

  @override
  _WebsiteBackgroundState createState() => _WebsiteBackgroundState();
}

class _WebsiteBackgroundState extends State<WebsiteBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _animationValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
      setState(() {
        _animationValue = _controller.value;
      });
    });
    _controller.repeat(); // Repeat the animation to keep it continuous
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the size of the screen and calculate the background height
    final screenSize = MediaQuery.of(context).size;
    final backgroundHeight = screenSize.height * 2;

    return SizedBox(
      width: screenSize.width,
      height: backgroundHeight,
      child: CustomPaint(
        painter: BackgroundPainter(
          animationValue: _animationValue,
          backgroundHeight: backgroundHeight,
        ),
        size: Size(screenSize.width, backgroundHeight),
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double animationValue;
  final double backgroundHeight;

  BackgroundPainter({
    required this.animationValue,
    required this.backgroundHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Create a solid red background
    Paint backgroundPaint = Paint()
      ..color = Colors.red.shade900;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Paints for the circles and their shadows
    Paint circlePaint = Paint()
      ..color = Colors.red.shade800
      ..style = PaintingStyle.fill;

    Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Parameters for the pattern
    double patternSize = 100; // Size of the grid cells
    double circleRadius = 20; // Radius of each circle
    Offset shadowOffset = const Offset(3, 3); // Offset for the shadow effect

    // Calculate the offset based on the animation value to create the scrolling effect
    // Reverse the direction of scrolling to left-to-right
    double dx = patternSize * animationValue * 2; // Multiplied to control the speed
    double dy = 0;

    // Calculate shift for staggering based on dx
    int shift = ((dx / patternSize).floor() % 2).toInt();

    // Draw the grid of circles with shadows
    for (double x = dx % patternSize - patternSize; x < size.width + patternSize; x += patternSize) {
      // Adjusted isShiftedColumn calculation
      bool isShiftedColumn = (((x / patternSize).floor() + shift) % 2 == 1);

      for (double y = dy % patternSize - patternSize; y < size.height + patternSize; y += patternSize) {
        // Shift every other column up by half the pattern size
        double yOffset = isShiftedColumn ? patternSize / 2 : 0;
        double yPosition = y + yOffset;

        // Draw the shadow
        canvas.drawCircle(Offset(x + shadowOffset.dx, yPosition + shadowOffset.dy), circleRadius, shadowPaint);
        // Draw the circle
        canvas.drawCircle(Offset(x, yPosition), circleRadius, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}






class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 70.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.redAccent, Colors.red.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Logo and App Name
          Row(
            children: [
              Image.asset(
                'assets/wc_logo1.png', // Update with your image path
                height: 70.0, // Adjust the height as needed
              ),
              const SizedBox(width: 10.0),
              const Text(
                'TOC Automata Maker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          // Right side: Navigation buttons or menu icon based on screen width
          if (screenWidth > 600)
          // Show navigation buttons on larger screens
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Features',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'About',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            )
          else
          // Show menu icon on smaller screens
            IconButton(
              icon: const Icon(Icons.menu),
              color: Colors.white,
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}

