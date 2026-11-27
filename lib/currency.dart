/// Курс гривні до долара США для перерахунку сум
const double uahPerUsd = 45.05;

/// Курс гривні до євро для перерахунку сум
const double uahPerEur = 49.53;

/// Валюта витрати, яку підтримує журнал
enum Currency {
  /// Українська гривня
  uah('UAH', 1),

  /// Долар США
  usd('USD', uahPerUsd),

  /// Євро
  eur('EUR', uahPerEur);

  /// Код валюти у вхідних рядках
  final String code;

  /// Скільки гривень коштує одна одиниця валюти
  final double uahRate;

  const Currency(this.code, this.uahRate);

  /// Повертає валюту з кодом [code] або `null`, якщо журнал її не підтримує
  static Currency? tryParse(String code) =>
      values.where((currency) => currency.code == code).firstOrNull;

  /// Перераховує суму [amount] у цій валюті в гривні
  double toUah(double amount) => amount * uahRate;
}
