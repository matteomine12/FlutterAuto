import 'package:flutter/services.dart';

class DeviceApp {
  const DeviceApp({required this.name, required this.packageName});
  final String name;
  final String packageName;
}

/// Android-only capabilities. Other platforms fail explicitly, never silently.
class DeviceService {
  static const _channel = MethodChannel('flutter_auto/device');

  Future<void> openMaps() => _channel.invokeMethod<void>('openMaps');
  Future<void> openPhone() => _channel.invokeMethod<void>('openPhone');
  Future<void> openSettings() => _channel.invokeMethod<void>('openSettings');
  Future<void> openAndroidAuto() =>
      _channel.invokeMethod<void>('openAndroidAuto');
  Future<void> launchApp(String packageName) =>
      _channel.invokeMethod<void>('launchApp', {'packageName': packageName});
  Future<double> getVolume() async {
    final value = await _channel.invokeMethod<num>('getVolume');
    if (value == null || !value.isFinite) {
      throw PlatformException(
        code: 'invalid_volume',
        message: 'Media volume is unavailable.',
      );
    }
    return value.toDouble();
  }

  Future<void> setVolume(double value) => _channel.invokeMethod<void>(
    'setVolume',
    {'value': value.clamp(0.0, 1.0)},
  );

  Future<List<DeviceApp>> getApps() async {
    final apps = await _channel.invokeListMethod<Map>('getApps') ?? [];
    return apps
        .map(
          (app) => DeviceApp(
            name: app['name'] as String,
            packageName: app['packageName'] as String,
          ),
        )
        .toList();
  }
}
