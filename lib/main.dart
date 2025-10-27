import 'package:flutter/material.dart';
import 'package:tringo_vendor/Presentation/Register/Screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: RegisterScreen());
  }
}
