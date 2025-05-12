import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.storagePath),
            subtitle: Text(settingsProvider.storagePath),
            trailing: const Icon(Icons.folder),
            onTap: () async {
              String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
              if (selectedDirectory != null) {
                await settingsProvider.setStoragePath(selectedDirectory);
              }
            },
          ),
          SwitchListTile(
            title: Text(l10n.darkMode),
            value: settingsProvider.isDarkMode,
            onChanged: (value) => settingsProvider.setDarkMode(value),
          ),
          SwitchListTile(
            title: Text(l10n.keepFiles),
            value: settingsProvider.keepFiles,
            onChanged: (value) => settingsProvider.setKeepFiles(value),
          ),
          ListTile(
            title: Text(l10n.qrSpeed),
            subtitle: Slider(
              value: settingsProvider.qrSpeed,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              label: '${settingsProvider.qrSpeed.toStringAsFixed(1)} fps',
              onChanged: (value) => settingsProvider.setQrSpeed(value),
            ),
          ),
          ListTile(
            title: Text(l10n.chunkSize),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.chunkSizeHint),
                Slider(
                  value: settingsProvider.chunkSize.toDouble(),
                  min: 512,
                  max: 1400,
                  divisions: 89,
                  label: '${settingsProvider.chunkSize} bytes',
                  onChanged: (value) => settingsProvider.setChunkSize(value.toInt()),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: settingsProvider.locale,
              items: const [
                DropdownMenuItem(
                  value: Locale('zh', 'CN'),
                  child: Text('中文'),
                ),
                DropdownMenuItem(
                  value: Locale('en', 'US'),
                  child: Text('English'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLocale(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
} 