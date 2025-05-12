import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/qr_frame.dart';
import '../providers/settings_provider.dart';

class SenderDisplayScreen extends StatefulWidget {
  final List<QrFrame> qrFrames;
  final String verificationCode;

  const SenderDisplayScreen({
    super.key,
    required this.qrFrames,
    required this.verificationCode,
  });

  @override
  State<SenderDisplayScreen> createState() => _SenderDisplayScreenState();
}

class _SenderDisplayScreenState extends State<SenderDisplayScreen> {
  int _currentFrameIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startDisplay();
  }

  void _startDisplay() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final frameDuration = Duration(milliseconds: (1000 / settingsProvider.qrSpeed).round());

    _timer = Timer.periodic(frameDuration, (timer) {
      setState(() {
        _currentFrameIndex = (_currentFrameIndex + 1) % widget.qrFrames.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentFrame = widget.qrFrames[_currentFrameIndex];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendFiles),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.transferComplete),
                content: Text(l10n.confirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.no),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Text(l10n.yes),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(l10n.verificationCode),
                const SizedBox(height: 8),
                Text(
                  widget.verificationCode,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: currentFrame.data,
                  version: QrVersions.auto,
                  size: 600.0,
                  backgroundColor: Colors.white,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: isDarkMode ? Colors.black : Colors.black87,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: isDarkMode ? Colors.black : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '${_currentFrameIndex + 1}/${widget.qrFrames.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
} 