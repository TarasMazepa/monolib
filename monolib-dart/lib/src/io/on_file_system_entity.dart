import 'dart:io';

/// Extension on [FileSystemEntity] that provides non-throwing deletion.
extension OnFileSystemEntity on FileSystemEntity {
  /// Asynchronously deletes this [FileSystemEntity], ignoring any exceptions.
  ///
  /// Wraps [delete] in a `try`/`catch` block and silently swallows any error
  /// (such as when the path does not exist or a directory is not empty).
  ///
  /// - [recursive]: Whether to recursively delete all contents if this entity
  ///   is a directory. Defaults to `false`.
  ///
  /// Example:
  /// ```dart
  /// final cacheDir = Directory('/tmp/app_cache');
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
