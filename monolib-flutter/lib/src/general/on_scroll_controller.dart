import 'package:flutter/widgets.dart';

extension OnScrollController on ScrollController {
  Future<void> scrollToTheEnd() => Future.doWhile(() {
        if (!hasClients) {
          return Future.value(false);
        }
        if (position.extentAfter == 0.0) {
          return Future.value(false);
        }
        return animateTo(
          position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
        ).then((_) => hasClients);
      });
}
