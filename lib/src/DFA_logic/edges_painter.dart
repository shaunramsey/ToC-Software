import 'package:flutter/material.dart';


class Edge {
  final int startIndex;
  final int endIndex;
  final String label;

  Edge(this.startIndex, this.endIndex, this.label);
}


class Edges {
  final List<Edge> edges = [];

  Edges(List<String> lines, List<String> words) {
    final wordIndices = {for (int i = 0; i < words.length; i++) words[i]: i};

    for (int i = 1; i < lines.length; i++) {
      final parts = lines[i]
          .split(' ')
          .where((part) => part.isNotEmpty)
          .toList();

      if (parts.length == 3) {
        final startIndex = wordIndices[parts[0]];
        final endIndex = wordIndices[parts[2]];
        if (startIndex != null && endIndex != null) {
          edges.add(Edge(startIndex, endIndex, parts[1]));
        }
      }
    }
  }
}

