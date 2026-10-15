import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';
import '../../widgets/module_label.dart';

enum WeatherCondition { clear, cloudy, rain, snow }

@immutable
class WeatherState {
  const WeatherState({
    required this.temperature,
    required this.location,
    required this.condition,
    required this.high,
    required this.low,
    this.isDemo = false,
  });
  final int temperature;
  final String location;
  final WeatherCondition condition;
  final int high;
  final int low;
  final bool isDemo;
}

class WeatherModule extends StatelessWidget {
  const WeatherModule({super.key, required this.weather});
  final WeatherState weather;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (weather.condition) {
      WeatherCondition.clear => (Icons.wb_sunny_outlined, 'Clear skies'),
      WeatherCondition.cloudy => (Icons.cloud_outlined, 'Cloudy'),
      WeatherCondition.rain => (Icons.water_drop_outlined, 'Rain'),
      WeatherCondition.snow => (Icons.ac_unit, 'Snow'),
    };
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AutoColors.surface,
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF282E2B), AutoColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleLabel(weather.isDemo ? 'Weather · demo' : 'Weather'),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${weather.temperature}°',
                    semanticsLabel: '${weather.temperature} degrees Celsius',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, size: 44, color: AutoColors.mint),
            ],
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 7),
          Text(
            '${weather.location} · H:${weather.high}° L:${weather.low}°',
            style: const TextStyle(
              color: AutoColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
