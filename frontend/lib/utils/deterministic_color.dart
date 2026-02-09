import 'package:flutter/material.dart';

/// Custom hash function that produces consistent results across all platforms
int _stableHash(String str) {
  int hash = 0;
  for (int i = 0; i < str.length; i++) {
    hash = ((hash << 5) - hash + str.codeUnitAt(i)) & 0xFFFFFFFF;
  }
  return hash.abs();
}

/// Returns a unique color based on an ID string.
/// The same ID will always return the same color across all devices.
/// Uses HSL color space to generate vibrant, distinguishable colors.
Color getColorFromId(String id) {
  final hash = _stableHash(id);

  // Generate hue from hash (0-360 degrees)
  final hue = (hash % 360).toDouble();

  // Fixed saturation and lightness for vibrant, readable colors
  const saturation = 0.65;
  const lightness = 0.55;

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}
