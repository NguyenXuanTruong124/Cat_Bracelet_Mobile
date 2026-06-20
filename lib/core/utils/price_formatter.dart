import 'package:intl/intl.dart';

class PriceFormatter {
  static String format(num price) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(price);
  }
}