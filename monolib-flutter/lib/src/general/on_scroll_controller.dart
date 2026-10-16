/// Provides utilities for programmatic scrolling behaviors in Flutter.
library;

import 'package:flutter/widgets.dart';

/// Extension methods for [ScrollController] to enhance scrolling capabilities.
///
/// This extension provides convenient scrolling behaviors that are commonly
/// required in user interfaces, such as auto-scrolling to the bottom of
/// dynamic lists, chat interfaces, or log viewers.
extension OnScrollController on ScrollController {
  /// Repeatedly animates the scroll position to the bottom until the end is reached.
  ///
  /// Unlike a single call to [ScrollController.animateTo] using
  /// [ScrollPosition.maxScrollExtent], this method uses [Future.doWhile] to
  /// continuously scroll downwards. This is particularly useful for dynamically
  /// sized or lazily loaded lists (like [ListView.builder]) where new elements
  /// or extents are revealed or calculated as the user scrolls.
  ///
  /// It completes when:
  /// - The scroll controller is detached (i.e., [hasClients] is false).
  /// - The bottom is reached (i.e., [ScrollPosition.extentAfter] is `0.0`).
  ///
  /// ```dart
  /// final controller = ScrollController();
  ///
  /// // In a chat app, call this after sending or receiving a new message
  /// // to ensure the view stays anchored to the most recent items.
  /// controller.scrollToTheEnd().ignore();
  /// ```
  Future<void> scrollToTheEnd() => Future.doWhile(() {
        if (!hasClients) {
          return Future.value(false);
        }
        if (position.extentAfter == 0.0) {
          return Future.value(false);
        }
        return animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        ).then((_) => hasClients);
      });
}
