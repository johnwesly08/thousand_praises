import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const ThousandPraiseApp());
}

class ThousandPraiseApp extends StatelessWidget {
  const ThousandPraiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thousand Praises',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'NotoSerifTamil',
      ),
      home: const HomeScreen(),
    );
  }
}