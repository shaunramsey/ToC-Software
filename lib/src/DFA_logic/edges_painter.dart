

class Edge {
  final int startIndex;
  final int endIndex;
  final List<String> labels;

  Edge(this.startIndex, this.endIndex, this.labels);
}



class Edges {
  final List<Edge> edges = [];
  final Set<String> oppositeEdges = {};

  Edges(List<String> lines, List<String> words) {
    final wordIndices = {for (int i = 0; i < words.length; i++) words[i]: i};
    final Map<String, Edge> edgeMap = {};

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i].split(' ').where((part) => part.isNotEmpty).toList();
      if (parts.length == 3) {
        final startIndex = wordIndices[parts[0]];
        final endIndex = wordIndices[parts[2]];
        if (startIndex != null && endIndex != null) {
          final key = '$startIndex-$endIndex';
          final oppositeKey = '$endIndex-$startIndex';
          if (edgeMap.containsKey(key)) {
            edgeMap[key]!.labels.add(parts[1]);
          } else {
            edgeMap[key] = Edge(startIndex, endIndex, [parts[1]]);
          }
          if (edgeMap.containsKey(oppositeKey)) {
            oppositeEdges.add(key);
            oppositeEdges.add(oppositeKey);
          }
        }
      }
    }

    edges.addAll(edgeMap.values);
  }
}



