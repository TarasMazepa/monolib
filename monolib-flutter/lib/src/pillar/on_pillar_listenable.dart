/// Provides extension methods to bridge the pure Dart [PillarListenable] API
/// with Flutter's reactive ecosystem.
library;

import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

import 'pillar_listenable_adapter.dart';

/// An extension on [PillarListenable] that integrates the Pillar DI framework's
/// pure Dart reactivity model with Flutter.
///
/// In the Pillar framework, lifecycle boundaries and reactivity are managed
/// via [PillarListenable] within `monolib-dart`, ensuring core business logic
/// remains decoupled from Flutter dependencies. This extension facilitates
/// cross-package adaptation by allowing any [PillarListenable] (such as those
/// returned by [Pillar.changeNotifierFor]) to be easily converted into a standard
/// Flutter [Listenable].
///
/// This enables Flutter UI components (like `ListenableBuilder` or `AnimatedBuilder`)
/// to seamlessly react to Pillar scope changes without requiring the DI container
/// to depend on Flutter directly.
extension OnPillarListenable on PillarListenable {
  /// Adapts this [PillarListenable] into a Flutter [Listenable].
  ///
  /// This getter wraps the current instance in a [PillarListenableAdapter],
  /// translating Pillar's internal listener management into Flutter's `VoidCallback`
  /// notifications. This is structurally necessary to consume Pillar scope updates
  /// inside Flutter widget trees.
  ///
  /// Example:
  /// ```dart
  /// final scopeListenable = pillar.changeNotifierFor(myScope);
  ///
  /// return ListenableBuilder(
  ///   listenable: scopeListenable.asListenable,
  ///   builder: (context, child) {
  ///     return Text('Scope updated!');
  ///   },
  /// );
  /// ```
  ///
  /// Returns a new [Listenable] that delegates `addListener` and `removeListener`
  /// calls directly to this underlying [PillarListenable].
  Listenable get asListenable => PillarListenableAdapter(this);
}
