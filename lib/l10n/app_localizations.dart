import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'QR File Transfer',
      'sendFiles': 'Send Files',
      'receiveFiles': 'Receive Files',
      'settings': 'Settings',
      'selectFiles': 'Select Files',
      'selectFolder': 'Select Folder',
      'startTransfer': 'Start Transfer',
      'transferComplete': 'Transfer Complete',
      'verificationCode': 'Verification Code',
      'startScanning': 'Start Scanning',
      'stopScanning': 'Stop Scanning',
      'scanning': 'Scanning...',
      'processing': 'Processing...',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'continueLastTask': 'Continue Last Task?',
      'yes': 'Yes',
      'no': 'No',
      'storagePath': 'Storage Path',
      'qrSpeed': 'QR Code Speed',
      'keepFiles': 'Keep Files on Interrupt',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'processingProgress': 'Processing: {current}/{total} ({percentage}%)',
      'scanningProgress': 'Received Frames: {count}; File Processing: {current}/{total} ({percentage}%)',
      'fileListEmpty': 'No files selected',
      'fileListHint': 'If files are large or numerous, consider compressing them first',
      'emptyDirectory': 'Empty directory or no permission to access files',
      'emptyDirectoryContent': 'Please grant file management permission to access folder contents',
      'receiverPermissionTitle': 'Storage Permission Required',
      'receiverPermissionContent': 'To save received files, the app needs storage permission. Please grant permission in settings.',
      'transferSuccessTitle': 'Transfer Complete',
      'transferSuccessContent': 'All files have been successfully received and saved to: {path}',
      'chunkSize': 'QR Code Data Size',
      'chunkSizeHint': 'Size of data in each QR code frame (512-1400 bytes)',
    },
    'zh': {
      'appTitle': 'QR文件传输',
      'sendFiles': '发送文件',
      'receiveFiles': '接收文件',
      'settings': '设置',
      'selectFiles': '选择文件',
      'selectFolder': '选择文件夹',
      'startTransfer': '开始传输',
      'transferComplete': '传输完成',
      'verificationCode': '验证码',
      'startScanning': '开始扫码',
      'stopScanning': '停止扫码',
      'scanning': '正在扫描...',
      'processing': '正在处理...',
      'cancel': '取消',
      'confirm': '确认',
      'continueLastTask': '是否继续上次任务？',
      'yes': '是',
      'no': '否',
      'storagePath': '存储路径',
      'qrSpeed': '二维码播放速度',
      'keepFiles': '中断时保留文件',
      'darkMode': '夜间模式',
      'language': '语言',
      'processingProgress': '处理进度：{current}/{total} ({percentage}%)',
      'scanningProgress': '共接收{count}帧，接收文件进度：{current}/{total} ({percentage}%)',
      'fileListEmpty': '未选择文件',
      'fileListHint': '如果文件较大或较多，建议先进行打包压缩',
      'emptyDirectory': '文件夹为空或无权限访问文件',
      'emptyDirectoryContent': '请授予文件管理权限以访问文件夹内容',
      'receiverPermissionTitle': '需要存储权限',
      'receiverPermissionContent': '为了保存接收的文件，应用需要存储权限。请在设置中授予权限。',
      'transferSuccessTitle': '传输完成',
      'transferSuccessContent': '所有文件已成功接收并保存至：{path}',
      'chunkSize': '二维码数据大小',
      'chunkSizeHint': '每个二维码帧的数据大小（512-1400字节）',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get sendFiles => _localizedValues[locale.languageCode]!['sendFiles']!;
  String get receiveFiles => _localizedValues[locale.languageCode]!['receiveFiles']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get selectFiles => _localizedValues[locale.languageCode]!['selectFiles']!;
  String get selectFolder => _localizedValues[locale.languageCode]!['selectFolder']!;
  String get startTransfer => _localizedValues[locale.languageCode]!['startTransfer']!;
  String get transferComplete => _localizedValues[locale.languageCode]!['transferComplete']!;
  String get verificationCode => _localizedValues[locale.languageCode]!['verificationCode']!;
  String get startScanning => _localizedValues[locale.languageCode]!['startScanning']!;
  String get stopScanning => _localizedValues[locale.languageCode]!['stopScanning']!;
  String get scanning => _localizedValues[locale.languageCode]!['scanning']!;
  String get processing => _localizedValues[locale.languageCode]!['processing']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get continueLastTask => _localizedValues[locale.languageCode]!['continueLastTask']!;
  String get yes => _localizedValues[locale.languageCode]!['yes']!;
  String get no => _localizedValues[locale.languageCode]!['no']!;
  String get storagePath => _localizedValues[locale.languageCode]!['storagePath']!;
  String get qrSpeed => _localizedValues[locale.languageCode]!['qrSpeed']!;
  String get keepFiles => _localizedValues[locale.languageCode]!['keepFiles']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get fileListEmpty => _localizedValues[locale.languageCode]!['fileListEmpty']!;
  String get fileListHint => _localizedValues[locale.languageCode]!['fileListHint']!;
  String get emptyDirectory => _localizedValues[locale.languageCode]!['emptyDirectory']!;
  String get emptyDirectoryContent => _localizedValues[locale.languageCode]!['emptyDirectoryContent']!;
  String get receiverPermissionTitle => _localizedValues[locale.languageCode]!['receiverPermissionTitle']!;
  String get receiverPermissionContent => _localizedValues[locale.languageCode]!['receiverPermissionContent']!;
  String get transferSuccessTitle => _localizedValues[locale.languageCode]!['transferSuccessTitle']!;
  String get transferSuccessContent => _localizedValues[locale.languageCode]!['transferSuccessContent']!;
  String get chunkSize => _localizedValues[locale.languageCode]!['chunkSize']!;
  String get chunkSizeHint => _localizedValues[locale.languageCode]!['chunkSizeHint']!;

  String processingProgress(int current, int total, double percentage) {
    return _localizedValues[locale.languageCode]!['processingProgress']!
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString())
        .replaceAll('{percentage}', percentage.toStringAsFixed(1));
  }

  String scanningProgress(int count ,int current, int total, double percentage) {
    return _localizedValues[locale.languageCode]!['scanningProgress']!
        .replaceAll('{count}', count.toString())
        .replaceAll('{current}', current.toString())
        .replaceAll('{total}', total.toString())
        .replaceAll('{percentage}', percentage.toStringAsFixed(1));
  }

  String getTransferSuccessContent(String path) {
    return _localizedValues[locale.languageCode]!['transferSuccessContent']!
        .replaceAll('{path}', path);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 