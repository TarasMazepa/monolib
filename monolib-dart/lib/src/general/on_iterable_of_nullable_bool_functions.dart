/// Provides [OnIterableOfNullableBoolFunctions], an architectural utility for
/// aggregating collections of optional predicate functions.
library;

/// An architectural utility extension for dynamically composing multiple, potentially optional
/// predicate functions (`bool Function(T)`) into a single unified evaluation criteria.
///
/// This extension simplifies the aggregation of optional domain rules, such as search filters,
/// validation constraints, or permission checks, where some criteria may be unassigned (`null`).
/// It transparently strips out `null` predicates and safely optimizes the execution of the
/// remaining rules without requiring manual `if` branching or collection filtering.
extension OnIterableOfNullableBoolFunctions<T> on Iterable<bool Function(T)?> {
  /// Fuses a collection of optional predicates into a single, strict `bool Function(T)` that
  /// validates an input against all active rules, analogous to a logical AND (`&&`) operation.
  ///
  /// This getter first filters out any `null` elements from the iterable. The returned function
  /// evaluates the provided value (e.g., `x` of type [T]) against each remaining non-null predicate
  /// sequentially. It short-circuits and returns `false` upon the first failing predicate.
  /// To optimize execution, it uses unrolled logical combinations for collections with up
  /// to 4 predicates, falling back to [Iterable.every] for larger lists.
  ///
  /// Returns `null` if the iterable contains exclusively `null` elements or is empty,
  /// indicating no constraints are enforced.
  ///
  /// Example:
  /// ```dart
  /// bool Function(User)? isActive = (u) => u.status == 'active';
  /// bool Function(User)? isAdult = null; // Optional rule not applied
  /// bool Function(User)? isVerified = (u) => u.verified;
  ///
  /// final isValidUser = [isActive, isAdult, isVerified].combinedEvery;
  ///
  /// if (isValidUser != null && isValidUser(currentUser)) {
  ///   // User passed all active criteria.
  /// }
  /// ```
  bool Function(T)? get combinedEvery =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) && p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) && p2(x) && p3(x),
        [final p1, final p2, final p3, final p4] => (x) =>
            p1(x) && p2(x) && p3(x) && p4(x),
        final ps => (x) => ps.every((p) => p(x)),
      };

  /// Fuses a collection of optional predicates into a single, permissive `bool Function(T)` that
  /// validates an input against any active rule, analogous to a logical OR (`||`) operation.
  ///
  /// This getter removes all `null` predicates from the iterable. The returned function
  /// evaluates the input of type [T] against the active predicates. It short-circuits
  /// and returns `true` as soon as any single predicate evaluates to `true`. Like [combinedEvery],
  /// it optimizes the evaluation loop by explicitly matching collections up to 4 elements
  /// before falling back to [Iterable.any].
  ///
  /// Returns `null` if the iterable contains no non-null predicates, meaning no fallback
  /// conditions or optional preferences are available to match.
  ///
  /// Example:
  /// ```dart
  /// bool Function(Log)? isError = (log) => log.level == 'ERROR';
  /// bool Function(Log)? isWarning = null; // Feature toggle disabled
  /// bool Function(Log)? isFatal = (log) => log.level == 'FATAL';
  ///
  /// final shouldAlert = [isError, isWarning, isFatal].combinedAny;
  ///
  /// if (shouldAlert != null && shouldAlert(currentLog)) {
  ///   // Log triggered at least one active alert condition.
  /// }
  /// ```
  bool Function(T)? get combinedAny =>
      switch (nonNulls.toList(growable: false)) {
        [] => null,
        [final p] => p,
        [final p1, final p2] => (x) => p1(x) || p2(x),
        [final p1, final p2, final p3] => (x) => p1(x) || p2(x) || p3(x),
        [final p1, final p2, final p3, final p4] => (x) =>
            p1(x) || p2(x) || p3(x) || p4(x),
        final ps => (x) => ps.any((p) => p(x)),
      };
}
