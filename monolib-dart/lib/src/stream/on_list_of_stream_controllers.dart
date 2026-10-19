import 'dart:async';

/// Extension on [List] of [StreamController] that automatically removes
/// controllers when their subscriptions are cancelled.
extension OnListOfStreamControllers<T> on List<StreamController<T>> {
  /// Adds [listener] to this list and configures its
  /// [StreamController.onCancel] callback to remove it when cancelled.
  ///
  /// If removing [listener] leaves this list empty, the optional [onEmpty]
  /// callback is invoked.
  ///
  /// If removing [listener] from this list throws an error, the optional
  /// [onRemoveError] callback is invoked with `(error)` or
  /// `(error, stackTrace)` depending on its signature. Errors thrown by
  /// [onEmpty] are not caught.
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
