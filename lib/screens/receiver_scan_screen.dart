import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class ReceiverScanScreen extends StatefulWidget {
  final String verificationCode;

  const ReceiverScanScreen({
    super.key,
    required this.verificationCode,
  });

  @override
  State<ReceiverScanScreen> createState() => _ReceiverScanScreenState();
}

class _ReceiverScanScreenState extends State<ReceiverScanScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  final Map<int, Map<int, Map<String, dynamic>>> _receivedFrames = {};
  final Set<int> _receivedFiles = {};
  int _totalFiles = 0;
  int _receivedFramesCount = 0;
  bool _isScanning = true;
  String? _taskFolderName;

  @override
  void initState() {
    super.initState();
    _checkStoragePermission();
  }

  Future<void> _checkStoragePermission() async {
    _loadLastTask();

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final folderName = await _getTaskFolderName();
    final saveDir = Directory('${settingsProvider.storagePath}/$folderName');

    try {
      // Try saving test file
      await saveDir.create(recursive: true);
      final testFile = File('${saveDir.path}/test_permission.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
    } catch (e) {
      await saveDir.delete(recursive: true);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).receiverPermissionTitle),
            content: Text(AppLocalizations.of(context).receiverPermissionContent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).confirm),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String> _getTaskFolderName() async {
    if (_taskFolderName != null) {
      return _taskFolderName!;
    }

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final baseDir = Directory(settingsProvider.storagePath);
    if (!await baseDir.exists()) {
      await baseDir.create(recursive: true);
    }

    // Check existing folder with the same name
    int index = 0;
    String folderName = widget.verificationCode;
    while (await Directory('${baseDir.path}/$folderName').exists()) {
      index++;
      folderName = '${widget.verificationCode}($index)';
    }

    _taskFolderName = folderName;
    return folderName;
  }

  Future<void> _loadLastTask() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTask = prefs.getString('last_task_${widget.verificationCode}');
    if (lastTask != null) {
      try {
        final taskData = jsonDecode(lastTask) as Map<String, dynamic>;
        setState(() {
          _receivedFrames.clear();
          _receivedFiles.clear();
          _totalFiles = taskData['total_files'] as int? ?? 0;
          _receivedFramesCount = taskData['received_frames'] as int? ?? 0;
          _taskFolderName = taskData['folder_name'] as String?;

          // Restore frame data
          final frames = taskData['frames'] as Map<String, dynamic>?;
          if (frames != null) {
            frames.forEach((fileIndex, fileFrames) {
              if (fileFrames is Map<String, dynamic>) {
                _receivedFrames[int.parse(fileIndex)] = {};
                fileFrames.forEach((frameIndex, frameData) {
                  if (frameData is Map<String, dynamic>) {
                    _receivedFrames[int.parse(fileIndex)]![int.parse(frameIndex)] = frameData;
                  }
                });
              }
            });
          }

          final receivedFiles = taskData['received_files'] as List<dynamic>?;
          if (receivedFiles != null) {
            _receivedFiles.addAll(receivedFiles.map((e) => e as int));
          }
        });
      } catch (e) {
        print('Failed to load task data: $e');
        await _resetTask();
      }
    }
  }

  Future<void> _saveTask() async {
    if (!Provider.of<SettingsProvider>(context, listen: false).keepFiles) {
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final taskData = {
        'total_files': _totalFiles,
        'received_frames': _receivedFramesCount,
        'frames': _receivedFrames.map((key, value) => MapEntry(
          key.toString(),
          value.map((k, v) => MapEntry(k.toString(), v)),
        )),
        'received_files': _receivedFiles.toList(),
        'folder_name': _taskFolderName,
      };
      await prefs.setString('last_task_${widget.verificationCode}', jsonEncode(taskData));
    } catch (e) {
      print('Failed to save task data: $e');
    }
  }

  Future<void> _resetTask() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_task_${widget.verificationCode}');

    setState(() {
      _receivedFrames.clear();
      _receivedFiles.clear();
      _receivedFramesCount = 0;
      _totalFiles = 0;
      _taskFolderName = null;
    });
  }

  Future<void> _processFrame(Map<String, dynamic> frameData) async {
    if (frameData['v'] != widget.verificationCode) {
      return;
    }

    final fileIndex = frameData['fi'] as int;
    final frameIndex = frameData['ci'] as int;
    final totalFiles = frameData['fn'] as int;
    final totalFrames = frameData['cn'] as int;

    if (_totalFiles == 0) {
      setState(() {
        _totalFiles = totalFiles;
      });
    }

    if (_receivedFiles.contains(fileIndex)) {
      return;
    }

    if (!_receivedFrames.containsKey(fileIndex)) {
      _receivedFrames[fileIndex] = {};
    }

    if (!_receivedFrames[fileIndex]!.containsKey(frameIndex)) {
      _receivedFrames[fileIndex]![frameIndex] = frameData;
      setState(() {
        _receivedFramesCount++;
      });

      if (_receivedFrames[fileIndex]!.length == totalFrames) {
        await _saveFile(fileIndex);
        setState(() {
          _receivedFiles.add(fileIndex);
        });
      }

      await _saveTask();
    }

    if (_receivedFiles.length == _totalFiles) {
      _isScanning = false;
      // Clear local records
      await _resetTask();
      if (mounted) {
        final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
        final folderName = await _getTaskFolderName();
        final savePath = '${settingsProvider.storagePath}/$folderName';
        
        // Completion tip
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.of(context).transferSuccessTitle),
            content: Text(AppLocalizations.of(context).getTransferSuccessContent(savePath)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context).confirm),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveFile(int fileIndex) async {
    final frames = _receivedFrames[fileIndex]!;
    final frameData = frames.values.first;
    final rawPath = frameData['p'] as String;
    final relativePath = rawPath.replaceAll('\\', '/');

    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    final folderName = await _getTaskFolderName();
    final saveDir = Directory('${settingsProvider.storagePath}/$folderName');
    //await saveDir.create(recursive: true);

    final file = File('${saveDir.path}/$relativePath');
    await file.parent.create(recursive: true);

    final fileContent = <int>[];
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i]!;
      final chunkData = (frame['d'] as String)
          .split('')
          .map((hex) => int.parse(hex, radix: 16))
          .toList();
      fileContent.addAll(chunkData);
    }

    await file.writeAsBytes(fileContent);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanning),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.stopScanning),
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
          Expanded(
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                if (!_isScanning) return;

                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  try {
                    final frameData = jsonDecode(barcode.rawValue ?? '');
                    _processFrame(frameData);
                  } catch (e) {
                    // Ignore invalid codes
                  }
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: _totalFiles > 0 ? _receivedFiles.length / _totalFiles : 0,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.scanningProgress(
                    _receivedFramesCount,
                    _receivedFiles.length,
                    _totalFiles,
                    _totalFiles > 0 ? (_receivedFiles.length / _totalFiles * 100) : 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 