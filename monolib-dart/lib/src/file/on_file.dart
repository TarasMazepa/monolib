import 'dart:io';

import '../general/retry_on_failure.dart';

extension OnFile on File {
  bool retryingExistsSync({int times = 3}) {
    return existsSync.callWithRetryOnFailure(times: times);
  }

  bool retryingDoesNotExistSync({int times = 3}) {
    return !retryingExistsSync(times: times);
  }
}
