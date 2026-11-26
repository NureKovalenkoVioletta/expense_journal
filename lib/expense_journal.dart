import 'expense.dart';
import 'payment.dart';

export 'expense.dart';
export 'payment.dart';

/// Валюти, які підтримує журнал
const Set<String> supportedCurrencies = {'UAH', 'USD', 'EUR'};

/// Перевіряє значення [expense] і повертає перелік виявлених порушень
List<String> validateExpense(Expense expense) => [
  if (expense.amount <= 0) 'сума не додатна',
  if (expense.date.isAfter(referenceDate)) 'дата в майбутньому',
  if (!supportedCurrencies.contains(expense.currency))
    'непідтримувана валюта ${expense.currency}',
  if (expense.category.isEmpty) 'порожня категорія',
  if (expense.paymentMethod == null)
    'некоректний спосіб оплати ${expense.payment}',
];

/// Поріг суми в гривнях, від якого витрата вважається великою
const int largeExpenseThresholdUah = 500;

/// Повертає загальну суму в гривнях за витратами, оплаченими карткою
double totalCardSpendingUah(Iterable<Expense> expenses) =>
    expenses.where((expense) => expense.isCardPayment).totalUah;

/// Формує текстові описи витрат, сума яких не менша за поріг великої витрати
List<String> describeLargeExpenses(Iterable<Expense> expenses) => expenses
    .where((expense) => expense.amountInUah >= largeExpenseThresholdUah)
    .map((expense) => '$expense')
    .toList();

/// Обчислює мінімальну, максимальну та середню суму витрат у гривнях
({double min, double max, double average}) amountStatsUah(
  List<Expense> expenses,
) {
  final amounts = expenses.map((expense) => expense.amountInUah);
  return (
    min: amounts.reduce((a, b) => a < b ? a : b),
    max: amounts.reduce((a, b) => a > b ? a : b),
    average: expenses.totalUah / expenses.length,
  );
}

/// Групує витрати [expenses] за категорією
Map<String, List<Expense>> groupByCategory(Iterable<Expense> expenses) =>
    expenses.fold(
      {},
      (groups, expense) =>
          groups..putIfAbsent(expense.category, () => []).add(expense),
    );

/// Групує витрати [expenses] за видом оплати
Map<String, List<Expense>> groupByPaymentKind(Iterable<Expense> expenses) =>
    expenses.fold(
      {},
      (groups, expense) => groups
        ..putIfAbsent(
          paymentKind(expense.paymentMethod),
          () => [],
        ).add(expense),
    );

/// Обчислює загальну суму в гривнях для кожної групи витрат [groups]
Map<String, double> totalByGroupUah(Map<String, List<Expense>> groups) =>
    groups.map((key, items) => MapEntry(key, items.totalUah));

/// Повертає копію [expenses], відсортовану за сумою в гривнях
List<Expense> sortByAmount(
  Iterable<Expense> expenses, {
  bool descending = false,
}) => expenses.toList()
  ..sort(
    (a, b) => descending
        ? b.amountInUah.compareTo(a.amountInUah)
        : a.amountInUah.compareTo(b.amountInUah),
  );

/// Повертає копію [expenses], відсортовану за датою
List<Expense> sortByDate(
  Iterable<Expense> expenses, {
  bool descending = false,
}) => expenses.toList()
  ..sort(
    (a, b) => descending ? b.date.compareTo(a.date) : a.date.compareTo(b.date),
  );

/// Заголовок звіту за замовчуванням
const String defaultReportTitle = 'Звіт про витрати';

/// Кількість записів у звіті за замовчуванням
const int defaultReportTopCount = 5;

/// Роздільник колонок звіту за замовчуванням
const String defaultReportSeparator = ' | ';

/// Формує текстовий звіт із перших [topCount] витрат [expenses], упорядкованих за сумою
String buildReport(
  List<Expense> expenses, {
  String title = defaultReportTitle,
  int topCount = defaultReportTopCount,
  bool descending = true,
  String separator = defaultReportSeparator,
}) {
  final rows = sortByAmount(expenses, descending: descending)
      .take(topCount)
      .map(
        (expense) => [
          expense.date.toIso8601String().split('T').first,
          expense.category,
          '${expense.amountInUah.toStringAsFixed(amountFractionDigits)} UAH',
          expense.note,
        ].join(separator),
      );
  final buffer = StringBuffer()
    ..writeln(title)
    ..writeln('Показано ${rows.length} з ${expenses.length}')
    ..writeAll(rows, '\n');
  return buffer.toString();
}

/// Повертає предикат, що перевіряє належність витрати до категорії [category]
bool Function(Expense) isInCategory(String category) =>
    (expense) => expense.category == category;
