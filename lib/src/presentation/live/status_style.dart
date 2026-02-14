import 'package:flutter/material.dart';

class StatusStyle {
  const StatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;
}

StatusStyle statusStyleFor(String rawStatus) {
  final status = rawStatus.trim().toLowerCase();

  if (status.contains('live') || status.contains('en_curso') || status.contains('running')) {
    return const StatusStyle(
      label: 'En curso',
      background: Color(0xFFDFF7E8),
      foreground: Color(0xFF0F6C3A),
    );
  }

  if (status.contains('finished') || status.contains('final') || status.contains('done')) {
    return const StatusStyle(
      label: 'Finalizada',
      background: Color(0xFFE8EDF3),
      foreground: Color(0xFF324A60),
    );
  }

  if (status.contains('delayed') || status.contains('delay')) {
    return const StatusStyle(
      label: 'Retrasada',
      background: Color(0xFFFDEAD8),
      foreground: Color(0xFF9A4A06),
    );
  }

  if (status.contains('cancel')) {
    return const StatusStyle(
      label: 'Suspendida',
      background: Color(0xFFFBE2E6),
      foreground: Color(0xFFA02943),
    );
  }

  return const StatusStyle(
    label: 'Programada',
    background: Color(0xFFF2E9D8),
    foreground: Color(0xFF7A4B11),
  );
}
