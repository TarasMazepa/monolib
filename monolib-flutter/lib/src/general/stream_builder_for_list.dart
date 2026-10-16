/// A specialized [StreamBuilder] wrapper for handling lists of data.
///
/// This library provides [StreamBuilderForList] to simplify the boilerplate
/// of managing [AsyncSnapshot] states (loading, error, empty, and populated)
/// when consuming a [Stream] of [List]s.
library;

import 'package:flutter/material.dart';

/// A specialized [StreamBuilder] wrapper that provides explicit UI states for a
/// [Stream] emitting lists of data.
///
/// While [StreamBuilder] exposes a raw [AsyncSnapshot] that requires manual
/// evaluation of data availability and error states, [StreamBuilderForList]
/// abstracts this boilerplate. It leverages pattern matching on the
/// [AsyncSnapshot] to delegate rendering to distinct builder callbacks based
/// on the stream's current state: loading, error, empty list, or populated list.
///
/// This is particularly useful for list-based UI patterns (like displaying a
/// [ListView] of items fetched from a stream) where an empty list often requires
/// a different visual representation (e.g., a "No items found" message) than a
/// list containing elements.
///
/// Example usage:
/// ```dart
/// StreamBuilderForList<String>(
///   stream: myStringListStream,
///   onLoading: (context) => const CircularProgressIndicator(),
///   onEmpty: (context) => const Text('No results available.'),
///   onError: (context, error) => Text('Failed to load: $error'),
///   onData: (context, data) {
///     return ListView.builder(
///       itemCount: data.length,
///       itemBuilder: (context, index) => Text(data[index]),
///     );
///   },
/// )
/// ```
class StreamBuilderForList<T> extends StatelessWidget {
  /// Creates a [StreamBuilderForList] to handle a [Stream] of [List]s.
  ///
  /// The [stream] and [onData] callbacks are required. If [onEmpty],
  /// [onLoading], or [onError] are omitted, the widget provides sensible
  /// default fallback UI components for those states.
  const StreamBuilderForList({
    required this.stream,
    required this.onData,
    this.onEmpty,
    this.onLoading,
    this.onError,
    super.key,
  });

  /// The asynchronous [Stream] of [List]s to which this builder is subscribed.
  final Stream<List<T>> stream;

  /// The builder callback invoked when the stream emits a non-empty [List].
  ///
  /// This callback is provided with the [BuildContext] and the populated list
  /// of [data] to render the primary UI for the items.
  final Widget Function(BuildContext context, List<T> data) onData;

  /// The builder callback invoked when the stream emits an empty [List].
  ///
  /// If null, defaults to returning a [SizedBox.shrink], effectively hiding
  /// the widget when there is no data to display.
  final Widget Function(BuildContext context)? onEmpty;

  /// The builder callback invoked when the stream is actively waiting for its
  /// first event (i.e., when the [AsyncSnapshot] has no data and no error).
  ///
  /// If null, defaults to a centered [CircularProgressIndicator].
  final Widget Function(BuildContext context)? onLoading;

  /// The builder callback invoked when the stream emits an error.
  ///
  /// This callback receives the [BuildContext] and the emitted [error] object.
  /// If null, defaults to displaying a centered [Text] widget with a generic
  /// error message.
  final Widget Function(BuildContext context, Object error)? onError;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, asyncSnapshot) {
        return switch (asyncSnapshot) {
          AsyncSnapshot(error: final error?) => onError != null
              ? onError!(context, error)
              : const Align(child: Text('An error occurred.')),
          AsyncSnapshot(data: null) => onLoading != null
              ? onLoading!(context)
              : const Align(child: CircularProgressIndicator()),
          AsyncSnapshot(data: []) =>
            onEmpty != null ? onEmpty!(context) : const SizedBox.shrink(),
          AsyncSnapshot(data: final data?) => onData(context, data),
        };
      },
    );
  }
}
