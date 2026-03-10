import 'package:intl/intl.dart';

extension OnDateTime on DateTime {
  static final DateFormat _thisYearFormat = DateFormat.MMMd().add_jm();
  static final DateFormat _notThisYearFormat = DateFormat.yMMMd().add_jm();

  String get adaptiveYMMMDjm {
    if (year == DateTime.now().year) {
      return _thisYearFormat.format(this);
    }
    return _notThisYearFormat.format(this);
  }
}
