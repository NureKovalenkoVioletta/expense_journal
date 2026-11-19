import 'package:expense_journal/expense_data.dart';
import 'package:expense_journal/expense_journal.dart';

void main() {
  final rejected = rawExpenses.where((line) => parseLine(line) == null);
  final parsedCount = rawExpenses.length - rejected.length;

  print('Розібрано записів: $parsedCount з ${rawExpenses.length}');
  print('Пошкоджені рядки:');
  rejected.forEach(print);
}
