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
  /// Any errors thrown during the removal or by the [onEmpty] callback are caught
  /// and ignored to ensure the cancelation process completes without interrupting
  /// the stream lifecycle.
  ///
  /// Example:
  /// ```dart
  /// final controllers = <StreamController<int>>[];
  /// final controller = StreamController<int>();
  ///
  /// controllers.addAndSetupOnCancel(
  ///   controller,
  ///   onEmpty: () => print('All controllers removed!'),
  /// );
  /// ```
  void addAndSetupOnCancel(
    StreamController<T> listener, {
    void Function()? onEmpty,
  }) {
    listener.onCancel = () {
      try {
        remove(listener);
      } catch (_) {
        // ignore
      }
      if (isEmpty) {
        try {
          onEmpty?.call();
        } catch (_) {
          // ignore
        }
      }
    };
    add(listener);
  }
}
