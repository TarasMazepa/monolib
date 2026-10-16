import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

/// An architectural adapter that bridges a pure-Dart [PillarListenable] to
/// Flutter's native [Listenable] contract.
///
/// Within the Pillar dependency injection framework, [PillarListenable] provides
/// a way to broadcast state or scope changes without introducing a direct
/// dependency on Flutter. This adapter wraps a [PillarListenable] instance so
/// it can be seamlessly consumed by Flutter widgets that expect a standard
/// [Listenable], such as `ListenableBuilder` or `AnimatedBuilder`.
///
/// Rather than instantiating this class manually, consumers typically access
/// it via the `asListenable` extension getter on any [PillarListenable].
///
/// Example:
/// ```dart
/// final PillarListenable pillarListenable = pillar.changeNotifierFor(myScope);
///
/// // In a Flutter build method:
/// return ListenableBuilder(
///   listenable: pillarListenable.asListenable,
///   builder: (context, child) {
///     return Text('Scope state updated!');
///   },
/// );
/// ```
class PillarListenableAdapter implements Listenable {
  /// The underlying pure-Dart notification source being wrapped.
  ///
  /// This [PillarListenable] is responsible for the actual event tracking and
  /// dispatching when [addListener] and [removeListener] are invoked.
  final PillarListenable pillarListenable;

  /// Creates a new adapter wrapping the given [pillarListenable].
  ///
  /// Generally, developers should use the `asListenable` getter on
  /// [PillarListenable] instead of calling this constructor directly.
  const PillarListenableAdapter(this.pillarListenable);

  /// Registers a Flutter [VoidCallback] [listener] with the underlying
  /// [pillarListenable].
  ///
  /// The [listener] will be invoked whenever the [PillarListenable] dispatches
  /// an update.
  @override
  void addListener(VoidCallback listener) {
    pillarListenable.addListener(listener);
  }

  /// Unregisters a previously registered Flutter [VoidCallback] [listener]
  /// from the underlying [pillarListenable].
  @override
  void removeListener(VoidCallback listener) {
    pillarListenable.removeListener(listener);
  }
}
