import 'package:dquote/core/models.dart';
import 'package:dquote/core/symbol.dart';
import 'package:flutter_test/flutter_test.dart';

/// 代號解析是使用者接觸 app 的第一道門，而且**不打網路**，所以每種輸入都該有斷言。
/// 規則依據 2026-11 對 Yahoo 的實測（見 PLAN.md）。
void main() {
  String? sym(String raw) => parseSymbol(raw)?.yahooSymbol;
  Market? mkt(String raw) => parseSymbol(raw)?.market;

  group('台股', () {
    test('4 碼數字自動補 .TW（Yahoo 不帶後綴會回 Not Found）', () {
      expect(sym('2330'), '2330.TW');
      expect(sym('0050'), '0050.TW');
      expect(sym(' 2330 '), '2330.TW');
      expect(mkt('2330'), Market.taiwan);
    });

    test('實測 Yahoo 沒有 .TWO，一律改寫成 .TW', () {
      expect(sym('6443.TWO'), '6443.TW');
      expect(sym('6443.two'), '6443.TW');
      expect(sym('6443.tw'), '6443.TW');
    });

    test('大寫化', () {
      expect(sym('tsm'), 'TSM');
      expect(sym('nvda'), 'NVDA');
    });
  });

  group('美股 / ADR', () {
    test('TSM 是 ADR 的正字（TSMC 不存在）', () {
      expect(sym('TSM'), 'TSM');
      expect(mkt('TSM'), Market.america);
    });
    test('含小數點的 Class 股', () {
      expect(sym('BRK.B'), 'BRK.B');
    });
    test('3 碼是美股，**不是**匯率（TSM/AMD/IBM 的誤判會毁掉整個 app）', () {
      expect(mkt('AMD'), Market.america);
      expect(mkt('IBM'), Market.america);
    });
  });

  group('匯率', () {
    test('各種寫法都收斂成 <BASE><TARGET>=X', () {
      expect(sym('USD/TWD'), 'USDTWD=X');
      expect(sym('usd/twd'), 'USDTWD=X');
      expect(sym('USD-TWD'), 'USDTWD=X');
      expect(sym('USDTWD'), 'USDTWD=X');
      expect(sym('USDTWD=X'), 'USDTWD=X');
      expect(mkt('USD/TWD'), Market.fx);
    });

    test('Yahoo 慣用的 TWD=X（= USD/TWD）也接，並統一換成 USDTWD=X', () {
      expect(sym('TWD=X'), 'USDTWD=X');
    });

    test('反過來寫 TWD/USD 也對到同一档（本 app 只有「1 外幣 = ? 台幣」這個方向）', () {
      expect(sym('TWD/USD'), 'USDTWD=X');
    });

    test('非台幣的貨幣對保留原方向', () {
      expect(sym('EUR/JPY'), 'EURJPY=X');
    });

    test('裸幣別不猜成匯率（會跟美股 ticker 撞名），要用 / 寫', () {
      expect(parseSymbol('USD'), isNotNull); // USD 本身是合法 ticker 形状
      expect(mkt('USD'), Market.america);
    });

    test('fxSymbol() 給匯率分頁用', () {
      expect(fxSymbol('USD').yahooSymbol, 'USDTWD=X');
      expect(fxSymbol('JPY').yahooSymbol, 'JPYTWD=X');
      expect(fxSymbol('USD', 'JPY').yahooSymbol, 'USDJPY=X');
    });
  });

  group('指數與加密', () {
    test('^TWII（實測可用）', () {
      expect(sym('^TWII'), '^TWII');
      expect(mkt('^TWII'), Market.stockIndex);
    });
    test('含 - 的放行給加密', () {
      expect(sym('BTC-USD'), 'BTC-USD');
      expect(mkt('BTC-USD'), Market.crypto);
    });
  });

  group('無法辨識 → null（UI 顯示「無法辨識的代號」，不要瞎猜）', () {
    for (final bad in ['', '   ', '台積電', '12', '12345678901234', '^', '=', '/']) {
      test('「$bad」', () => expect(parseSymbol(bad), isNull));
    }
  });
}
