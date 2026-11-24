import 'package:expense_journal/expense_data.dart';
import 'package:expense_journal/expense_journal.dart';

const String _sectionLine = '----------------------------------------';

const int _previewCount = 3;

const String _foodCategory = 'Продукти';

const String _pharmacyCategory = 'Аптека';

const String _travelCategory = 'Подорожі';

void _printSection(String title) {
  print('');
  print(title);
  print(_sectionLine);
}

void main() {
  final rejected = rawExpenses.where((line) => Expense.tryParse(line) == null);
  final parsedCount = rawExpenses.length - rejected.length;

  _printSection('Розбір рядків');
  print('Розібрано записів: $parsedCount з ${rawExpenses.length}');
  print('Пошкоджені рядки:');
  rejected.forEach(print);

  _printSection('Валідація записів');
  for (final expense in rawExpenses.map(Expense.tryParse).nonNulls) {
    final violations = validateExpense(expense);
    if (violations.isNotEmpty) {
      print('${expense.note}: ${violations.join(', ')}');
    }
  }

  final expenses = rawExpenses
      .map(Expense.tryParse)
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
  sortByAmount(expenses, descending: true).take(_previewCount).forEach(print);
  print('Найраніші за датою:');
  sortByDate(expenses).take(_previewCount).forEach(print);

  _printSection('Звіт');
  print(buildReport(expenses));
  print('');
  print(
    buildReport(
      expenses,
      title: 'Найменші витрати',
      topCount: _previewCount,
      descending: false,
      separator: '; ',
    ),
  );

  _printSection('Замикання та пошук');
  final isFood = isInCategory(_foodCategory);
  print('Записів у категорії $_foodCategory: ${expenses.where(isFood).length}');
  for (final category in [_pharmacyCategory, _travelCategory]) {
    final found = expenses.where(isInCategory(category)).firstOrNull;
    print(
      'Перший запис у категорії $category: '
      '${found ?? 'не знайдено'}',
    );
  }

  _printSection('Маскування способів оплати');
  expenses
      .map((expense) => expense.payment)
      .toSet()
      .map(
        (payment) =>
            '$payment -> ${Payment.tryParse(payment)?.masked ?? payment}',
      )
      .forEach(print);

  _printSection('Конструктори');
  final line = rawExpenses.first;
  print(
    'fromCsv двічі – той самий об’єкт: '
    '${identical(Expense.fromCsv(line), Expense.fromCsv(line))}',
  );
  print(
    'cached двічі – той самий об’єкт: '
    '${identical(Expense.cached(line), Expense.cached(line))}',
  );

  _printSection('Порівняння за значенням');
  final first = Expense.fromCsv(line);
  final second = Expense.fromCsv(line);
  print('Однакові поля, той самий об’єкт: ${identical(first, second)}');
  print('Однакові поля, first == second: ${first == second}');
  print('Розмір Set з двох однакових витрат: ${{first, second}.length}');

  _printSection('Вік записів');
  final byDate = sortByDate(expenses);
  print(
    'Найстаріший: ${byDate.first}, '
    '${byDate.first.ageInDays} дн.',
  );
  print(
    'Найновіший: ${byDate.last}, '
    '${byDate.last.ageInDays} дн.',
  );
}
