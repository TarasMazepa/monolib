import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';
import 'package:monolib_flutter/src/pillar/pillar_listenable_adapter.dart';

/// Extension on [PillarListenable] that adapts it into a Flutter [Listenable].
///
/// Allows pure Dart [PillarListenable] instances (such as those returned by
/// [Pillar.changeNotifierFor]) to be consumed directly by Flutter widgets like
/// `ListenableBuilder` or `AnimatedBuilder`.
extension OnPillarListenable on PillarListenable {
  /// Returns this [PillarListenable] as a Flutter [Listenable].
  ///
  /// Example:
  /// ```dart
  /// // Within a Flutter widget's build method:
  /// final scopeNotifier = pillar.changeNotifierFor(myScope);
  ///
  /// return ListenableBuilder(
  ///   listenable: scopeNotifier.asListenable,
  ///   builder: (context, child) {
  ///     return const Text('Pillar scope state has been updated!');
  ///   },
  /// );
  /// ```
  Listenable get asListenable => PillarListenableAdapter(this);
}
