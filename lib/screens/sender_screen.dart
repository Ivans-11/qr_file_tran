import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/file_item.dart';
import 'sender_processing_screen.dart';

class SenderScreen extends StatefulWidget {
  const SenderScreen({super.key});

  @override
  State<SenderScreen> createState() => _SenderScreenState();
}

class _SenderScreenState extends State<SenderScreen> {
  final List<FileItem> _selectedFiles = [];
  static const String _filesKey = 'selected_files';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = prefs.getString(_filesKey);
    if (filesJson != null) {
      final List<dynamic> filesList = jsonDecode(filesJson);
      setState(() {
        _selectedFiles.clear();
        _selectedFiles.addAll(
          filesList.map((file) => FileItem(
            path: file['path'],
            name: file['name'],
            size: file['size'],
          )),
        );
      });
    }
  }

  Future<void> _saveFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final filesJson = jsonEncode(_selectedFiles.map((file) => {
      'path': file.path,
      'name': file.name,
      'size': file.size,
    }).toList());
    await prefs.setString(_filesKey, filesJson);
  }

  void _clearFiles() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_filesKey);
    setState(() {
      _selectedFiles.clear();
    });
  }

  void _selectFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null) {
      setState(() {
        for (var file in result.files) {
          final path = file.path;
          if (path != null) {
            _selectedFiles.add(FileItem(
              path: path.replaceAll('\\', '/'),
              name: file.name,
              size: file.size,
            ));
          }
        }
      });
      _saveFiles();
    }
  }

  Future<List<FileSystemEntity>> _getAllFiles(Directory directory) async {
    List<FileSystemEntity> allFiles = [];
    
    try {
      final List<FileSystemEntity> entities = await directory.list().toList();
      
      for (var entity in entities) {
        if (entity is File) {
          allFiles.add(entity);
        } else if (entity is Directory) {
          // Recursively get files in subdirectories
          final subFiles = await _getAllFiles(entity);
          allFiles.addAll(subFiles);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read directory: $e')),
        );
      }
    }
    
    return allFiles;
  }

  Future<void> _getFilesFromDirectory(Directory directory) async {
    try {
      final List<FileSystemEntity> entities = await _getAllFiles(directory);
      
      if (entities.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).emptyDirectory),
                  Text(AppLocalizations.of(context).emptyDirectoryContent),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      for (var entity in entities) {
        if (entity is File) {
          final file = File(entity.path);
          final stat = await file.stat();
          
          setState(() {
            _selectedFiles.add(FileItem(
              path: entity.path.replaceAll('\\', '/'),
              name: entity.path.split(Platform.pathSeparator).last,
              size: stat.size,
            ));
          });
        }
      }
      _saveFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read directory: $e')),
        );
      }
    }
  }

  void _selectDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await _getFilesFromDirectory(Directory(selectedDirectory));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    _saveFiles();
  }

  void _startTransfer() {
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).fileListEmpty)),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SenderProcessingScreen(
          files: _selectedFiles,
          onProcessingComplete: (success) {
            if (success) {
              _clearFiles();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendFiles),
      ),
      body: Column(
        children: [
          Expanded(
            child: _selectedFiles.isEmpty
                ? Center(
                    child: Text(
                      l10n.fileListHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return ListTile(
                        title: Text(file.name),
                        subtitle: Text('${(file.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _removeFile(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.file_upload),
                  label: Text(l10n.selectFiles),
                  onPressed: _selectFiles,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.folder),
                  label: Text(l10n.selectFolder),
                  onPressed: _selectDirectory,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: Text(l10n.startTransfer),
                  onPressed: _startTransfer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 