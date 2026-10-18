import 'package:monolib_dart/src/pillar/pillar_accessor.dart';

/// Extension on a 1-parameter function that adapts it into a `PillarFactory`.
///
/// The returned factory resolves the positional parameter [P0] from the
/// `Pillar` container via [PillarAccessor.get], allowing constructors or
/// functions to be registered without writing manual tear-off closures.
///
/// Example:
/// ```dart
/// // Without toPillarFactory:
/// pillar.register<UserService>(
///   factory: (accessor) => UserService(accessor.get<Database>()),
/// );
///
/// // With toPillarFactory:
/// pillar.register<UserService>(
///   factory: UserService.new.toPillarFactory(),
/// );
/// ```
extension OnFunction1<T, P0> on T Function(P0) {
  /// Converts this function into a `PillarFactory` by resolving [P0] via
  /// [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>());
}

/// Extension on a 2-parameter function that adapts it into a `PillarFactory`.
///
/// Example:
/// ```dart
/// pillar.register<UserService>(
///   factory: UserService.new.toPillarFactory(),
/// );
/// ```
extension OnFunction2<T, P0, P1> on T Function(P0, P1) {
  /// Converts this function into a `PillarFactory` by resolving [P0] and [P1]
  /// via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>(), pillar.get<P1>());
}

/// Extension on a 3-parameter function that adapts it into a `PillarFactory`.
extension OnFunction3<T, P0, P1, P2> on T Function(P0, P1, P2) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P2] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() => (PillarAccessor pillar) =>
      this(pillar.get<P0>(), pillar.get<P1>(), pillar.get<P2>());
}

/// Extension on a 4-parameter function that adapts it into a `PillarFactory`.
extension OnFunction4<T, P0, P1, P2, P3> on T Function(P0, P1, P2, P3) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P3] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
          );
}

/// Extension on a 5-parameter function that adapts it into a `PillarFactory`.
extension OnFunction5<T, P0, P1, P2, P3, P4> on T Function(P0, P1, P2, P3, P4) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P4] via [PillarAccessor.get].
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
            pillar.get<P0>(),
            pillar.get<P1>(),
            pillar.get<P2>(),
            pillar.get<P3>(),
            pillar.get<P4>(),
          );
}

/// Extension on a 6-parameter function that adapts it into a `PillarFactory`.
extension OnFunction6<T, P0, P1, P2, P3, P4, P5> on T Function(
    P0, P1, P2, P3, P4, P5) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P5] via [PillarAccessor.get].
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

/// Extension on a 7-parameter function that adapts it into a `PillarFactory`.
extension OnFunction7<T, P0, P1, P2, P3, P4, P5, P6> on T Function(
    P0, P1, P2, P3, P4, P5, P6) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P6] via [PillarAccessor.get].
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

/// Extension on an 8-parameter function that adapts it into a `PillarFactory`.
extension OnFunction8<T, P0, P1, P2, P3, P4, P5, P6, P7> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P7] via [PillarAccessor.get].
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

/// Extension on a 9-parameter function that adapts it into a `PillarFactory`.
extension OnFunction9<T, P0, P1, P2, P3, P4, P5, P6, P7, P8> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7, P8) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P8] via [PillarAccessor.get].
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

/// Extension on a 10-parameter function that adapts it into a `PillarFactory`.
extension OnFunction10<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9> on T Function(
    P0, P1, P2, P3, P4, P5, P6, P7, P8, P9) {
  /// Converts this function into a `PillarFactory` by resolving [P0] through
  /// [P9] via [PillarAccessor.get].
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
