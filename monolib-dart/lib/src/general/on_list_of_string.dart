import 'on_list.dart';

extension OnListOfString on List<String> {
  bool isTrimmedDeepEqualsTo(List<String> list) {
    return toMappedList((String x) => x.trim()).deepEquals(list);
  }
}
