import 'package:flutter/material.dart';

/// Extension on [BuildContext] that provides convenient access to the nearest
/// [ThemeData] in the widget tree.
///
/// Example:
/// ```dart
/// Widget build(BuildContext context) {
///   return Text(
///     'Styled Text',
///     style: context.theme.textTheme.bodyLarge,
///   );
/// }
/// ```
extension OnBuildContext on BuildContext {
  /// Resolves the nearest [ThemeData] from the widget tree hierarchy.
  ///
  /// This getter delegates directly to [Theme.of], triggering a rebuild
  /// of the consuming widget whenever the inherited [Theme] changes. It provides
  /// a safe, non-nullable return value by falling back to the default Material
  /// theme if no explicit [Theme] widget is found in the ancestor tree.
  ThemeData get theme => Theme.of(this);
}
