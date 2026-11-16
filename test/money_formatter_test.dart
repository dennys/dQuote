import 'package:dquote/core/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  MoneyFormatter fmtWith(Map<String, double> rates, {String base = 'TWD'}) =>
      MoneyFormatter(baseCcy: base, rateOf: (c) => rates[c]);

  group('金額顯示', () {
    test('台幣股價不顯示小數、美股顯示兩位', () {
      final f = fmtWith({});
      expect(f.amount(2295, 'TWD'), 'NT\$2,295');
      expect(f.amount(150.5, 'USD'), 'US\$150.50');
    });

    test('匯率要看到小數點後 3～4 位（0.2043 變成 0 是嚴重誤導）', () {
      final f = fmtWith({});
      expect(f.amount(32.975, 'TWD', decimals: 3), 'NT\$32.975');
      expect(f.amount(0.2043, 'TWD'), 'NT\$0.2043');
    });

    test('JPY / KRW 不顯示小數', () {
      final f = fmtWith({});
      expect(f.amount(1200, 'JPY'), '¥1,200');
      expect(f.amount(1335, 'KRW'), '₩1,335');
    });

    test('漲跌/損益帶正負號，0 不帶號', () {
      final f = fmtWith({});
      expect(f.signed(50000, 'TWD'), '+NT\$50,000');
      expect(f.signed(-50000, 'TWD'), '-NT\$50,000');
      expect(f.signed(0, 'TWD'), 'NT\$0.00');
    });

    test('百分比：正數預設加 +，兩位小數', () {
      final f = fmtWith({});
      expect(f.pct(2.345), '+2.35%');
      expect(f.pct(-1.2), '-1.20%');
      expect(f.pct(0), '0.00%');
      expect(f.pct(3.1, alwaysSign: false), '3.10%');
    });
  });

  group('基礎貨幣換算', () {
    test('本幣恒為 1，不打匯率表', () {
      final f = fmtWith({});
      expect(f.toBase(100, 'TWD'), 100);
    });

    test('外幣乘以匯率', () {
      final f = fmtWith({'USD': 32});
      expect(f.toBase(1000, 'USD'), 32000);
    });

    test('沒有匯率時回 null，由 UI 顯示「—」（**不能偷偷當成 0**）', () {
      final f = fmtWith({'USD': 32});
      expect(f.toBase(1000, 'EUR'), isNull);
    });

    test('總資產一律用基礎幣顯示', () {
      final f = fmtWith({});
      expect(f.base(757413), 'NT\$757,413');
      expect(f.signedBase(-1200), '-NT\$1,200');
    });

    test('千分位固定用逗號，不受裝置語系影響（中文環境也是逗號分位）', () {
      final f = fmtWith({});
      expect(f.amount(1234567, 'TWD'), 'NT\$1,234,567');
    });
  });

  test('unknown 幣別顯示幣別碼本身，不會變成空白', () {
    final f = fmtWith({});
    expect(f.amount(10, 'XYZ'), 'XYZ 10.00');
  });

  test('clock(null) 顯示破折號', () {
    expect(MoneyFormatter.clock(null), '—');
  });
}
