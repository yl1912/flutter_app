class MoneyFormatter {
  static String format(dynamic value) {
    if (value == null) return '0';

    final int number = value is int
        ? value
        : int.tryParse(value.toString()) ?? 0;

    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    return buffer.toString().split('').reversed.join('');
  }
}
