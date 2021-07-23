import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeUtils {
  static String get currentDay {
    DateTime now = DateTime.now();
    return DateFormat.EEEE('ko_KR').format(now);
  }

  static String get currentMonth {
    DateTime now = DateTime.now();
    return DateFormat.MMM('ko_KR').format(now);
  }

  static String get currentDate {
    DateTime now = DateTime.now();
    return DateFormat.d('ko_KR').format(now);
  }
}
