/// A robust, scope-aware Dependency Injection (DI) and Inversion of Control (IoC)
/// container designed for managing the lifecycles and boundaries of shared resources.
///
/// The Pillar system is intended to operate as the architectural backbone of an
/// application, resolving dependencies while strictly enforcing scope hierarchies.
/// By segregating access using [PillarScope], Pillar ensures that short-lived
/// dependencies (like a request or session) cannot be leaked or improperly cached
/// by long-lived global singletons, preventing state contamination and memory leaks.
///
/// Beyond basic dependency registration and resolution, the library provides built-in
/// mechanisms for reactivity through [PillarListenable] and lifecycle management
/// via [Pillar.discard] and [Pillar.replace], making it ideal for managing
/// complex, multi-tiered application state.
library;

export 'src/pillar/pillar.dart';
export 'src/pillar/pillar_accessor.dart';
export 'src/pillar/pillar_change_notifier.dart';
export 'src/pillar/pillar_change_notifier_internal.dart';
export 'src/pillar/pillar_entry.dart';
export 'src/pillar/pillar_key.dart';
export 'src/pillar/pillar_listenable.dart';
export 'src/pillar/pillar_scope.dart';
export 'src/pillar/scope_enforcing_pillar_accessor.dart';
export 'src/pillar/scope_tracking_pillar_accessor.dart';
export 'src/pillar/to_pillar_factory.dart';
