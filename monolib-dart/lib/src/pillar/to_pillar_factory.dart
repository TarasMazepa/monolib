import 'pillar_accessor.dart';

extension ToPillarFactoryOneArgument<T, P0> on T Function(P0) {
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>());
}

extension ToPillarFactoryTwoArguments<T, P0, P1> on T Function(P0, P1) {
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(pillar.get<P0>(), pillar.get<P1>());
}

extension ToPillarFactoryThreeArguments<T, P0, P1, P2>
    on T Function(P0, P1, P2) {
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) =>
          this(pillar.get<P0>(), pillar.get<P1>(), pillar.get<P2>());
}

extension ToPillarFactoryFourArguments<T, P0, P1, P2, P3>
    on T Function(P0, P1, P2, P3) {
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
        pillar.get<P0>(),
        pillar.get<P1>(),
        pillar.get<P2>(),
        pillar.get<P3>(),
      );
}

extension ToPillarFactoryFiveArguments<T, P0, P1, P2, P3, P4>
    on T Function(P0, P1, P2, P3, P4) {
  T Function(PillarAccessor) toPillarFactory() =>
      (PillarAccessor pillar) => this(
        pillar.get<P0>(),
        pillar.get<P1>(),
        pillar.get<P2>(),
        pillar.get<P3>(),
        pillar.get<P4>(),
      );
}

extension ToPillarFactorySixArguments<T, P0, P1, P2, P3, P4, P5>
    on T Function(P0, P1, P2, P3, P4, P5) {
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

extension ToPillarFactorySevenArguments<T, P0, P1, P2, P3, P4, P5, P6>
    on T Function(P0, P1, P2, P3, P4, P5, P6) {
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

extension ToPillarFactoryEightArguments<T, P0, P1, P2, P3, P4, P5, P6, P7>
    on T Function(P0, P1, P2, P3, P4, P5, P6, P7) {
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

extension ToPillarFactoryNineArguments<T, P0, P1, P2, P3, P4, P5, P6, P7, P8>
    on T Function(P0, P1, P2, P3, P4, P5, P6, P7, P8) {
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

extension ToPillarFactoryTenArguments<T, P0, P1, P2, P3, P4, P5, P6, P7, P8, P9>
    on T Function(P0, P1, P2, P3, P4, P5, P6, P7, P8, P9) {
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
