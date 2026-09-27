import 'package:flutter/material.dart';
import 'screens/level_screen.dart';

void main() {
  runApp(const EchoChainApp());
}

class EchoChainApp extends StatelessWidget {
  const EchoChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Chain',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LevelScreen(),
    );
  }
}