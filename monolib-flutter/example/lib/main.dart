import 'package:flutter/material.dart';
import 'editor_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notepad Editor Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EditorScreen(),
    );
  }
}