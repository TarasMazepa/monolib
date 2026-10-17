/// Provides architectural extensions on [BuildContext] for streamlined tree traversal.
library;

import 'package:flutter/material.dart';

/// Provides a clean, fluent API for accessing deeply nested inherited widgets,
/// reducing boilerplate when traversing the widget tree.
///
/// Architecturally, this extension centralizes the retrieval of cross-cutting concerns
/// (such as theme configurations) directly from the element tree context, making widget
/// `build` methods more concise and readable by eliminating repetitive `Theme.of(context)`
/// calls.
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
