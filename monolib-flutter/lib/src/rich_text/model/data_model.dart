import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// --- DATA MODELS FOR METADATA ---
abstract class InlineWidgetData {}

class ButtonInlineData extends InlineWidgetData {
  final String text;
  final String snackbarText;
  ButtonInlineData({required this.text, required this.snackbarText});
}

class ImageInlineData extends InlineWidgetData {
  final String url;
  ImageInlineData({required this.url});
}

// UI ko Box + Data sath mein dene ke liye
class RenderedWidgetBox {
  final TextBox box;
  final InlineWidgetData data;
  RenderedWidgetBox({required this.box, required this.data});
}