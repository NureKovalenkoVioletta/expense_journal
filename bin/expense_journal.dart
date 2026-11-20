import 'package:expense_journal/expense_data.dart';
import 'package:expense_journal/expense_journal.dart';

const String _sectionLine = '----------------------------------------';

const int _previewCount = 3;

void _printSection(String title) {
  print('');
  print(title);
  print(_sectionLine);
}

void main() {
  final rejected = rawExpenses.where((line) => parseLine(line) == null);
  final parsedCount = rawExpenses.length - rejected.length;

  _printSection('Розбір рядків');
  print('Розібрано записів: $parsedCount з ${rawExpenses.length}');
  print('Пошкоджені рядки:');
  rejected.forEach(print);

  _printSection('Валідація записів');
  for (final expense in rawExpenses.map(parseLine).nonNulls) {
    final violations = validateExpense(expense);
    if (violations.isNotEmpty) {
      print('${expense.note}: ${violations.join(', ')}');
    }
  }

  final expenses = rawExpenses
      .map(parseLine)
      .nonNulls
      .where((expense) => validateExpense(expense).isEmpty)
      .toList();

  _printSection('Конвеєри обробки');
  print('Коректних записів: ${expenses.length}');
  print(
    'Оплачено карткою: '
    '${totalCardSpendingUah(expenses).toStringAsFixed(amountFractionDigits)} UAH',
  );
  print('Великі витрати (від $largeExpenseThresholdUah UAH):');
  describeLargeExpenses(expenses).forEach(print);
  final stats = amountStatsUah(expenses);
  print(
    'Мінімум: ${stats.min.toStringAsFixed(amountFractionDigits)} UAH, '
    'максимум: ${stats.max.toStringAsFixed(amountFractionDigits)} UAH, '
    'середнє: ${stats.average.toStringAsFixed(amountFractionDigits)} UAH',
  );

  _printSection('Групування за категоріями');
  final totals = totalByGroupUah(groupByCategory(expenses));
  totals.forEach(
    (category, total) =>
        print('$category: ${total.toStringAsFixed(amountFractionDigits)} UAH'),
  );

  _printSection('Сортування');
  print('Найбільші за сумою:');
  sortByAmount(
    expenses,
    descending: true,
  ).take(_previewCount).map(formatExpense).forEach(print);
  print('Найраніші за датою:');
  sortByDate(expenses).take(_previewCount).map(formatExpense).forEach(print);
}
