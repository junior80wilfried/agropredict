import 'package:flutter/material.dart';

/// Convertit une couleur hexadécimale ("#2E6B28") renvoyée par l'API en
/// [Color] Flutter.
Color hexToColor(String hex, {Color fallback = Colors.grey}) {
  try {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  } catch (_) {
    return fallback;
  }
}
