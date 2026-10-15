import 'package:flutter/services.dart';
import 'package:flutter_auto/core/platform/device_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_auto/device');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'getVolume' => .6,
        'getApps' => [
          {'name': 'Maps', 'packageName': 'com.google.android.apps.maps'},
        ],
        _ => null,
      };
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('maps, phone and settings use explicit native methods', () async {
    final service = DeviceService();
    await service.openMaps();
    await service.openPhone();
    await service.openSettings();
    expect(calls.map((call) => call.method), [
      'openMaps',
      'openPhone',
      'openSettings',
    ]);
  });

  test('Android Auto uses its explicit native method', () async {
    await DeviceService().openAndroidAuto();
    expect(calls.single.method, 'openAndroidAuto');
  });

  test('volume is read and writes are clamped', () async {
    final service = DeviceService();
    expect(await service.getVolume(), .6);
    await service.setVolume(2);
    expect(calls.last.arguments, {'value': 1.0});
  });

  test('app list is decoded and package name is passed through', () async {
    final service = DeviceService();
    final apps = await service.getApps();
    expect(apps.single.name, 'Maps');
    await service.launchApp(apps.single.packageName);
    expect(calls.last.arguments, {
      'packageName': 'com.google.android.apps.maps',
    });
  });
}
