import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_auto/app/auto_theme.dart';
import 'package:flutter_auto/core/platform/device_service.dart';
import 'package:flutter_auto/features/home/clock_module.dart';
import 'package:flutter_auto/features/home/home_page.dart';
import 'package:flutter_auto/features/media/media_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDeviceService extends DeviceService {
  int mapsOpened = 0;
  int androidAutoOpened = 0;
  double volume = .5;
  @override
  Future<double> getVolume() async => volume;
  @override
  Future<void> setVolume(double value) async {
    volume = value;
  }

  @override
  Future<void> openMaps() async {
    mapsOpened++;
  }

  @override
  Future<void> openAndroidAuto() async {
    androidAutoOpened++;
  }

  @override
  Future<List<DeviceApp>> getApps() async => [
    const DeviceApp(name: 'Music', packageName: 'test.music'),
  ];
}

Future<void> pumpDashboard(
  WidgetTester tester,
  Size size, {
  double textScale = 1,
  DeviceService? device,
  MediaController? media,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: AutoTheme.dark,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: HomePage(device: device ?? FakeDeviceService(), media: media),
    ),
  );
  await tester.pump();
}

void main() {
  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(844, 390),
    const Size(800, 1280),
    const Size(1280, 800),
    const Size(1920, 1080),
  ]) {
    testWidgets('dashboard lays out without overflow at $size', (tester) async {
      await pumpDashboard(tester, size);
      expect(find.text('Where to next?'), findsOneWidget);
      expect(find.text('Weightless'), findsOneWidget);
      expect(find.text('WEATHER · DEMO'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('large accessibility text remains scrollable without overflow', (
    tester,
  ) async {
    await pumpDashboard(tester, const Size(320, 640), textScale: 2);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('media controls update the controller', (tester) async {
    final media = DemoMediaController();
    await pumpDashboard(tester, const Size(1280, 900), media: media);
    await tester.ensureVisible(find.byTooltip('Play'));
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(media.state.isPlaying, isTrue);
    expect(find.byTooltip('Pause'), findsOneWidget);
    await tester.tap(find.byTooltip('Next track'));
    await tester.pump();
    expect(find.text('A Walk'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    media.dispose();
  });

  testWidgets('navigation delegates to device service', (tester) async {
    final device = FakeDeviceService();
    await pumpDashboard(tester, const Size(1280, 900), device: device);
    await tester.tap(find.text('Open Google Maps'));
    await tester.pump();
    expect(device.mapsOpened, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Android Auto action opens the USB connection screen', (
    tester,
  ) async {
    final device = FakeDeviceService();
    await pumpDashboard(tester, const Size(1280, 900), device: device);
    await tester.ensureVisible(find.text('Android Auto'));
    await tester.tap(find.text('Android Auto'));
    await tester.pumpAndSettle();
    expect(
      find.text('Connect your phone via USB to use Android Auto.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Connect via USB'));
    await tester.pumpAndSettle();
    expect(device.androidAutoOpened, 1);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('unsupported platform explains native actions', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_auto/device'),
          null,
        );
    await pumpDashboard(tester, const Size(1280, 900), device: DeviceService());
    await tester.tap(find.text('Open Google Maps'));
    await tester.pump();
    expect(
      find.text('This action is available on your Android headunit.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('app drawer loads launchable apps', (tester) async {
    await pumpDashboard(tester, const Size(1280, 900));
    await tester.ensureVisible(find.byTooltip('Apps'));
    await tester.tap(find.byTooltip('Apps'));
    await tester.pumpAndSettle();
    expect(find.text('Your apps'), findsOneWidget);
    expect(find.text('Music'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('clock renders current date and both time formats', (
    tester,
  ) async {
    Widget clock(bool use24Hour) => MaterialApp(
      home: Scaffold(
        body: ClockModule(
          now: () => DateTime(2026, 10, 14, 21, 5),
          use24Hour: use24Hour,
        ),
      ),
    );
    await tester.pumpWidget(clock(false));
    expect(find.text('9:05'), findsOneWidget);
    expect(find.text('PM'), findsOneWidget);
    expect(find.textContaining('October'), findsOneWidget);
    await tester.pumpWidget(clock(true));
    expect(find.text('21:05'), findsOneWidget);
    expect(find.text('PM'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
