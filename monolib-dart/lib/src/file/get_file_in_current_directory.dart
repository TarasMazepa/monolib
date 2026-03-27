import 'dart:io';

File getFileInCurrentDirectory(String name) =>
    File('${Directory.current.path}/$name');
