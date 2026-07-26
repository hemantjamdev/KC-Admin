import 'package:intl/intl.dart';

class DateTimeUtils {
  const DateTimeUtils._();

  static String formatDate(DateTime dateTime, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(dateTime);
  }

  static String formatTime(DateTime dateTime, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(dateTime);
  }
}
