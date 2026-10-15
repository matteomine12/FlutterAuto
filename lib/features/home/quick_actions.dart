import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onApps,
    required this.onMaps,
    required this.onMedia,
    required this.onPhone,
    required this.onSettings,
    required this.onAndroidAuto,
    required this.volume,
    required this.onVolumeChanged,
    required this.onVolumeChangeEnd,
  });
  final VoidCallback onApps;
  final VoidCallback onMaps;
  final VoidCallback onMedia;
  final VoidCallback onPhone;
  final VoidCallback onSettings;
  final VoidCallback onAndroidAuto;
  final double? volume;
  final ValueChanged<double>? onVolumeChanged;
  final ValueChanged<double>? onVolumeChangeEnd;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 680;
      final actions = Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 4,
        runSpacing: 12,
        children: [
          _Action(icon: Icons.apps_rounded, label: 'Apps', onTap: onApps),
          _Action(
            icon: Icons.explore_outlined,
            label: 'Explore',
            onTap: onMaps,
            highlighted: true,
          ),
          _Action(
            icon: Icons.music_note_outlined,
            label: 'Media',
            onTap: onMedia,
          ),
          _Action(icon: Icons.phone_outlined, label: 'Phone', onTap: onPhone),
          _Action(
            icon: Icons.android,
            label: 'Android Auto',
            onTap: onAndroidAuto,
          ),
          _Action(
            icon: Icons.tune_rounded,
            label: 'Settings',
            onTap: onSettings,
          ),
        ],
      );
      final volumeControl = Row(
        children: [
          Tooltip(
            message: volume == null
                ? 'Volume control is available on Android'
                : 'Media volume',
            child: Icon(
              volume == 0
                  ? Icons.volume_off_outlined
                  : Icons.volume_up_outlined,
              size: 21,
              color: AutoColors.muted,
            ),
          ),
          Expanded(
            child: Semantics(
              label: 'Media volume',
              child: Slider(
                value: volume ?? 0,
                onChanged: volume == null ? null : onVolumeChanged,
                onChangeEnd: volume == null ? null : onVolumeChangeEnd,
                semanticFormatterCallback: (value) =>
                    '${(value * 100).round()} percent',
              ),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              volume == null ? '—' : '${(volume! * 100).round()}',
              style: const TextStyle(fontSize: 12, color: AutoColors.muted),
            ),
          ),
        ],
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: compact
            ? Column(
                children: [
                  actions,
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: volumeControl,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: actions),
                  const SizedBox(width: 40),
                  Expanded(flex: 2, child: volumeControl),
                ],
              ),
      );
    },
  );
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 52, minHeight: 64),
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlighted
                        ? AutoColors.elevated
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: highlighted ? AutoColors.mint : AutoColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: highlighted ? AutoColors.text : AutoColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
