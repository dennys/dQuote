import 'package:dquote/core/alerts.dart';
import 'package:dquote/data/db/database.dart';
import 'package:dquote/data/repositories/alert_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// re-arm 狀態機與觸發紀錄的上限。
///
/// 狀態機的「唯一來源是 AlertLogs」是這個 repo 最容易被改壞的地方（改成另開一個 `armed`
/// 欄位就會讓「通知歷史」頁與實際发通知的行為分岔），所以這裡把兩條性質都鎖住：
/// 只看最後一筆、每條 alert 各自獨立；外加「表不會無限長大」。
void main() {
  late AppDatabase db;
  late AlertRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = AlertRepository(db);
  });
  tearDown(() async => db.close());

  Future<int> addAlert() => repo.addAlert(
      kind: AlertKind.above, scope: AlertScope.single, symbol: '2330.TW', threshold: 100);

  test('武裝狀態只看最後一筆', () async {
    final id = await addAlert();
    // 沒寫過紀錄的 alert **不在 map 裡**；心跳那側用 `armed[id] ?? true` 預設武裝
    // （把「預設值」放在讀取端，這裡才不必為每條 alert 預先塞一筆）。
    expect(await repo.armedMap(), isEmpty);

    await repo.recordFire(id, 101);
    expect(await repo.armedMap(), {id: false}, reason: '還在門檻上 → 不重複轟使用者');

    await repo.recordClear(id, 99);
    expect(await repo.armedMap(), {id: true}, reason: '跌回門檻下 → 重新武裝');
  });

  test('每條 alert 各自獨立；超過上限的舊紀錄會被清掉（心跳不再掃全表）', () async {
    final a = await addAlert();
    final b = await addAlert();

    // 價格在門檻附近進出：一條規則就能把表寫到幾千筆（以前心跳每 15 分鐘掃全表）
    for (var i = 0; i < 400; i++) {
      await repo.recordFire(a, 101);
      await repo.recordClear(a, 99);
    }
    await repo.recordFire(b, 101);

    final armed = await repo.armedMap();
    expect(armed[a], isTrue, reason: 'a 的最後一筆是 clear');
    expect(armed[b], isFalse, reason: 'b 的最後一筆是 fire');

    final kept = await repo.history(limit: AlertRepository.historyLimit * 2);
    expect(kept.length, AlertRepository.historyLimit, reason: '表要停在一個上限，不能只增不減');
    expect(kept.first.alertId, b, reason: '清的是最舊的，最新那筆（也是狀態的依據）要留著');
  });

  test('移除 alert 不會把歷史一併刪掉（通知歷史是獨立的紀錄）', () async {
    final id = await addAlert();
    await repo.recordFire(id, 101);
    await repo.removeAlert(id);
    expect(await repo.history(), hasLength(1));
  });
}
