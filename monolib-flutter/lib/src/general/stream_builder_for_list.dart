import 'package:flutter/material.dart';

class StreamBuilderForList<T> extends StatelessWidget {
  const StreamBuilderForList({
    required this.stream,
    required this.onData,
    this.onEmpty,
    this.onLoading,
    this.onError,
    super.key,
  });

  final Stream<List<T>> stream;
  final Widget Function(BuildContext context, List<T> data) onData;
  final Widget Function(BuildContext context)? onEmpty;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, Object error)? onError;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, asyncSnapshot) {
        return switch (asyncSnapshot) {
          AsyncSnapshot(error: final error?) =>
            onError != null
                ? onError!(context, error)
                : const Align(child: Text('An error occurred.')),
          AsyncSnapshot(data: null) =>
            onLoading != null
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
