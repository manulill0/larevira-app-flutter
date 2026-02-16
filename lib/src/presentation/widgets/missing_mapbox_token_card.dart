import 'package:flutter/material.dart';

import 'info_message_card.dart';

class MissingMapboxTokenCard extends StatelessWidget {
  const MissingMapboxTokenCard({super.key});

  static const String _message =
      'Falta MAPBOX_ACCESS_TOKEN. Ejecuta con --dart-define=MAPBOX_ACCESS_TOKEN=tu_token.';

  @override
  Widget build(BuildContext context) {
    return const InfoMessageCard(message: _message);
  }
}
