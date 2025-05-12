import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import 'receiver_scan_screen.dart';

class ReceiverScreen extends StatefulWidget {
  const ReceiverScreen({super.key});

  @override
  State<ReceiverScreen> createState() => _ReceiverScreenState();
}

class _ReceiverScreenState extends State<ReceiverScreen> {
  final _verificationController = TextEditingController();
  static const String _lastVerificationKey = 'last_verification_code';

  @override
  void initState() {
    super.initState();
    _loadLastVerificationCode();
  }

  Future<void> _loadLastVerificationCode() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCode = prefs.getString(_lastVerificationKey);
    if (lastCode != null) {
      setState(() {
        _verificationController.text = lastCode;
      });
    }
  }

  Future<void> _saveVerificationCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastVerificationKey, code);
  }

  void _startScanning() {
    final verificationCode = _verificationController.text.trim();
    if (verificationCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).verificationCode)),
      );
      return;
    }

    _saveVerificationCode(verificationCode);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiverScanScreen(
          verificationCode: verificationCode,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _verificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiveFiles),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _verificationController,
              decoration: InputDecoration(
                labelText: l10n.verificationCode,
                border: const OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.startScanning),
              onPressed: _startScanning,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 