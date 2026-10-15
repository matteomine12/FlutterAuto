import 'package:flutter/material.dart';

abstract final class AutoColors {
  static const background = Color(0xFF111415);
  static const surface = Color(0xFF1B2021);
  static const elevated = Color(0xFF242A2B);
  static const text = Color(0xFFF0F2EC);
  static const muted = Color(0xFFA1ABAA);
  static const mint = Color(0xFFD1EBC8);
  static const coral = Color(0xFFE7AB93);
}

abstract final class AutoTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AutoColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AutoColors.mint,
        onPrimary: AutoColors.background,
        secondary: AutoColors.coral,
        surface: AutoColors.surface,
        onSurface: AutoColors.text,
        onSurfaceVariant: AutoColors.muted,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AutoColors.text,
        displayColor: AutoColors.text,
      ),
      iconTheme: const IconThemeData(color: AutoColors.text, size: 24),
      splashFactory: InkSparkle.splashFactory,
      sliderTheme: const SliderThemeData(
        trackHeight: 3,
        activeTrackColor: AutoColors.mint,
        inactiveTrackColor: Color(0xFF3B4343),
        thumbColor: AutoColors.mint,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AutoColors.surface,
        showDragHandle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AutoColors.elevated,
        contentTextStyle: TextStyle(color: AutoColors.text),
      ),
    );
  }
}
