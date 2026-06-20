import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String ddMMyyyy(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateString;
    }
  }
}