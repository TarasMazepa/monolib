import 'dart:async';

/// A self-managing lifecycle bridge for list-backed subscriber architectures.
///
/// In systems implementing manual pub-sub or multiplexing patterns (where listeners
/// are stored dynamically in a `List<StreamController>`), managing resource teardown
/// is traditionally error-prone. Failing to evict a [StreamController] from the list
/// when the downstream client cancels their subscription leads to memory leaks and
/// zombie connections.
///
/// This extension resolves this by establishing an automatic lifecycle linkage.
/// It intercepts the `onCancel` event of an incoming controller, guaranteeing it
/// is safely and immediately purged from the active registry without requiring manual
/// garbage collection sweeps by the host class.
extension OnListOfStreamControllers<T> on List<StreamController<T>> {
  /// Adds the provided [listener] to this list and configures its [StreamController.onCancel] handler.
  ///
  /// When the [listener] is canceled, it will be automatically removed from this list.
  /// If the list becomes empty as a result of the removal, the optional [onEmpty]
  /// callback will be invoked.
  ///
  /// If removing the [listener] from this list throws an error, the optional
  /// [onRemoveError] callback will be invoked. It can be provided as a function
  /// taking either one argument (the error) or two arguments (the error and stack trace).
  ///
  /// Errors thrown by the [onEmpty] callback are not caught, allowing them to propagate.
  ///
  /// Example:
  /// ```dart
  /// final controllers = <StreamController<int>>[];
  /// final controller = StreamController<int>();
  ///
  /// controllers.addAndSetupOnCancel(
  ///   controller,
  ///   onEmpty: () => print('All controllers removed!'),
  ///   onRemoveError: (e) => print('Error removing: $e'), // Or (e, st) => ...
  /// );
  /// ```
  void addAndSetupOnCancel(
    StreamController<T> listener, {
    void Function()? onEmpty,
    Function? onRemoveError,
  }) {
    listener.onCancel = () {
      switch (onRemoveError) {
        case null:
          remove(listener);
        case void Function(Object, StackTrace) handleExceptionAndStacktrace:
          try {
            remove(listener);
          } catch (e, st) {
            handleExceptionAndStacktrace(e, st);
          }
        case void Function(Object) handleException:
          try {
            remove(listener);
          } catch (e) {
            handleException(e);
          }
        default:
          try {
            remove(listener);
          } catch (e, st) {
            // If the user provided a function with an invalid signature,
            // we fall back to calling it dynamically to fail fast or succeed
            // if it was broadly typed.
            (onRemoveError as dynamic)(e, st);
          }
      }
      if (isEmpty) {
        onEmpty?.call();
      }
    };
    add(listener);
  }
}
