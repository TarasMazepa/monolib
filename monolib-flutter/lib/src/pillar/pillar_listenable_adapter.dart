import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

/// A [Listenable] adapter that wraps a pure Dart [PillarListenable].
///
/// Delegates [addListener] and [removeListener] calls directly to
/// [pillarListenable] so that Pillar scope notifications can trigger rebuilds
/// in Flutter widgets (such as `ListenableBuilder` or `AnimatedBuilder`).
///
/// Prefer using the `.asListenable` extension getter on [PillarListenable] as
/// a convenient shorthand instead of instantiating this class directly.
///
/// Example:
/// ```dart
/// final PillarListenable scopeNotifier = pillar.changeNotifierFor(myScope);
///
/// return ListenableBuilder(
///   listenable: PillarListenableAdapter(scopeNotifier),
///   builder: (context, child) {
///     return const Text('Pillar scope state has been updated!');
///   },
/// );
/// ```
class PillarListenableAdapter implements Listenable {
  /// The underlying [PillarListenable] notification source.
  ///
  /// Calls to [addListener] and [removeListener] on this adapter are forwarded
  /// to this instance.
  final PillarListenable pillarListenable;

  /// Creates a [PillarListenableAdapter] that wraps [pillarListenable].
  ///
  /// Prefer using the `.asListenable` extension getter on [PillarListenable]
  /// instead of calling this constructor directly.
  const PillarListenableAdapter(this.pillarListenable);

  /// Registers [listener] with the underlying [pillarListenable].
  ///
  /// The [listener] is invoked whenever [pillarListenable] notifies its
  /// subscribers.
  @override
  void addListener(VoidCallback listener) {
    pillarListenable.addListener(listener);
  }

  /// Removes a previously registered [listener] from the underlying
  /// [pillarListenable].
  @override
  void removeListener(VoidCallback listener) {
    pillarListenable.removeListener(listener);
  }
}
