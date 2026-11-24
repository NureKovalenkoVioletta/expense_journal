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
