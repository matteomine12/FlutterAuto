import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/auto_theme.dart';
import '../../core/platform/device_service.dart';

/// A full-screen entry point for Android Auto on a USB-connected phone.
class AndroidAutoScreen extends StatefulWidget {
  const AndroidAutoScreen({super.key, this.device});
  final DeviceService? device;

  @override
  State<AndroidAutoScreen> createState() => _AndroidAutoScreenState();
}

class _AndroidAutoScreenState extends State<AndroidAutoScreen> {
  late final DeviceService _device = widget.device ?? DeviceService();
  bool _connecting = false;

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      await _device.openAndroidAuto();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Android Auto opened.')));
      }
    } on MissingPluginException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Android Auto is available on Android devices.'),
          ),
        );
      }
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Android Auto is unavailable on this device.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Android Auto is unavailable on this device.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AutoColors.background,
    appBar: AppBar(
      title: const Text('Android Auto'),
      backgroundColor: AutoColors.surface,
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AutoColors.surface,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Connect your phone via USB to use Android Auto.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AutoColors.muted),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _connecting ? null : _connect,
              child: Text(_connecting ? 'Connecting…' : 'Connect via USB'),
            ),
          ],
        ),
      ),
    ),
  );
}
