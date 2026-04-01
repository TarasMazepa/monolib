import 'dart:io';

extension OnIoSink on IOSink {
  Future<T> withIOSink<T>(Future<T> Function(IOSink) call) async {
    try {
      return await call(this);
    } finally {
      await flush();
      await close();
    }
  }
}
