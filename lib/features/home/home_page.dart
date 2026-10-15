import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/auto_theme.dart';
import '../../core/platform/device_service.dart';
import '../../widgets/module_label.dart';
import '../media/media_controller.dart';
import '../media/media_module.dart';
import '../weather/weather_module.dart';
import 'clock_module.dart';
import 'device_sheets.dart';
import 'navigation_module.dart';
import 'quick_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.device, this.media});
  final DeviceService? device;
  final MediaController? media;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late final DeviceService _device = widget.device ?? DeviceService();
  late final MediaController _media = widget.media ?? DemoMediaController();
  final _mediaKey = GlobalKey();
  double? _volume;
  bool _use24Hour = false;
  bool _changingVolume = false;
  int _volumeRevision = 0;

  static const _weather = WeatherState(
    temperature: 21,
    location: 'San Francisco',
    condition: WeatherCondition.clear,
    high: 23,
    low: 16,
    isDemo: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshVolume();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshVolume();
  }

  Future<void> _refreshVolume() async {
    final revision = _volumeRevision;
    try {
      final value = await _device.getVolume();
      if (mounted && !_changingVolume && revision == _volumeRevision) {
        setState(() => _volume = value.clamp(0.0, 1.0));
      }
    } on MissingPluginException {
      // A web/desktop preview intentionally has no Android volume control.
    } on PlatformException {
      if (mounted) setState(() => _volume = null);
    }
  }

  Future<void> _runDeviceAction(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      _message('This action is available on your Android headunit.');
    } on PlatformException catch (error) {
      _message(error.message ?? 'This action is unavailable on this device.');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _setVolume(double value) async {
    final revision = ++_volumeRevision;
    await _runDeviceAction(() => _device.setVolume(value));
    if (!mounted || revision != _volumeRevision) return;
    _changingVolume = false;
    await _refreshVolume();
  }

  void _openApps() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
        maxWidth: 640,
      ),
      builder: (sheetContext) => AppDrawerSheet(
        device: _device,
        onLaunch: (app) async {
          Navigator.of(sheetContext).pop();
          await _runDeviceAction(() => _device.launchApp(app.packageName));
        },
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
        maxWidth: 640,
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, updateSheet) => SettingsSheet(
          use24Hour: _use24Hour,
          onTimeFormatChanged: (value) {
            setState(() => _use24Hour = value);
            updateSheet(() {});
          },
          onSystemSettings: () => _runDeviceAction(_device.openSettings),
        ),
      ),
    );
  }

  void _showMedia() {
    final target = _mediaKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: .15,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.media == null) _media.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, viewport) {
          final horizontalPadding = viewport.maxWidth >= 1000 ? 40.0 : 20.0;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              24,
              horizontalPadding,
              16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1600),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final scale =
                        MediaQuery.textScalerOf(context).scale(16) / 16;
                    // Large accessibility text falls back to a vertical, scrollable flow.
                    final wide = width >= 1000 && scale <= 1.3;
                    final medium = width >= 600 && scale <= 1.3;
                    final mapHeight = wide
                        ? math.max(552.0, viewport.maxHeight - 216)
                        : 380.0 + 80 * (scale - 1);
                    final clock = ClockModule(use24Hour: _use24Hour);
                    const weather = WeatherModule(weather: _weather);
                    final navigation = NavigationModule(
                      height: mapHeight,
                      onOpenMaps: () => _runDeviceAction(_device.openMaps),
                    );
                    final media = MediaModule(
                      key: _mediaKey,
                      controller: _media,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(compact: width < 600),
                        const SizedBox(height: 30),
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 26,
                                child: SizedBox(
                                  height: mapHeight,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [clock, const Spacer(), weather],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(flex: 39, child: navigation),
                              const SizedBox(width: 24),
                              Expanded(flex: 35, child: media),
                            ],
                          )
                        else ...[
                          if (medium)
                            Row(
                              children: [
                                Expanded(child: clock),
                                const SizedBox(width: 24),
                                const Expanded(child: weather),
                              ],
                            )
                          else ...[
                            clock,
                            const SizedBox(height: 20),
                            weather,
                          ],
                          const SizedBox(height: 24),
                          if (medium)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: NavigationModule(
                                    height: 552,
                                    onOpenMaps: () =>
                                        _runDeviceAction(_device.openMaps),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(child: media),
                              ],
                            )
                          else ...[
                            navigation,
                            const SizedBox(height: 24),
                            media,
                          ],
                        ],
                        const SizedBox(height: 24),
                        QuickActions(
                          onApps: _openApps,
                          onMaps: () => _runDeviceAction(_device.openMaps),
                          onMedia: _showMedia,
                          onPhone: () => _runDeviceAction(_device.openPhone),
                          onSettings: _openSettings,
                          volume: _volume,
                          onVolumeChanged: (value) {
                            _changingVolume = true;
                            _volumeRevision++;
                            setState(() => _volume = value);
                          },
                          onVolumeChangeEnd: _setVolume,
                        ),
                        const SizedBox(height: 18),
                        const Center(child: ModuleLabel('Enjoy the journey.')),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Text(
        'autō',
        semanticsLabel: 'Auto',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          letterSpacing: -1.5,
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 24),
        const Expanded(child: ModuleLabel('Your drive, simplified')),
      ] else
        const Spacer(),
      const SizedBox(width: 16),
      const Icon(Icons.circle, size: 6, color: AutoColors.mint),
      const SizedBox(width: 8),
      const Flexible(child: ModuleLabel('Home', color: AutoColors.text)),
    ],
  );
}
