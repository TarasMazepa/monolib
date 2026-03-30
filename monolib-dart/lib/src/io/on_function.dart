import 'dart:io';

extension OnFunction on IOSink Function() {
  Future<void> withIOSink(Future<void> Function(IOSink) call) async {
    final ioSink = this();
    try {
      await call(ioSink);
    } finally {
      await ioSink.flush();
      await ioSink.close();
    }
  }
}
