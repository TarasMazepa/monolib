/// Provides architectural utilities for robust file system cleanup and teardown operations.
///
/// In real-world applications (such as managing caches, temporary generated files, or
/// local file-based databases), attempting to delete a file or directory that has already
/// been removed, locked by another process, or never existed can throw unhandled exceptions.
/// This library centralizes a fail-safe deletion mechanism to prevent routine cleanup
/// tasks from crashing the application or disrupting the teardown lifecycle.
library;

import 'dart:io';

/// Enhances [FileSystemEntity] (such as [File] and [Directory]) with safe, non-throwing
/// operations.
///
/// This extension acts as a fault-tolerant utility for teardown processes where guaranteeing the removal
/// of a file or directory is best-effort. It abstracts away the boilerplate of wrapping
/// native [FileSystemEntity.delete] calls in `try-catch` blocks, which are otherwise prone to failing if the
/// path does not exist or access is denied.
extension OnFileSystemEntity on FileSystemEntity {
  /// Asynchronously deletes this [FileSystemEntity] without throwing any exceptions.
  ///
  /// This method wraps the native [delete] call in a generic `catch (_)` block. If the
  /// deletion fails for any reason (e.g., the path is not found, the directory is not
  /// empty when [recursive] is false, or due to a `FileSystemException`), the error is
  /// silently swallowed and execution continues.
  ///
  /// - [recursive]: If `true`, deletes a directory and its contents recursively.
  ///   Defaults to `false`. If applied to a file, this parameter is ignored by the
  ///   underlying [delete] implementation.
  ///
  /// ```dart
  /// final cacheDir = Directory('/tmp/app_cache');
  /// // Safely attempt to clear the cache during app teardown without crashing
  /// // if the cache directory was already removed by the OS.
  /// await cacheDir.deleteQuietly(recursive: true);
  /// ```
  Future<void> deleteQuietly({bool recursive = false}) async {
    try {
      await delete(recursive: recursive);
    } catch (_) {
      // no op
    }
  }
}
