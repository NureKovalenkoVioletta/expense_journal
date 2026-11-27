/// Сутність, яка має власний ідентифікатор
abstract interface class Identifiable {
  /// Унікальний ідентифікатор сутності
  String get id;
}

/// Сховище сутностей, доступних за ідентифікатором
class Repository<T extends Identifiable> {
  final Map<String, T> _items = {};

  /// Кількість сутностей у сховищі
  int get length => _items.length;

  /// Додає сутність [item] або замінює наявну з тим самим ідентифікатором
  void add(T item) => _items[item.id] = item;

  /// Повертає сутність з ідентифікатором [id] або `null`, якщо її немає
  T? findById(String id) => _items[id];

  /// Повертає сутності, які задовольняють умову [test]
  Iterable<T> where(bool Function(T item) test) => _items.values.where(test);
}
