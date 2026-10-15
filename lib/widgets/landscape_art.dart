import 'package:flutter/material.dart';

/// Original, resolution-independent placeholder artwork. No network dependency.
class LandscapeArt extends StatelessWidget {
  const LandscapeArt({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Album artwork placeholder: a sun above layered mountains',
    image: true,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: const CustomPaint(
        painter: _LandscapePainter(),
        size: Size.infinite,
      ),
    ),
  );
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5B6A0), Color(0xFFC18570)],
        ).createShader(bounds),
    );
    canvas.drawCircle(
      Offset(size.width * .68, size.height * .35),
      size.height * .2,
      Paint()..color = const Color(0xFFF7DAC0),
    );
    void ridge(Color color, List<Offset> points) {
      final path = Path()..moveTo(0, size.height);
      for (final p in points) {
        path.lineTo(p.dx * size.width, p.dy * size.height);
      }
      path
        ..lineTo(size.width, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
    }

    ridge(const Color(0xFF9A7168), [
      const Offset(0, .8),
      const Offset(.2, .48),
      const Offset(.38, .72),
      const Offset(.59, .52),
      const Offset(.8, .7),
      const Offset(1, .5),
    ]);
    ridge(const Color(0xFF695E5B), [
      const Offset(0, .67),
      const Offset(.24, .84),
      const Offset(.5, .65),
      const Offset(.78, .86),
      const Offset(1, .7),
    ]);
    ridge(const Color(0xFF384849), [
      const Offset(0, .88),
      const Offset(.3, .77),
      const Offset(.67, .98),
      const Offset(1, .84),
    ]);
  }

  @override
  bool shouldRepaint(_LandscapePainter oldDelegate) => false;
}
