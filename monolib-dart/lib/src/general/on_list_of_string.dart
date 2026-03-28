import 'on_list.dart';

extension OnListOfString on List<String> {
  bool isTrimmedDeepEqualsTo(List<String> list) {
    return map<String>((String x) => x.trim()).toList().deepEquals(list);
  }
}
