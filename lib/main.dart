import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/auto_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF111415),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Do not lock orientation: the dashboard adapts to the available space.
  runApp(const AutoApp());
}
