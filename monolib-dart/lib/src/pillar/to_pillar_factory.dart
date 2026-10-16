/// Provides extension methods to seamlessly bridge standard Dart functions and constructors
/// into the [Pillar] dependency injection framework.
///
/// Architecturally, these extensions (e.g., [OnFunction1], [OnFunction2]) abstract away the boilerplate
/// of manually resolving dependencies via a [PillarAccessor]. They allow consumers to register
/// classes directly using their standard constructors or static factory methods without writing
/// explicit closure adapters. The generated [PillarFactory] automatically requests each positional
/// parameter (e.g., [P0], [P1]) from the container at runtime.
///
/// ```dart
/// // Without toPillarFactory:
/// pillar.register<UserService>(
///   factory: (accessor) => UserService(
///     accessor.get<Database>(),
///     accessor.get<ApiClient>(),
///   ),
/// );
///
/// // With toPillarFactory:
/// pillar.register<UserService>(
///   factory: UserService.new.toPillarFactory(),
/// );
/// ```
library;

import 'package:monolib_dart/src/pillar/pillar_accessor.dart';

/// Adapts a 1-parameter Dart function into a [PillarFactory].
extension OnFunction1<T, P0> on T Function(P0) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] via [PillarAccessor.get].

  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>());
}

/// Adapts a 2-parameter Dart function into a [PillarFactory].
extension OnFunction2<T, P0, P1> on T Function(P0, P1) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] and [P1] via [PillarAccessor.get].

  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>(), pillar.get<P1>());
}

/// Adapts a 3-parameter Dart function into a [PillarFactory].
extension OnFunction3<T, P0, P1, P2> on T Function(P0, P1, P2) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P2] via [PillarAccessor.get].

  T Function(PillarAccessor) toPillarFactory() => (PillarAccessor pillar) =>
      this(pillar.get<P0>(), pillar.get<P1>(), pillar.get<P2>());
}

/// Adapts a 4-parameter Dart function into a [PillarFactory].
extension OnFunction4<T, P0, P1, P2, P3> on T Function(P0, P1, P2, P3) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P3] via [PillarAccessor.get].

  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
          );
}

/// Adapts a 5-parameter Dart function into a [PillarFactory].
extension OnFunction5<T, P0, P1, P2, P3, P4> on T Function(P0, P1, P2, P3, P4) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P4] via [PillarAccessor.get].

  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
          );
}

/// Adapts a 6-parameter Dart function into a [PillarFactory].
extension OnFunction6<T, P0, P1, P2, P3, P4, P5> on T Function(
    P0, P1, P2, P3, P4, P5) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P5] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
            pillar.get<P5>(),
          );
}

/// Adapts a 7-parameter Dart function into a [PillarFactory].
extension OnFunction7<T, P0, P1, P2, P3, P4, P5, P6> on T Function(
    P0, P1, P2, P3, P4, P5, P6) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P6] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
            pillar.get<P5>(),
            pillar.get<P6>(),
          );
}

/// Adapts an 8-parameter Dart function into a [PillarFactory].
extension OnFunction8<T, P0, P1, P2, P3, P4, P5, P6, P7> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P7] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
            pillar.get<P5>(),
            pillar.get<P6>(),
            pillar.get<P7>(),
          );
}

/// Adapts a 9-parameter Dart function into a [PillarFactory].
extension OnFunction9<T, P0, P1, P2, P3, P4, P5, P6, P7, P8> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7, P8) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P8] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
            pillar.get<P5>(),
            pillar.get<P6>(),
            pillar.get<P7>(),
            pillar.get<P8>(),
          );
}

/// Adapts a 10-parameter Dart function into a [PillarFactory].
extension OnFunction10<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7, P8, P9) {
  /// Transforms this function into a [PillarFactory] by resolving [P0] through [P9] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
            pillar.get<P5>(),
            pillar.get<P6>(),
            pillar.get<P7>(),
            pillar.get<P8>(),
            pillar.get<P9>(),
          );
}
