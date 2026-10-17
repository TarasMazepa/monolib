/// Provides an architectural utility to gracefully open writable streams on
/// files that might be situated within currently uncreated directories.
library;

import 'dart:convert';
import 'dart:io';

/// Integrates directory creation directly into the stream opening lifecycle
/// of a [File].
///
/// In standard Dart I/O, calling [File.openWrite] on a path where the parent
/// directories do not yet exist will fail with a `FileSystemException`. This
/// extension bridges that gap, acting as a unified utility to lazily guarantee
/// that the storage path is valid before the asynchronous write stream is bound,
/// effectively preventing initialization crashes during disk writes.
extension FileEnsureOpenExtension on File {
  /// Opens a streaming [IOSink] on the target file, ensuring the [parent]
  /// directories are successfully constructed beforehand.
  ///
  /// This wraps the native [openWrite] API by executing an asynchronous check
  /// and creation of the [File]'s parent [Directory] structure.
  ///
  /// - [recursive]: Indicates whether all missing parent components up the path
  ///   chain should be created. By default, this is `false`, meaning only the
  ///   immediate parent is created. Note that you likely want to pass `true`
  ///   if the file resides deeply within a dynamically determined path.
  /// - [mode]: The [FileMode] configuring how data is appended or written.
  ///   Defaults to [FileMode.write], which overwrites existing file content.
  /// - [encoding]: The character encoding strategy to apply when writing strings.
  ///   Defaults to [utf8].
  ///
  /// Returns a [Future] resolving to the standard, ready-to-write [IOSink].
  ///
  /// Example:
  /// ```dart
  /// final logFile = File('/tmp/app_logs/2023/10/crash.log');
  /// // Safely creates /tmp/app_logs/2023/10 if missing before streaming
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
