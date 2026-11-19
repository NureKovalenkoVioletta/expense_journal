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
