import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';

class MuhasabahApp extends StatelessWidget {
  const MuhasabahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muhasabah02',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}