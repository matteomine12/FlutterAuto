import 'package:flutter/material.dart';

import '../../app/auto_theme.dart';
import '../../core/platform/device_service.dart';

class AppDrawerSheet extends StatefulWidget {
  const AppDrawerSheet({
    super.key,
    required this.device,
    required this.onLaunch,
  });
  final DeviceService device;
  final Future<void> Function(DeviceApp) onLaunch;

  @override
  State<AppDrawerSheet> createState() => _AppDrawerSheetState();
}

class _AppDrawerSheetState extends State<AppDrawerSheet> {
  late final Future<List<DeviceApp>> _apps = widget.device.getApps();

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your apps', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'Choose an app to open.',
            style: TextStyle(color: AutoColors.muted),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: FutureBuilder<List<DeviceApp>>(
              future: _apps,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Installed apps are available on the Android headunit.',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final apps = snapshot.data!;
                if (apps.isEmpty)
                  return const Text('No launchable apps found.');
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: apps.length,
                  itemBuilder: (context, index) {
                    final app = apps[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AutoColors.elevated,
                        child: Text(
                          app.name.isEmpty
                              ? '?'
                              : app.name.characters.first.toUpperCase(),
                          style: const TextStyle(color: AutoColors.mint),
                        ),
                      ),
                      title: Text(app.name),
                      trailing: const Icon(
                        Icons.arrow_outward_rounded,
                        size: 18,
                      ),
                      onTap: () => widget.onLaunch(app),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({
    super.key,
    required this.use24Hour,
    required this.onTimeFormatChanged,
    required this.onSystemSettings,
  });
  final bool use24Hour;
  final ValueChanged<bool> onTimeFormatChanged;
  final VoidCallback onSystemSettings;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick settings',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('24-hour clock'),
            subtitle: const Text('Time format for this session'),
            value: use24Hour,
            onChanged: onTimeFormatChanged,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Android settings'),
            subtitle: const Text('Connections, display & sound'),
            trailing: const Icon(Icons.arrow_outward_rounded),
            onTap: onSystemSettings,
          ),
          const SizedBox(height: 24),
          const Text(
            'Made for the journey.',
            style: TextStyle(color: AutoColors.mint, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Autō 1.0 · Music and weather use demo data.\nOnly interact with your headunit when it is safe to do so.',
            style: TextStyle(
              color: AutoColors.muted,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}
