import 'package:flutter/material.dart';

import '../features/home/home_page.dart';
import 'auto_theme.dart';

class AutoApp extends StatelessWidget {
  const AutoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Autō · Your drive, simplified',
    debugShowCheckedModeBanner: false,
    theme: AutoTheme.dark,
    home: const HomePage(),
  );
}
