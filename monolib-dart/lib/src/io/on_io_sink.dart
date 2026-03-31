import 'dart:io';

extension OnIoSink on IOSink {
  Future<void> withIOSink(Future<void> Function(IOSink) call) async {
    try {
      await call(this);
    } finally {
      await flush();
      await close();
    }
  }
}
