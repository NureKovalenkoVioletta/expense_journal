import 'currency.dart';
import 'payment.dart';
import 'repository.dart';

/// Дата, відносно якої визначаються вік запису та майбутні дати
final DateTime referenceDate = DateTime(2026, 11, 1);

/// Кількість знаків після коми у виведених сумах
const int amountFractionDigits = 2;

/// Роздільник полів у вхідному рядку
const String fieldSeparator = ';';

/// Кількість полів у коректному рядку
const int expenseFieldCount = 6;

/// Запис про одну витрату
class const Expense({
  /// Дата витрати
  required final DateTime date,

  /// Категорія витрати
  required final String category,

  /// Сума у валюті [currency]
  required final double amount,

  /// Код валюти
  required final String currency,

  /// Спосіб оплати: `cash`, `card:` з номером картки або `transfer:` з IBAN
  required final String payment,

  /// Довільна примітка
  required final String note,
}) implements Identifiable {
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
  double get amountInUah => knownCurrency?.toUah(amount) ?? amount;

  /// Валюта витрати або `null`, якщо журнал її не підтримує
  Currency? get knownCurrency => Currency.tryParse(currency);

  /// Вік витрати в днях відносно [referenceDate]
  int get ageInDays => referenceDate.difference(date).inDays;

  /// Розпізнаний спосіб оплати або `null`, якщо формат невідомий
  Payment? get paymentMethod => Payment.tryParse(payment);

  /// Чи оплачено витрату карткою
  bool get isCardPayment => paymentMethod is CardPayment;

  @override
  bool operator ==(Object other) =>
      other is Expense &&
      date == other.date &&
      category == other.category &&
      amount == other.amount &&
      currency == other.currency &&
      payment == other.payment &&
      note == other.note;

  @override
  int get hashCode =>
      Object.hash(date, category, amount, currency, payment, note);

  /// Дата витрати у форматі РРРР-ММ-ДД
  String get isoDate => date.toIso8601String().split('T').first;

  @override
  String get id => '$isoDate/$category';

  @override
  String toString() =>
      '$isoDate $category: '
      '${amountInUah.toStringAsFixed(amountFractionDigits)} UAH';
}

/// Підсумкові обчислення для колекції витрат
extension ExpenseTotals on Iterable<Expense> {
  /// Загальна сума витрат у гривнях
  double get totalUah =>
      map((expense) => expense.amountInUah)
          .fold(0, (sum, amount) => sum + amount);
}
