import 'dart:math';
import 'package:flutter/material.dart';

/// Returns a consistent color for a user based on their ID.
/// The same user ID will always return the same color across all devices.
Color getUserColor(String userId) {
  final hash = userId.hashCode;
  final index = Random(hash).nextInt(Colors.primaries.length);
  return Colors.primaries[index];
}
