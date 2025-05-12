import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _localeKey = 'locale';
  static const String _qrSpeedKey = 'qr_speed';
  static const String _keepFilesKey = 'keep_files';
  static const String _storagePathKey = 'storage_path';
  static const String _chunkSizeKey = 'chunk_size';

  bool _isDarkMode = false;
  Locale _locale = const Locale('zh', 'CN');
  double _qrSpeed = 2.0;
  bool _keepFiles = true;
  String? _storagePath;
  int _chunkSize = 680;

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  double get qrSpeed => _qrSpeed;
  bool get keepFiles => _keepFiles;
  String get storagePath => _storagePath ?? '';
  int get chunkSize => _chunkSize;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _qrSpeed = prefs.getDouble(_qrSpeedKey) ?? 2.0;
    _keepFiles = prefs.getBool(_keepFilesKey) ?? true;
    _storagePath = prefs.getString(_storagePathKey);
    _chunkSize = prefs.getInt(_chunkSizeKey) ?? 680;

    if (_storagePath == null) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        _storagePath = '${directory.path}/QRFileTransfer';
        await prefs.setString(_storagePathKey, _storagePath!);
      }
    }

    final String? localeString = prefs.getString(_localeKey);
    if (localeString != null) {
      final parts = localeString.split('_');
      _locale = Locale(parts[0], parts[1]);
    }

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, '${locale.languageCode}_${locale.countryCode}');
    notifyListeners();
  }

  Future<void> setQrSpeed(double speed) async {
    _qrSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_qrSpeedKey, speed);
    notifyListeners();
  }

  Future<void> setKeepFiles(bool value) async {
    _keepFiles = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keepFilesKey, value);
    notifyListeners();
  }

  Future<void> setStoragePath(String path) async {
    _storagePath = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storagePathKey, path);
    notifyListeners();
  }

  Future<void> setChunkSize(int size) async {
    if (size >= 512 && size <= 1400) {
      _chunkSize = size;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_chunkSizeKey, size);
      notifyListeners();
    }
  }
} 