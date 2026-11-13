import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leafeat_mobile/core/input/date_input_formatter.dart';

void main() {
  test('adds date separators while the user types', () {
    final formatter = DateInputFormatter();

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '03122003'),
    );

    expect(result.text, '03/12/2003');
    expect(result.selection.baseOffset, 10);
  });

  test('limits the date to eight numeric characters', () {
    final formatter = DateInputFormatter();

    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '03122003123'),
    );

    expect(result.text, '03/12/2003');
  });
}
