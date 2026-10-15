import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';
import '../../widgets/module_label.dart';

class NavigationModule extends StatelessWidget {
  const NavigationModule({
    super.key,
    required this.onOpenMaps,
    this.height = 490,
  });
  final VoidCallback onOpenMaps;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: CustomPaint(
      painter: const _MapPainter(),
      child: Container(
        constraints: BoxConstraints(minHeight: height),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, .3, .55, 1],
            colors: [
              Color(0xC01B2223),
              Color(0x001B2223),
              Color(0x401B2223),
              Color(0xFF1B2223),
            ],
          ),
        ),
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.near_me_outlined,
                      size: 16,
                      color: AutoColors.mint,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ModuleLabel('Navigation', color: AutoColors.text),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Map preview · not live',
                  style: TextStyle(fontSize: 11, color: AutoColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Where to next?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'A new route. A little discovery.',
                  style: TextStyle(
                    color: AutoColors.muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: onOpenMaps,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text('Open Google Maps')),
                      SizedBox(width: 12),
                      Icon(Icons.arrow_outward_rounded, size: 19),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// A deliberately fictional map; never presented as navigation or GPS position.
class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF202829),
    );
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / 400, size.height / 500);
    final water = Path()
      ..moveTo(280, -30)
      ..cubicTo(190, 110, 400, 130, 340, 260)
      ..cubicTo(270, 380, 410, 400, 320, 530)
      ..lineTo(450, 550)
      ..lineTo(450, -30)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFF1A3338));
    final park = Path()
      ..moveTo(20, 125)
      ..lineTo(80, 100)
      ..lineTo(145, 165)
      ..lineTo(93, 211)
      ..lineTo(28, 183)
      ..close();
    canvas.drawPath(park, Paint()..color = const Color(0xFF2B3830));
    final road = Paint()
      ..color = const Color(0xFF3A4241)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = -4; i < 11; i++) {
      final x = i * 47.0;
      canvas.drawLine(Offset(x, -30), Offset(x + 240, 530), road);
      canvas.drawLine(Offset(-100, x), Offset(470, x + 195), road);
    }
    final highway = Path()
      ..moveTo(-30, 300)
      ..cubicTo(110, 190, 130, 280, 260, 95)
      ..cubicTo(310, 20, 380, 70, 440, 40);
    canvas.drawPath(
      highway,
      Paint()
        ..color = const Color(0xFF202829)
        ..strokeWidth = 13
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      highway,
      Paint()
        ..color = const Color(0xFF57625A)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    final route = Path()
      ..moveTo(65, 240)
      ..lineTo(133, 198)
      ..quadraticBezierTo(150, 187, 177, 157)
      ..lineTo(206, 128);
    canvas.drawPath(
      route,
      Paint()
        ..color = AutoColors.mint
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    const point = Offset(177, 157);
    canvas.drawCircle(point, 33, Paint()..color = const Color(0x18D1EBC8));
    canvas.drawCircle(point, 23, Paint()..color = const Color(0x22D1EBC8));
    canvas.drawCircle(point, 14, Paint()..color = AutoColors.mint);
    final arrow = Path()
      ..moveTo(177, 148)
      ..lineTo(171, 163)
      ..lineTo(177, 160)
      ..lineTo(183, 163)
      ..close();
    canvas.drawPath(arrow, Paint()..color = AutoColors.background);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) => false;
}
