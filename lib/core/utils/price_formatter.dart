import 'package:intl/intl.dart';

/// Định dạng giá tiền theo chuẩn Việt Nam (VD: 1.000.000d).
String formatPrice(int price) {
  final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
  return formatCurrency.format(price);
}
