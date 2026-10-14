import 'package:flutter_auto/features/media/media_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DemoMediaController controller;
  setUp(() => controller = DemoMediaController());
  tearDown(() => controller.dispose());

  test('demo state is explicit and paused by default', () {
    expect(controller.state.isDemo, isTrue);
    expect(controller.state.isPlaying, isFalse);
    expect(controller.state.title, 'Weightless');
    expect(controller.state.canSeek, isTrue);
  });

  test('seek clamps to valid track bounds and notifies listeners', () {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.seek(const Duration(seconds: -20));
    expect(controller.state.position, Duration.zero);
    controller.seek(const Duration(hours: 1));
    expect(controller.state.position, controller.state.duration);
    expect(notifications, 2);
  });

  test('next wraps the playlist and clears position', () {
    controller.next();
    expect(controller.state.title, 'A Walk');
    expect(controller.state.position, Duration.zero);
    controller.next();
    controller.next();
    expect(controller.state.title, 'Weightless');
  });

  test('previous restarts current track before moving to previous', () {
    controller.previous();
    expect(controller.state.title, 'Weightless');
    expect(controller.state.position, Duration.zero);
    controller.previous();
    expect(controller.state.title, 'Open Eye Signal');
  });

  test('play and pause toggle simulated playback', () {
    controller.togglePlayback();
    expect(controller.state.isPlaying, isTrue);
    controller.togglePlayback();
    expect(controller.state.isPlaying, isFalse);
  });

  test('playing from the end restarts the track', () {
    controller.seek(controller.state.duration);
    controller.togglePlayback();
    expect(controller.state.position, Duration.zero);
  });
}
