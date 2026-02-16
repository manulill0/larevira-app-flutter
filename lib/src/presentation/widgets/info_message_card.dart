import 'package:flutter/material.dart';

class InfoMessageCard extends StatelessWidget {
  const InfoMessageCard({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.all(16),
    this.textAlign = TextAlign.center,
    this.centered = true,
  });

  final String message;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: padding,
        child: Text(message, textAlign: textAlign),
      ),
    );

    if (!centered) {
      return card;
    }

    return Center(child: card);
  }
}
