/// Дата, відносно якої визначаються вік запису та майбутні дати
final DateTime referenceDate = DateTime(2026, 11, 1);

/// Курс гривні до долара США для перерахунку сум
const double uahPerUsd = 45.05;

/// Курс гривні до євро для перерахунку сум
const double uahPerEur = 49.53;

/// Префікс способу оплати карткою
const String cardPrefix = 'card:';

/// Кількість знаків після коми у виведених сумах
const int amountFractionDigits = 2;

/// Роздільник полів у вхідному рядку
const String fieldSeparator = ';';

/// Кількість полів у коректному рядку
const int expenseFieldCount = 6;

/// Запис про одну витрату
class Expense {
  /// Дата витрати
  final DateTime date;

  /// Категорія витрати
  final String category;

  /// Сума у валюті [currency]
  final double amount;

  /// Код валюти
  final String currency;

  /// Спосіб оплати: `cash` або `card:` з номером картки
  final String payment;

  /// Довільна примітка
  final String note;

  /// Створює витрату з уже розібраних значень
  const Expense({
    required this.date,
    required this.category,
    required this.amount,
    required this.currency,
    required this.payment,
    required this.note,
  });

  /// Створює витрату з рядка журналу [line] або кидає [FormatException], якщо рядок пошкоджений
  factory Expense.fromCsv(String line) =>
      tryParse(line) ??
      (throw FormatException('Пошкоджений рядок журналу', line));

  /// Повертає збережений екземпляр для рядка [line], створюючи його лише під час першого виклику
  factory Expense.cached(String line) =>
      _cache.putIfAbsent(line, () => Expense.fromCsv(line));

  static final Map<String, Expense> _cache = {};

  /// Розбирає рядок журналу [line] або повертає `null`, якщо формат некоректний
  static Expense? tryParse(String line) {
    final parts = line.split(fieldSeparator);
    if (parts.length != expenseFieldCount) return null;

    final date = DateTime.tryParse(parts[0]);
    final amount = double.tryParse(parts[2]);
    if (date == null || amount == null) return null;

    return Expense(
      date: date,
      category: parts[1],
      amount: amount,
      currency: parts[3],
      payment: parts[4],
      note: parts[5],
    );
  }

  /// Сума витрати, перерахована в гривні
  double get amountInUah =>
      amount *
      switch (currency) {
        'USD' => uahPerUsd,
        'EUR' => uahPerEur,
        _ => 1,
      };

  /// Вік витрати в днях відносно [referenceDate]
  int get ageInDays => referenceDate.difference(date).inDays;

  /// Чи оплачено витрату карткою
  bool get isCardPayment => payment.startsWith(cardPrefix);

  @override
  String toString() =>
      '${date.toIso8601String().split('T').first} $category: '
      '${amountInUah.toStringAsFixed(amountFractionDigits)} UAH';
}
