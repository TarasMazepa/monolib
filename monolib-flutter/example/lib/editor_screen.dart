import 'package:flutter/material.dart';
import 'package:monolib_flutter/monolib_flutter.dart';


class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notepad Style Rich Text"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          // Inside your EditorScreen build method:
          child: CustomEngineEditor(
            text: "Hello! This is our custom rendering engine.",
          ),
        ),
      ),
    );
  }
}