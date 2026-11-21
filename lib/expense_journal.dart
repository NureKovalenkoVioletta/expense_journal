/// Роздільник полів у вхідному рядку
const String fieldSeparator = ';';

/// Кількість полів у коректному рядку
const int expenseFieldCount = 6;

/// Запис про одну витрату
typedef Expense = ({
  DateTime date,
  String category,
  double amount,
  String currency,
  String payment,
  String note,
});

/// Розбирає рядок [line] у запис витрати або повертає `null`, якщо формат некоректний
Expense? parseLine(String line) {
  final parts = line.split(fieldSeparator);
  if (parts.length != expenseFieldCount) return null;

  final date = DateTime.tryParse(parts[0]);
  final amount = double.tryParse(parts[2]);
  if (date == null || amount == null) return null;

  return (
    date: date,
    category: parts[1],
    amount: amount,
    currency: parts[3],
    payment: parts[4],
    note: parts[5],
  );
}

/// Дата, відносно якої визначається, чи запис не з майбутнього
final DateTime referenceDate = DateTime(2026, 11, 1);

/// Валюти, які підтримує журнал
const Set<String> supportedCurrencies = {'UAH', 'USD', 'EUR'};

/// Перевіряє значення [expense] і повертає перелік виявлених порушень
List<String> validateExpense(Expense expense) => [
  if (expense.amount <= 0) 'сума не додатна',
  if (expense.date.isAfter(referenceDate)) 'дата в майбутньому',
  if (!supportedCurrencies.contains(expense.currency))
    'непідтримувана валюта ${expense.currency}',
  if (expense.category.isEmpty) 'порожня категорія',
];

/// Курс гривні до долара США для перерахунку сум
const double uahPerUsd = 45.05;

/// Курс гривні до євро для перерахунку сум
const double uahPerEur = 49.53;

/// Префікс способу оплати карткою
const String cardPrefix = 'card:';

/// Поріг суми в гривнях, від якого витрата вважається великою
const int largeExpenseThresholdUah = 500;

/// Кількість знаків після коми у виведених сумах
const int amountFractionDigits = 2;

/// Повертає суму витрати [expense], перераховану в гривні
double amountInUah(Expense expense) =>
    expense.amount *
    switch (expense.currency) {
      'USD' => uahPerUsd,
      'EUR' => uahPerEur,
      _ => 1,
    };

/// Повертає загальну суму в гривнях за витратами, оплаченими карткою
double totalCardSpendingUah(Iterable<Expense> expenses) => expenses
    .where((expense) => expense.payment.startsWith(cardPrefix))
    .map(amountInUah)
    .fold(0, (sum, amount) => sum + amount);

/// Повертає короткий текстовий опис витрати [expense] із сумою в гривнях
String formatExpense(Expense expense) =>
    '${expense.date.toIso8601String().split('T').first} '
    '${expense.category}: '
    '${amountInUah(expense).toStringAsFixed(amountFractionDigits)} UAH';

/// Формує текстові описи витрат, сума яких не менша за поріг великої витрати
List<String> describeLargeExpenses(Iterable<Expense> expenses) => expenses
    .where((expense) => amountInUah(expense) >= largeExpenseThresholdUah)
    .map(formatExpense)
    .toList();

/// Обчислює мінімальну, максимальну та середню суму витрат у гривнях
({double min, double max, double average}) amountStatsUah(
  List<Expense> expenses,
) {
  final amounts = expenses.map(amountInUah);
  final total = amounts.fold<double>(0, (sum, amount) => sum + amount);
  return (
    min: amounts.reduce((a, b) => a < b ? a : b),
    max: amounts.reduce((a, b) => a > b ? a : b),
    average: total / expenses.length,
  );
}

/// Групує витрати [expenses] за категорією
Map<String, List<Expense>> groupByCategory(Iterable<Expense> expenses) =>
    expenses.fold(
      {},
      (groups, expense) =>
          groups..putIfAbsent(expense.category, () => []).add(expense),
    );

/// Обчислює загальну суму в гривнях для кожної групи витрат [groups]
Map<String, double> totalByGroupUah(Map<String, List<Expense>> groups) =>
    groups.map(
      (key, items) => MapEntry(
        key,
        items.map(amountInUah).fold(0, (sum, amount) => sum + amount),
      ),
    );

/// Повертає копію [expenses], відсортовану за сумою в гривнях
List<Expense> sortByAmount(
  Iterable<Expense> expenses, {
  bool descending = false,
}) => expenses.toList()
  ..sort(
    (a, b) => descending
        ? amountInUah(b).compareTo(amountInUah(a))
        : amountInUah(a).compareTo(amountInUah(b)),
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
          '${amountInUah(expense).toStringAsFixed(amountFractionDigits)} UAH',
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
