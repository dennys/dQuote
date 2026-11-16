import 'package:dquote/core/models.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/quote_repository.dart';
import 'package:dquote/domain/fx_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// 匯率不能「抓過一次就永遠不重抓」：總資產與匯兌損益全部問這裡，
/// 凍住的後果是：長時間開著的 app 用早上的匯率算傍晚的資產，而且畫面上看不出來。
void main() {
  late AppDatabase db;
  late FakeQuoteSource source;
  late QuoteRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    source = FakeQuoteSource({
      'USDTWD=X': quoteOf('USDTWD=X', 32.9, market: Market.fx),
    });
    repo = QuoteRepository(db, source);
  });

  tearDown(() async => db.close());

  test('TTL 內不重抓；過期了一定要再抓一次', () async {
    var now = DateTime.utc(2026, 11, 20, 1);
    final fx = FxService(repo, clock: () => now);

    await fx.ensureRates(['USD']);
    expect(fx.rateOf('USD'), 32.9);
    expect(source.requested.where((s) => s == 'USDTWD=X'), hasLength(1));

    await fx.ensureRates(['USD']);
    expect(source.requested.where((s) => s == 'USDTWD=X'), hasLength(1), reason: 'TTL 內不用重打');

    now = now.add(const Duration(minutes: 6));
    source.quotes['USDTWD=X'] = quoteOf('USDTWD=X', 31.5, market: Market.fx);
    await fx.ensureRates(['USD']);
    expect(source.requested.where((s) => s == 'USDTWD=X'), hasLength(2));
    expect(fx.rateOf('USD'), 31.5, reason: '沒重抓就會一直用舊匯率換算總資產');
  });

  test('force = true 不管新不新都重抓（使用者按重新整理）', () async {
    final fx = FxService(repo);
    await fx.ensureRates(['USD']);
    await fx.ensureRates(['USD'], force: true);
    expect(source.requested.where((s) => s == 'USDTWD=X'), hasLength(2));
  });

  test('本幣不該去打網路', () async {
    final fx = FxService(repo);
    await fx.ensureRates(['TWD']);
    expect(source.requested, isEmpty);
    expect(fx.rateOf('TWD'), 1);
  });
}
