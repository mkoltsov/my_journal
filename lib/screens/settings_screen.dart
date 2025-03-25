import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/sheets_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _sheetsService = SheetsService();
  final _spreadsheetIdController = TextEditingController();
  bool _isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_isSignedIn) {
                  await _authService.signOut();
                  setState(() => _isSignedIn = false);
                } else {
                  final account = await _authService.signIn();
                  if (account != null) {
                    setState(() => _isSignedIn = true);
                  }
                }
              },
              child: Text(_isSignedIn ? 'Sign Out' : 'Sign In with Google'),
            ),
            const SizedBox(height: 16),
            if (_isSignedIn) ...[
              TextField(
                controller: _spreadsheetIdController,
                decoration: const InputDecoration(
                  labelText: 'Spreadsheet ID',
                  helperText: 'Enter the ID from the spreadsheet URL',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_spreadsheetIdController.text.isNotEmpty) {
                    final client = await _authService.getAuthenticatedClient();
                    if (client != null) {
                      await _sheetsService.init(client);
                      // Save the spreadsheet ID to preferences here
                      Navigator.pushNamed(context, '/search');
                    }
                  }
                },
                child: const Text('Save and Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}