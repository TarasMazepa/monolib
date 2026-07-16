import 'package:flutter/material.dart';
import 'package:monolib_flutter/monolib_flutter.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final FocusNode _myFocusNode = FocusNode();


  @override
  void dispose() {
    _myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notepad Style Rich Text"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomEngineEditor(
          text: "Hello! This is our custom rendering engine.",
          focusNode: _myFocusNode,
        ),
      ),
    );
  }
}