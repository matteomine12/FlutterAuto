import 'package:flutter/material.dart';

import '../app/auto_theme.dart';

class ModuleLabel extends StatelessWidget {
  const ModuleLabel(this.text, {super.key, this.color = AutoColors.muted});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.0,
    ),
  );
}
