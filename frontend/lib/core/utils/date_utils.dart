import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormatter = DateFormat('yyyy-MM-dd');
  static final _dateTimeFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static String date(DateTime value) => _dateFormatter.format(value);

  static String dateTime(DateTime value) => _dateTimeFormatter.format(value);

  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
