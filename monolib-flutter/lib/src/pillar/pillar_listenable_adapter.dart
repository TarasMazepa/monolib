import 'package:flutter/foundation.dart';
import 'package:monolib_dart/pillar.dart';

/// An architectural adapter that bridges a pure Dart [PillarListenable] to
/// Flutter's native [Listenable] contract.
///
/// Within the Pillar dependency injection framework, [PillarListenable] provides
/// a way to broadcast state or scope lifecycle changes without introducing a direct
/// dependency on Flutter. This adapter wraps a [PillarListenable] instance so
/// it can be seamlessly consumed by native Flutter widgets that expect a standard
/// [Listenable], such as `ListenableBuilder` or `AnimatedBuilder`.
///
/// Architecturally, it delegates listener management directly to the underlying
/// notification source, enabling Pillar scope changes to safely trigger UI
/// rebuilds. Rather than instantiating this class manually, consumers typically
/// access it via the [asListenable] extension getter on [PillarListenable].
///
/// Example:
/// ```dart
/// final PillarListenable scopeNotifier = pillar.changeNotifierFor(myScope);
///
/// // Inside a Flutter widget's build method:
/// return ListenableBuilder(
///   listenable: scopeNotifier.asListenable, // Uses the adapter internally
///   builder: (context, child) {
///     return const Text('Pillar scope state has been updated!');
///   },
/// );
/// ```
class PillarListenableAdapter implements Listenable {
  /// The underlying pure Dart notification source being structurally proxied.
  ///
  /// This [PillarListenable] is responsible for the actual internal event tracking
  /// and dispatching. When [addListener] or [removeListener] are invoked on this
  /// adapter, they are safely forwarded to this underlying source.
  final PillarListenable pillarListenable;

  /// Creates a new adapter bridging the given [pillarListenable].
  ///
  /// Generally, developers should use the [asListenable] extension getter on
  /// [PillarListenable] instead of explicitly calling this constructor.
  const PillarListenableAdapter(this.pillarListenable);

  /// Registers a Flutter [VoidCallback] [listener] by safely forwarding it
  /// to the underlying [pillarListenable].
  ///
  /// The [listener] will be triggered whenever the encapsulated [PillarListenable]
  /// dispatches a state mutation or lifecycle update.
  @override
  void addListener(VoidCallback listener) {
    pillarListenable.addListener(listener);
  }

  /// Unregisters a previously registered Flutter [VoidCallback] [listener]
  /// by safely removing it from the underlying [pillarListenable].
  @override
  void removeListener(VoidCallback listener) {
    pillarListenable.removeListener(listener);
  }
}
