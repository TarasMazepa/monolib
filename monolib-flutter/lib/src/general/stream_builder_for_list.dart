import 'package:flutter/material.dart';

/// A [StatelessWidget] that wraps [StreamBuilder] with dedicated builder
/// callbacks for loading, error, empty, and populated [List] states.
///
/// While [StreamBuilder] exposes a raw [AsyncSnapshot] that requires manual
/// evaluation of data availability and error states, [StreamBuilderForList]
/// delegates rendering to distinct callbacks based on the snapshot's state.
///
/// By distinguishing between a `null` data state (loading) and an empty `[]`
/// list state, it simplifies list-based UI patterns (such as rendering a
/// [ListView] with an empty-state placeholder).
///
/// Example:
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
  /// of `data` to render the primary UI for the items.
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
  /// This callback receives the [BuildContext] and the emitted `error` object.
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
