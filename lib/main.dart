import 'package:flutter/material.dart';
import 'screens/settings_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sheets Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SettingsScreen(),
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}