import 'package:flutter_test/flutter_test.dart';
import 'package:solomatch/shared/models/price.dart';

void main() {
  test('free price', () {
    const price = Price.free();
    expect(price.isFree, isTrue);
    expect(price.display, 'Free');
    expect(price.currency, 'NPR');
  });

  test('paid price displays with currency and grouping', () {
    expect(const Price(amount: 300).display, 'NPR 300');
    expect(const Price(amount: 150000).display, 'NPR 1,50,000');
  });

  test('round-trips through JSON', () {
    const price = Price(amount: 500);
    expect(Price.fromJson(price.toJson()), price);
  });
}
