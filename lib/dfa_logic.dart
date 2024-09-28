

// Node class
class Node {
  final String name;
  bool isStartState;
  bool isEndState;
  double x;
  double y;
  double radius;
  double arrowAngle; // New variable to store the arrow angle

  Node({
    required this.name,
    this.isStartState = false,
    this.isEndState = false,
    this.x = 0,
    this.y = 0,
    this.radius = 0,
    this.arrowAngle = 0, // Initialize with 0
  });
}

// Edge class



class Edge {
  Node startNode;
  Node endNode;
  final List<String> weights = [];
  double bendAngle = 0.0; // Keep this variable to store the bend angle
  double startAngleOffset = 0.0; // Add this variable to store the start angle offset
  double endAngleOffset = 0.0; // Add this variable to store the end angle offset

  Edge(this.startNode, this.endNode, String weight) {
    weights.add(weight); // Add the initial weight
  }

  void addWeight(String weight) {
    if (!weights.contains(weight)) {
      weights.add(weight);
    }
  }
}





// NotePad singleton class
class NotePad {
  // Private constructor
  NotePad._privateConstructor();

  // The single instance of the class
  static final NotePad _instance = NotePad._privateConstructor();

  // Factory constructor to return the single instance
  factory NotePad() {
    return _instance;
  }

  // The user input string
  String _userInput = """
  A B C D E ha hr
  abba!
  A start
  ha end
  A a B
  A b hr
  A ! hr
  B a B
  B b C
  B ! hr
  C a C
  C b D
  C ! hr
  D a E
  D b D
  D ! hr
  E a E
  E b D
  E ! ha
  """;

  // Method to return the user input
  String getUserInput() {
    return _userInput;
  }

  // Method to update the user input
  void setUserInput(String input) {
    _userInput = input;
  }
}


// NotePadParse class
class NotePadParse {
  List<List<String>> parsedData = [];

  NotePadParse() {
    NotePad notePad = NotePad();
    _parseInput(notePad.getUserInput());
  }

  void _parseInput(String input) {
    List<String> lines = input.split('\n');
    for (String line in lines) {
      if (line.trim().isNotEmpty) { // Check for non-empty lines
        List<String> words = line.split(' ').where((word) => word.isNotEmpty).toList();
        parsedData.add(words);
      }
    }
  }

  List<List<String>> getParsedData() {
    return parsedData;
  }
}

// DFANodeBuilder class
class DFANodeBuilder {
  List<Node> nodes = [];

  DFANodeBuilder() {
    NotePadParse parser = NotePadParse();
    _createNodes(parser.getParsedData());
  }

  void _createNodes(List<List<String>> parsedData) {
    if (parsedData.isNotEmpty) {
      List<String> stateNames = parsedData[0];
      for (String name in stateNames) {
        if (!_nodeExists(name)) {
          nodes.add(Node(name: name));
        }
      }
    }
  }

  bool _nodeExists(String name) {
    for (Node node in nodes) {
      if (node.name == name) {
        return true;
      }
    }
    return false;
  }

  List<Node> getNodes() {
    return nodes;
  }
}

// DFAEdgeBuilder class
class DFAEdgeBuilder {
  List<Edge> edges = [];
  List<Node> nodes = [];

  DFAEdgeBuilder() {
    DFANodeBuilder nodeBuilder = DFANodeBuilder();
    nodes = nodeBuilder.getNodes();
    NotePadParse parser = NotePadParse();
    _createEdges(parser.getParsedData());
  }

  void _createEdges(List<List<String>> parsedData) {
    for (int i = 1; i < parsedData.length; i++) { // Start from index 1 to process edges
      List<String> line = parsedData[i];
      if (line.length == 3) {
        Node? startNode;
        Node? endNode;
        int neededNodes = 0;

        // Find the start and end nodes in the nodes list
        for (Node node in nodes) {
          if (line[0] == node.name) {
            startNode = node;
            neededNodes++;
          }
          if (line[2] == node.name) {
            endNode = node;
            neededNodes++;
          }
          if (neededNodes == 2) {
            break;
          }
        }

        if (neededNodes == 2) { // If both nodes are found
          String weight = line[1];
          bool edgeExists = false;

          // Check if an edge with the same start and end nodes already exists
          for (Edge edge in edges) {
            if (edge.startNode == startNode && edge.endNode == endNode) {
              edgeExists = true;
              edge.addWeight(weight); // Add the weight to the existing edge
              break;
            }
          }

          // If no such edge exists, create a new edge
          if (!edgeExists) {
            edges.add(Edge(startNode!, endNode!, weight));
          }
        }
      }
    }
  }

  List<Edge> getEdges() {
    return edges;
  }
}

// DFAStartEndBuilder class
class DFAStartEndBuilder {
  List<Node> nodes = [];
  Node? startNode;
  Node? endNode;
  bool hasStartState = false;
  bool hasEndState = false;

  DFAStartEndBuilder() {
    DFANodeBuilder nodeBuilder = DFANodeBuilder();
    nodes = nodeBuilder.getNodes();
    NotePadParse parser = NotePadParse();
    _setStartEndStates(parser.getParsedData());
  }

  void _setStartEndStates(List<List<String>> parsedData) {
    for (int i = 1; i < parsedData.length; i++) { // Start from index 1 (line 2)
      List<String> line = parsedData[i];
      if (line.length == 2) {
        Node? node = _getNodeByName(line[0]);
        if (node != null) {
          if (line[1] == 'start' && !hasStartState) {
            node.isStartState = true;
            startNode = node;
            hasStartState = true;
          } else if (line[1] == 'end' && !hasEndState) {
            node.isEndState = true;
            endNode = node;
            hasEndState = true;
          }
        }
      }
    }
  }

  Node? _getNodeByName(String name) {
    for (Node node in nodes) {
      if (node.name == name) {
        return node;
      }
    }
    return null;
  }

  List<Node?> getStartEndNodes() {
    return [startNode, endNode];
  }

  List<Node> getNodes() {
    return nodes;
  }
}

// DFAMapBuilder class
class DFAMapBuilder {
  Map<String, Map<String, String>> transitionMap = {};

  DFAMapBuilder() {
    DFAEdgeBuilder edgeBuilder = DFAEdgeBuilder();
    List<Edge> edges = edgeBuilder.getEdges();
    _buildTransitionMap(edges);
  }

  void _buildTransitionMap(List<Edge> edges) {
    for (Edge edge in edges) {
      String startNode = edge.startNode.name;
      String endNode = edge.endNode.name;

      // Initialize the map for the start node if it doesn't exist
      if (!transitionMap.containsKey(startNode)) {
        transitionMap[startNode] = {};
      }

      // Add all weights and corresponding end nodes to the transition map
      for (String weight in edge.weights) {
        transitionMap[startNode]![weight] = endNode;
      }
    }
  }

  Map<String, Map<String, String>> getTransitionMap() {
    return transitionMap;
  }
}

// StringInput singleton class
class StringInput {
  // Private constructor
  StringInput._privateConstructor();

  // The single instance of the class
  static final StringInput _instance = StringInput._privateConstructor();

  // Factory constructor to return the single instance
  factory StringInput() {
    return _instance;
  }

  // The input string
  String _input = "abba!";

  // Method to return the input string
  String getInput() {
    return _input;
  }

  // Method to update the input string
  void setInput(String input) {
    _input = input;
  }
}


// DFA class
class DFA {
  Map<String, Map<String, String>> transitionMap = {};
  String? startNode;
  String? endNode;
  String inputString = "";

  DFA() {
    // Initialize the transition map
    DFAMapBuilder mapBuilder = DFAMapBuilder();
    transitionMap = mapBuilder.getTransitionMap();

    // Initialize the start and end nodes
    DFAStartEndBuilder startEndBuilder = DFAStartEndBuilder();
    List<Node?> startEndNodes = startEndBuilder.getStartEndNodes();
    startNode = startEndNodes[0]?.name;
    endNode = startEndNodes[1]?.name;

    // Initialize the input string
    StringInput stringInput = StringInput();
    inputString = stringInput.getInput();
  }

  bool run() {
    if (startNode == null || endNode == null) {
      print("DFA is not properly initialized with start and end states.");
      return false;
    }

    String? currentNode = startNode;
    for (String symbol in inputString.split('')) {
      print('Current Node: $currentNode, Symbol: $symbol');
      if (transitionMap[currentNode] != null && transitionMap[currentNode]!.containsKey(symbol)) {
        currentNode = transitionMap[currentNode]![symbol];
        print('Transitioning to Node: $currentNode');
      } else {
        print("No valid transition for symbol $symbol from node $currentNode.");
        return false;
      }
    }

    return currentNode == endNode;
  }
}

// DFATest class
class DFATest {
  void runTests() {
    // Print the NotePad input
    NotePad notePad = NotePad();
    print('NotePad Input:');
    print(notePad.getUserInput());

    // Print the parsed data
    NotePadParse parser = NotePadParse();
    List<List<String>> parsedData = parser.getParsedData();
    print('\nParsed Data:');
    for (var line in parsedData) {
      print(line);
    }

    // Print the nodes
    DFANodeBuilder nodeBuilder = DFANodeBuilder();
    List<Node> nodes = nodeBuilder.getNodes();
    print('\nNodes:');
    for (var node in nodes) {
      print('Node name: ${node.name}, isStartState: ${node.isStartState}, isEndState: ${node.isEndState}');
    }

    // Print the edges
    DFAEdgeBuilder edgeBuilder = DFAEdgeBuilder();
    List<Edge> edges = edgeBuilder.getEdges();
    print('\nEdges:');
    for (var edge in edges) {
      print('Edge from ${edge.startNode.name} to ${edge.endNode.name} with weights: ${edge.weights}');
    }

    // Print the start and end nodes
    DFAStartEndBuilder startEndBuilder = DFAStartEndBuilder();
    List<Node?> startEndNodes = startEndBuilder.getStartEndNodes();
    print('\nStart and End Nodes:');
    print('Start Node: ${startEndNodes[0]?.name}');
    print('End Node: ${startEndNodes[1]?.name}');

    // Print the transition map
    DFAMapBuilder mapBuilder = DFAMapBuilder();
    Map<String, Map<String, String>> transitionMap = mapBuilder.getTransitionMap();
    print('\nTransition Map:');
    transitionMap.forEach((startNode, transitions) {
      print('State $startNode:');
      transitions.forEach((weight, endNode) {
        print('  on "$weight" -> $endNode');
      });
    });

    // Print the StringInput
    StringInput stringInput = StringInput();
    print('\nStringInput:');
    print(stringInput.getInput());
    print('');

    // Check for edge conflicts
    DFAEdgeChecker edgeChecker = DFAEdgeChecker();
    if (edgeChecker.checkForConflicts()) {
      print('\nEdge Conflicts Found');
    } else {
      print('\nNo Edge Conflicts');
    }
    print('');
  }
}


class DFAEdgeChecker {
  bool hasEdgeConflict = false;

  DFAEdgeChecker() {
    DFAEdgeBuilder edgeBuilder = DFAEdgeBuilder();
    List<Edge> edges = edgeBuilder.getEdges();
    _checkEdgeConflicts(edges);
  }

  void _checkEdgeConflicts(List<Edge> edges) {
    Map<String, Map<String, bool>> edgeMap = {};

    for (Edge edge in edges) {
      String startNode = edge.startNode.name;

      if (!edgeMap.containsKey(startNode)) {
        edgeMap[startNode] = {};
      }

      for (String weight in edge.weights) {
        if (edgeMap[startNode]!.containsKey(weight)) {
          hasEdgeConflict = true;
          print("Conflict found: Multiple transitions for weight '$weight' from node '$startNode'.");
        } else {
          edgeMap[startNode]![weight] = true;
        }
      }
    }
  }

  bool checkForConflicts() {
    return hasEdgeConflict;
  }
}




void main() {
  // Run the DFATest
  DFATest test = DFATest();
  test.runTests();

  // Run the DFA
  DFA dfa = DFA();
  bool accepted = dfa.run();
  if (accepted) {
    print("The DFA accepts the input string.");
  } else {
    print("The DFA does not accept the input string.");
  }
}
