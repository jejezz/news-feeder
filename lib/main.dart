import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const List<double> textScales = [0.9, 1.0, 1.15];

  int _textScaleIndex = 1;

  void _setTextScaleIndex(int index) {
    setState(() => _textScaleIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF2B705),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'EconoBrief',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'ClipartKorea',
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF12141B),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF12141B),
          titleTextStyle: TextStyle(
            fontFamily: 'ClipartKorea',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.2,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScales[_textScaleIndex]),
          ),
          child: child!,
        );
      },
      home: HomeScreen(
        textScaleIndex: _textScaleIndex,
        onTextScaleChanged: _setTextScaleIndex,
      ),
    );
  }
}
