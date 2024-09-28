import 'package:flutter/material.dart';
import 'dfa_logic.dart';
import 'canvas.dart';
import 'website_ui.dart';
import 'dragging.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TOC Automata Maker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Node> nodes = [];
  List<Edge> nonLoopedEdges = [];
  List<Edge> loopedEdges = [];

  late ScreenSizeCondition screenSizeCondition;

  @override
  void initState() {
    super.initState();
    screenSizeCondition = ScreenSizeCondition(onDFAUpdated: _updateDFA);
  }

  void _updateDFA(List<Node> updatedNodes, List<Edge> updatedNonLoopedEdges, List<Edge> updatedLoopedEdges) {
    setState(() {
      nodes = updatedNodes;
      nonLoopedEdges = updatedNonLoopedEdges;
      loopedEdges = updatedLoopedEdges;
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSizeCondition.handleScreenSizeChange(context);

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height * 2,
          child: Stack(
            children: <Widget>[
              const WebsiteBackground(),  // Add the WebsiteBackground to the stack
              const CustomAppBar(),       // Add the CustomAppBar to the stack
              UserInput(
                left: screenSize.width / 2 - screenSize.width / 3 / 2,
                top: screenSize.height / 6,
                sizeX: screenSize.width / 3,
                sizeY: screenSize.height / 3,
                onDFAUpdated: _updateDFA,
                canvasSizeX: screenSize.width / 1.2,
                canvasSizeY: screenSize.height / 1.1,
              ), // Add UserInput to the stack
              StringUserInput(
                left: screenSize.width / 2 - screenSize.width / 3 / 2,
                top: screenSize.height / 2 + 50,
                sizeX: screenSize.width / 3,
                sizeY: 50,
              ), // Add StringUserInput below the UserInput
              DFACanvas(
                left: screenSize.width / 2 - screenSize.width / 1.2 / 2,
                top: screenSize.height / 1.3,
                sizeX: screenSize.width / 1.2,
                sizeY: screenSize.height / 1.1,
                nodes: nodes,
                nonLoopedEdges: nonLoopedEdges,
                loopedEdges: loopedEdges,
              ), // Add DFACanvas to the stack
              // Additional layers can be added here
            ],
          ),
        ),
      ),
    );
  }
}









class UserInput extends StatefulWidget {
  final double left;
  final double top;
  final double sizeX;
  final double sizeY;
  final Function(List<Node>, List<Edge>, List<Edge>) onDFAUpdated;
  final double canvasSizeX;
  final double canvasSizeY;

  const UserInput({
    super.key,
    required this.left,
    required this.top,
    required this.sizeX,
    required this.sizeY,
    required this.onDFAUpdated,
    required this.canvasSizeX,
    required this.canvasSizeY,
  });

  @override
  _UserInputState createState() => _UserInputState();
}

class _UserInputState extends State<UserInput> {
  final TextEditingController _controller = TextEditingController();

  void _updateNotePad() {
    // Update the NotePad singleton with the text from the TextField
    NotePad notePad = NotePad();
    notePad.setUserInput(_controller.text);
    print('Updated NotePad with: ${_controller.text}');

    // Run DFATest
    DFATest test = DFATest();
    test.runTests();

    // Get the node list from DFANodeBuilder
    DFANodeBuilder nodeBuilder = DFANodeBuilder();
    List<Node> nodes = nodeBuilder.getNodes();

    // Parse the input
    NotePadParse parser = NotePadParse();
    List<List<String>> parsedData = parser.getParsedData();

    // Set start and end states using DFAStartEndBuilderForPainter
    DFAStartEndBuilderForPainter startEndBuilder = DFAStartEndBuilderForPainter(nodes);
    startEndBuilder.setStartEndStates(parsedData);

    // Set positions using DFANodePainterSetter
    DFANodePainterSetter nodeSetter = DFANodePainterSetter(
      canvasWidth: widget.canvasSizeX,
      canvasHeight: widget.canvasSizeY,
    );
    nodeSetter.setNodePositions(nodes);

    // Set start node angles using DFAStartNodeSetter
    DFAStartNodeSetter startNodeSetter = DFAStartNodeSetter(nodes);
    startNodeSetter.setStartNodeAngles(Size(widget.canvasSizeX, widget.canvasSizeY));

    // Get the edge list using DFAEdgeBuilderForPainter
    DFAEdgeBuilderForPainter edgeBuilder = DFAEdgeBuilderForPainter(nodes);
    Map<String, List<Edge>> edgeMap = edgeBuilder.getEdges(parsedData);
    List<Edge> nonLoopedEdges = edgeMap['nonLoopedEdges']!;
    List<Edge> loopedEdges = edgeMap['loopedEdges']!;

    // Set paths using DFAEdgeNonloopSetter
    DFAEdgeNonloopSetter edgeSetter = DFAEdgeNonloopSetter();
    edgeSetter.setEdgePaths(nonLoopedEdges);

    // Set loops using DFAEdgeLoopSetter
    DFAEdgeLoopSetter loopSetter = DFAEdgeLoopSetter();
    loopSetter.setEdgeLoops(loopedEdges);

    // Store the updated nodes and edges in ImportantStuff
    ImportantStuff importantStuff = ImportantStuff();
    importantStuff.setNodes(nodes);
    importantStuff.setNonLoopedEdges(nonLoopedEdges);
    importantStuff.setLoopedEdges(loopedEdges);

    // Send the updated nodes and edges to the parent widget
    widget.onDFAUpdated(nodes, nonLoopedEdges, loopedEdges);

    // Run DFA
    DFA dfa = DFA();
    bool accepted = dfa.run();
    if (accepted) {
      print("The DFA accepts the input string.");
    } else {
      print("The DFA does not accept the input string.");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Column(
        children: [
          Container(
            width: widget.sizeX,
            height: widget.sizeY,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red),
            ),
            padding: const EdgeInsets.all(8.0), // Add padding to the container
            child: TextField(
              controller: _controller,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter DFA pseudocode here',
                contentPadding: EdgeInsets.all(8.0), // Add padding to the text field
              ),
            ),
          ),
          const SizedBox(height: 10), // Add some space between the TextField and the Button
          ElevatedButton(
            onPressed: _updateNotePad,
            child: const Text('Update DFA'),
          ),
        ],
      ),
    );
  }
}









class StringUserInput extends StatefulWidget {
  final double left;
  final double top;
  final double sizeX;
  final double sizeY;

  const StringUserInput({
    super.key,
    required this.left,
    required this.top,
    required this.sizeX,
    required this.sizeY,
  });

  @override
  _StringUserInputState createState() => _StringUserInputState();
}

class _StringUserInputState extends State<StringUserInput> {
  final TextEditingController _controller = TextEditingController();

  void _updateStringInput() {
    // Update the StringInput singleton with the text from the TextField
    StringInput stringInput = StringInput();
    stringInput.setInput(_controller.text);
    print('Updated StringInput with: ${_controller.text}');

    // Run DFA
    DFA dfa = DFA();
    bool accepted = dfa.run();
    if (accepted) {
      print("The DFA accepts the input string.");
    } else {
      print("The DFA does not accept the input string.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      top: widget.top,
      child: Column(
        children: [
          Container(
            width: widget.sizeX,
            height: widget.sizeY,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red),
            ),
            padding: const EdgeInsets.all(1.0), // Add padding to the container
            child: TextField(
              controller: _controller,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter DFA string here',
                contentPadding: EdgeInsets.all(5.0), // Add padding to the text field
              ),
            ),
          ),
          const SizedBox(height: 0), // Add some space between the TextField and the Button
          ElevatedButton(
            onPressed: _updateStringInput,
            child: const Text('Update String'),
          ),
        ],
      ),
    );
  }
}




class ImportantStuff {
  static final ImportantStuff _instance = ImportantStuff._internal();
  List<Node> _nodes = [];
  List<Edge> _nonLoopedEdges = [];
  List<Edge> _loopedEdges = [];
  Size _oldCanvasSize = Size.zero;

  factory ImportantStuff() {
    return _instance;
  }

  ImportantStuff._internal();

  List<Node> getNodes() => _nodes;
  List<Edge> getNonLoopedEdges() => _nonLoopedEdges;
  List<Edge> getLoopedEdges() => _loopedEdges;
  Size getOldCanvasSize() => _oldCanvasSize;

  void setNodes(List<Node> nodes) {
    _nodes = nodes;
  }

  void setNonLoopedEdges(List<Edge> edges) {
    _nonLoopedEdges = edges;
  }

  void setLoopedEdges(List<Edge> edges) {
    _loopedEdges = edges;
  }

  void setOldCanvasSize(Size size) {
    _oldCanvasSize = size;
  }
}
