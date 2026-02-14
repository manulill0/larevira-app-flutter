import 'package:flutter/material.dart';

Color parseHexColor(String value, {Color fallback = const Color(0xFF8B1E3F)}) {
  final hex = value.replaceAll('#', '').trim();
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  return fallback;
}
