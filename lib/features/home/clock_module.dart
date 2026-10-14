import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';
import '../../widgets/module_label.dart';

class ClockModule extends StatefulWidget {
  const ClockModule({super.key, this.use24Hour = false, this.now});
  final bool use24Hour;
  final DateTime Function()? now;

  @override
  State<ClockModule> createState() => _ClockModuleState();
}

class _ClockModuleState extends State<ClockModule> with WidgetsBindingObserver {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = _readTime();
    _startTimer();
  }

  DateTime _readTime() => widget.now?.call() ?? DateTime.now();

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _readTime();
      if (_now.minute != next.minute ||
          _now.hour != next.hour ||
          _now.day != next.day ||
          _now.month != next.month ||
          _now.year != next.year) {
        setState(() => _now = next);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => _now = _readTime());
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(_now),
      alwaysUse24HourFormat: widget.use24Hour,
    );
    final hour = widget.use24Hour
        ? '${_now.hour}'.padLeft(2, '0')
        : '${_now.hour % 12 == 0 ? 12 : _now.hour % 12}';
    final greeting = _now.hour < 12
        ? 'Good morning.'
        : _now.hour < 18
        ? 'Good afternoon.'
        : 'Good evening.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ModuleLabel(greeting),
          const SizedBox(height: 20),
          Semantics(
            label: time,
            excludeSemantics: true,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$hour:${'${_now.minute}'.padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 88,
                      height: 1,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  if (!widget.use24Hour) ...[
                    const SizedBox(width: 10),
                    Text(
                      _now.hour < 12 ? 'AM' : 'PM',
                      style: const TextStyle(
                        color: AutoColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            localizations.formatFullDate(_now),
            style: const TextStyle(
              color: AutoColors.muted,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
