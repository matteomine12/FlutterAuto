import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';
import '../../widgets/landscape_art.dart';
import '../../widgets/module_label.dart';
import 'media_controller.dart';

class MediaModule extends StatelessWidget {
  const MediaModule({super.key, required this.controller});
  final MediaController controller;

  static String _time(Duration duration) =>
      '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.state;
      final duration = state.duration.inMilliseconds.toDouble();
      final position = state.position.inMilliseconds.toDouble().clamp(
        0.0,
        duration > 0 ? duration : 0.0,
      );
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AutoColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.graphic_eq_rounded,
                  size: 16,
                  color: AutoColors.mint,
                ),
                const SizedBox(width: 10),
                Expanded(child: ModuleLabel(state.source)),
                if (state.isDemo)
                  const Tooltip(
                    message: 'Simulated controls. No audio is playing.',
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AutoColors.muted,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 144,
              width: double.infinity,
              child: state.artworkUri == null
                  ? const LandscapeArt()
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        state.artworkUri.toString(),
                        fit: BoxFit.cover,
                        semanticLabel: '${state.title} album artwork',
                        errorBuilder: (_, error, stack) => const LandscapeArt(),
                      ),
                    ),
            ),
            const SizedBox(height: 22),
            Text(
              state.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              state.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AutoColors.muted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Semantics(
              label: 'Track position',
              child: Slider(
                value: position,
                max: duration > 0 ? duration : 1,
                semanticFormatterCallback: (value) =>
                    _time(Duration(milliseconds: value.round())),
                onChanged: state.canSeek && duration > 0
                    ? (value) =>
                          controller.seek(Duration(milliseconds: value.round()))
                    : null,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _time(state.position),
                  style: const TextStyle(fontSize: 11, color: AutoColors.muted),
                ),
                Text(
                  _time(state.duration),
                  style: const TextStyle(fontSize: 11, color: AutoColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Previous track',
                  onPressed: state.canSkipPrevious ? controller.previous : null,
                  icon: const Icon(Icons.skip_previous_rounded, size: 30),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  tooltip: state.isPlaying ? 'Pause' : 'Play',
                  style: IconButton.styleFrom(
                    backgroundColor: AutoColors.mint,
                    foregroundColor: AutoColors.background,
                    minimumSize: const Size(60, 60),
                  ),
                  onPressed: state.canTogglePlayback
                      ? controller.togglePlayback
                      : null,
                  icon: Icon(
                    state.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Next track',
                  onPressed: state.canSkipNext ? controller.next : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 30),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
