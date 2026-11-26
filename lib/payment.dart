/// Позначення оплати готівкою
const String cashPayment = 'cash';

/// Кількість останніх цифр номера, які залишаються видимими після маскування
const int visibleDigits = 4;

/// Довжина коду країни на початку IBAN
const int ibanCountryCodeLength = 2;

/// Видима частина замаскованого номера картки перед останніми цифрами
const String cardMaskPrefix = '**** **** **** ';

/// Шаблон оплати карткою: префікс `card:` і 16 цифр номера
final RegExp cardPaymentPattern = RegExp(r'^card:(?<number>\d{16})$');

/// Шаблон оплати переказом: префікс `transfer:` і український IBAN
final RegExp transferPaymentPattern = RegExp(r'^transfer:(?<iban>UA\d{27})$');

/// Спосіб оплати витрати
sealed class Payment {
  /// Створює спосіб оплати
  const Payment();

  /// Розпізнає спосіб оплати в рядку [raw] або повертає `null`, якщо формат невідомий
  static Payment? tryParse(String raw) {
    if (raw == cashPayment) return const CashPayment();
    if (cardPaymentPattern.firstMatch(raw)?.namedGroup('number')
        case final number?) {
      return CardPayment(number);
    }
    if (transferPaymentPattern.firstMatch(raw)?.namedGroup('iban')
        case final iban?) {
      return TransferPayment(iban);
    }
    return null;
  }

  /// Подання способу оплати для виведення з прихованим номером рахунку
  String get masked;
}

/// Маскування номера для способів оплати, які мають номер рахунку або картки
mixin MaskedNumber on Payment {
  /// Повний номер, який потрібно приховати
  String get accountNumber;

  /// Видима частина замаскованого номера перед останніми цифрами
  String get maskPrefix;

  @override
  String get masked =>
      '$maskPrefix${accountNumber.substring(accountNumber.length - visibleDigits)}';
}

/// Оплата готівкою
final class CashPayment extends Payment {
  /// Створює оплату готівкою
  const CashPayment();

  @override
  String get masked => cashPayment;
}

/// Оплата банківською карткою
final class CardPayment extends Payment with MaskedNumber {
  /// Номер картки
  final String number;

  /// Створює оплату карткою з номером [number]
  const CardPayment(this.number);

  @override
  String get accountNumber => number;

  @override
  String get maskPrefix => cardMaskPrefix;
}

/// Оплата банківським переказом
final class TransferPayment extends Payment with MaskedNumber {
  /// Номер рахунку отримувача у форматі IBAN
  final String iban;

  /// Створює оплату переказом на рахунок [iban]
  const TransferPayment(this.iban);

  @override
  String get accountNumber => iban;

  @override
  String get maskPrefix =>
      '${iban.substring(0, ibanCountryCodeLength)}** **** **** ';
}

/// Повертає назву виду оплати для [payment]; `null` означає нерозпізнаний спосіб
String paymentKind(Payment? payment) => switch (payment) {
  CashPayment() => 'готівка',
  CardPayment() => 'картка',
  TransferPayment() => 'переказ',
  MaskedNumber() => 'інший з номером',
  null => 'невідомий',
};
