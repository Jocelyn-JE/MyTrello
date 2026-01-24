import 'dart:math';
import 'package:flutter/material.dart';

/// Returns a consistent color for a board based on its ID.
/// The same board ID will always return the same color across all devices.
Color getBoardColor(String boardId) {
  final hash = boardId.hashCode;
  final index = Random(hash).nextInt(Colors.primaries.length);
  return Colors.primaries[index];
}
