import 'dart:convert';
import 'dart:io';

/// Extension on [File] to provide a method that ensures parent directories
/// exist before opening the file for writing.
extension FileEnsureOpenExtension on File {
  /// Opens the file for writing, ensuring that its parent directories are created
  /// before opening.
  ///
  /// Awaits the creation of the parent directory using [recursive]. By default,
  /// [recursive] is true to ensure all non-existent parent directories are created.
  /// Returns the standard [IOSink] by calling [openWrite] with [mode] and [encoding].
  Future<IOSink> openWriteEnsureParent({
    bool recursive = true,
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
  }) async {
    await parent.create(recursive: recursive);
    return openWrite(mode: mode, encoding: encoding);
  }
}
