import 'package:flutter/material.dart';

const Color kOfficialCourseFallbackColor = Color(0xFFFFA500);

Color parseHexColor(String value, {Color fallback = const Color(0xFF8B1E3F)}) {
  final hex = value.replaceAll('#', '').trim();
  if (hex.length == 3) {
    final expanded = hex.split('').map((char) => '$char$char').join();
    final parsed = int.tryParse('FF$expanded', radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }
  if (hex.length == 6) {
    final parsed = int.tryParse('FF$hex', radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }
  if (hex.length == 8) {
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed != null) {
      return Color(parsed);
    }
  }
  return fallback;
}

Color parseKmlAbgrColor(
  String? value, {
  Color fallback = const Color(0xFF8B1E3F),
}) {
  final raw = (value ?? '').replaceAll('#', '').trim().toLowerCase();
  if (raw.length != 8) {
    return fallback;
  }

  final alpha = raw.substring(0, 2);
  final blue = raw.substring(2, 4);
  final green = raw.substring(4, 6);
  final red = raw.substring(6, 8);
  final argb = '$alpha$red$green$blue';
  final parsed = int.tryParse(argb, radix: 16);

  return parsed == null ? fallback : Color(parsed);
}

bool isOfficialCourseSectionName(String value) {
  final normalized = value.trim().toLowerCase();

  return normalized.contains('carrera oficial') ||
      normalized.contains('carreda oficial');
}
