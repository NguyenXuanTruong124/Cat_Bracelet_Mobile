class NumberFormatter {
  NumberFormatter._();

  static String clean(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}