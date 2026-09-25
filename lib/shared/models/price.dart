import 'package:intl/intl.dart';

import '../../core/constants/app_constants.dart';

/// Per-player match fee. Amounts are whole currency units (NPR has no
/// commonly used minor unit). Zero means the match is free.
class Price {
  const Price({
    required this.amount,
    this.currency = AppConstants.defaultCurrency,
  }) : assert(amount >= 0, 'Price cannot be negative');

  const Price.free() : this(amount: 0);

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    amount: (json['amount'] as num).toInt(),
    currency: json['currency'] as String? ?? AppConstants.defaultCurrency,
  );

  final int amount;
  final String currency;

  bool get isFree => amount == 0;

  /// "Free" or e.g. "NPR 300".
  String get display => isFree
      ? 'Free'
      : '$currency ${NumberFormat.decimalPattern('en_IN').format(amount)}';

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'isFree': isFree,
  };

  @override
  bool operator ==(Object other) =>
      other is Price && other.amount == amount && other.currency == currency;

  @override
  int get hashCode => Object.hash(amount, currency);
}
