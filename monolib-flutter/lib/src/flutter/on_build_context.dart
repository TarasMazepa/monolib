import 'package:flutter/material.dart';

extension OnBuildContext on BuildContext {
  ThemeData get theme => Theme.of(this);
}
