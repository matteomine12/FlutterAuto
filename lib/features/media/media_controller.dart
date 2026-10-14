import 'dart:async';

import 'package:flutter/foundation.dart';

@immutable
class MediaState {
  const MediaState({
    required this.title,
    required this.artist,
    required this.duration,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.source = 'No active session',
    this.artworkUri,
    this.canSeek = false,
    this.canSkipNext = false,
    this.canSkipPrevious = false,
    this.canTogglePlayback = false,
    this.isDemo = false,
  });

  final String title;
  final String artist;
  final String source;
  final Duration duration;
  final Duration position;
  final bool isPlaying;
  final Uri? artworkUri;
  final bool canSeek;
  final bool canSkipNext;
  final bool canSkipPrevious;
  final bool canTogglePlayback;
  final bool isDemo;
}

/// Implement using Android MediaController / MediaSession callbacks later.
/// Widgets depend only on this contract, not a particular music provider.
abstract class MediaController extends ChangeNotifier {
  MediaState get state;
  void togglePlayback();
  void next();
  void previous();
  void seek(Duration position);
}

/// Simulated transport only. This does not play audio or inspect other apps.
class DemoMediaController extends MediaController {
  static const _tracks = [
    (title: 'Weightless', artist: 'Marconi Union', seconds: 489),
    (title: 'A Walk', artist: 'Tycho', seconds: 316),
    (title: 'Open Eye Signal', artist: 'Jon Hopkins', seconds: 472),
  ];
  int _index = 0;
  Duration _position = const Duration(seconds: 112);
  bool _playing = false;
  Timer? _timer;
  final Stopwatch _elapsed = Stopwatch();
  Duration _anchor = Duration.zero;

  @override
  MediaState get state => MediaState(
    title: _tracks[_index].title,
    artist: _tracks[_index].artist,
    duration: Duration(seconds: _tracks[_index].seconds),
    position: _position,
    isPlaying: _playing,
    source: 'Demo session',
    isDemo: true,
    canSeek: true,
    canSkipNext: true,
    canSkipPrevious: true,
    canTogglePlayback: true,
  );

  @override
  void togglePlayback() {
    _playing = !_playing;
    if (_playing) {
      if (_position >= state.duration) _position = Duration.zero;
      _resetAnchor();
      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        _position = _anchor + _elapsed.elapsed;
        if (_position >= state.duration) {
          _position = state.duration;
          _playing = false;
          _stopTimer();
        }
        notifyListeners();
      });
    } else {
      _position = _anchor + _elapsed.elapsed;
      if (_position > state.duration) _position = state.duration;
      _stopTimer();
    }
    notifyListeners();
  }

  void _resetAnchor() {
    _anchor = _position;
    _elapsed
      ..reset()
      ..start();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsed.stop();
  }

  @override
  void next() => _select((_index + 1) % _tracks.length);

  @override
  void previous() {
    if (_position.inSeconds > 3) {
      seek(Duration.zero);
    } else {
      _select((_index - 1 + _tracks.length) % _tracks.length);
    }
  }

  void _select(int index) {
    _index = index;
    _position = Duration.zero;
    if (_playing) _resetAnchor();
    notifyListeners();
  }

  @override
  void seek(Duration position) {
    _position = Duration(
      milliseconds: position.inMilliseconds.clamp(
        0,
        state.duration.inMilliseconds,
      ),
    );
    if (_playing) _resetAnchor();
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
