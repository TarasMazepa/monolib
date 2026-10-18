import 'dart:convert';
import 'dart:io';

/// Extension on [File] that ensures parent directories exist before opening a
/// writable [IOSink].
extension FileEnsureOpenExtension on File {
  /// Opens a writable [IOSink] on this file after creating its [parent]
  /// directory.
  ///
  /// - [recursive]: Whether to create all missing ancestor directories up the
  ///   path chain. Defaults to `false` (creating only the immediate parent).
  /// - [mode]: The [FileMode] used to open the file. Defaults to
  ///   [FileMode.write].
  /// - [encoding]: The character [Encoding] used when writing strings. Defaults
  ///   to [utf8].
  ///
  /// Example:
  /// ```dart
  /// final logFile = File('/tmp/app_logs/2023/10/crash.log');
  /// final sink = await logFile.openWriteEnsureParent(recursive: true);
  /// sink.writeln('Crash report context...');
  /// await sink.close();
  /// ```
  Future<IOSink> openWriteEnsureParent({
    bool recursive = false,
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) async {
    await parent.create(recursive: recursive);
    return openWrite(mode: mode, encoding: encoding);
  }
}
