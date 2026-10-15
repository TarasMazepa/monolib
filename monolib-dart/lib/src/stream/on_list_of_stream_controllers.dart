import 'dart:async';

/// Extension on a [List] of [StreamController]s.
///
/// Provides utilities to manage a collection of stream controllers, such as
/// adding a new controller to the list and automatically cleaning up when
/// the controller is canceled.
extension OnListOfStreamControllers<T> on List<StreamController<T>> {
  /// Adds the provided [listener] to this list and configures its [StreamController.onCancel] handler.
  ///
  /// When the [listener] is canceled, it will be automatically removed from this list.
  /// If the list becomes empty as a result of the removal, the optional [onEmpty]
  /// callback will be invoked.
  ///
  /// If removing the [listener] from this list throws an error, the optional
  /// [onRemoveError] callback will be invoked with the caught error and stack trace.
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
  ///   onRemoveError: (e, st) => print('Error removing: $e'),
  /// );
  /// ```
  void addAndSetupOnCancel(
    StreamController<T> listener, {
    void Function()? onEmpty,
    void Function(Object error, StackTrace stackTrace)? onRemoveError,
  }) {
    listener.onCancel = () {
      try {
        remove(listener);
      } catch (e, st) {
        onRemoveError?.call(e, st);
      }
      if (isEmpty) {
        onEmpty?.call();
      }
    };
    add(listener);
  }
}
