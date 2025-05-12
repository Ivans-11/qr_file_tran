import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/file_item.dart';
import '../models/qr_frame.dart';
import '../providers/settings_provider.dart';
import 'sender_display_screen.dart';

class SenderProcessingScreen extends StatefulWidget {
  final List<FileItem> files;

  const SenderProcessingScreen({
    super.key,
    required this.files,
  });

  @override
  State<SenderProcessingScreen> createState() => _SenderProcessingScreenState();
}

class _SenderProcessingScreenState extends State<SenderProcessingScreen> {
  double _progress = 0.0;
  String _verificationCode = '';
  List<QrFrame> _qrFrames = [];
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processFiles();
  }

  Future<void> _processFiles() async {
    // Generate verification code
    final combinedPaths = widget.files.map((f) => f.path).join('');
    _verificationCode = sha256.convert(utf8.encode(combinedPaths)).toString().substring(0, 6);

    // Get public parent path
    String commonPrefix = widget.files[0].path;
    for (var file in widget.files) {
      while (!file.path.startsWith(commonPrefix)) {
        commonPrefix = commonPrefix.substring(0, commonPrefix.lastIndexOf('/'));
      }
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final chunkSize = settingsProvider.chunkSize;

    // Process files one by one
    for (int fileIndex = 0; fileIndex < widget.files.length; fileIndex++) {
      final file = widget.files[fileIndex];
      final fileContent = await File(file.path).readAsBytes();
      final relativePath = file.path == commonPrefix
          ? file.name
          : file.path.substring(commonPrefix.length + 1);

      // Divide the content
      final chunks = <List<int>>[];
      for (var i = 0; i < fileContent.length; i += chunkSize) {
        chunks.add(fileContent.sublist(
          i,
          i + chunkSize > fileContent.length ? fileContent.length : i + chunkSize,
        ));
      }

      // Generate QR code
      for (int chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
        final frameData = {
          'fn': widget.files.length,
          'fi': fileIndex,
          'cn': chunks.length,
          'ci': chunkIndex,
          'p': relativePath,
          'v': _verificationCode,
          'd': chunks[chunkIndex].map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
        };

        _qrFrames.add(QrFrame(
          data: jsonEncode(frameData),
          fileIndex: fileIndex,
          frameIndex: chunkIndex,
        ));

        setState(() {
          _progress = (fileIndex + (chunkIndex + 1) / chunks.length) / widget.files.length;
        });
      }
    }

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SenderDisplayScreen(
            qrFrames: _qrFrames,
            verificationCode: _verificationCode,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.processing),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.cancel),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              CircularProgressIndicator(value: _progress),
              const SizedBox(height: 20),
              Text(
                l10n.processingProgress(
                  (_progress * 100).round(),
                  100,
                  _progress * 100,
                ),
              ),
            ] else ...[
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 20),
              Text(l10n.verificationCode),
              const SizedBox(height: 10),
              Text(
                _verificationCode,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 