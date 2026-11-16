import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/models.dart';

part 'database.g.dart';

// ---------------------------------------------------------------- 資料表
//
// 8 張表，對應 PLAN.md 的資料模型。刻意全部用 TextColumn 存 enum 的 `.name`
// （不是 int index）：之後加枚舉值時舊資料不會悄悄錯位，代價只是幾 bytes。

class Instruments extends Table {
  TextColumn get symbol => text()(); // Yahoo symbol，如 2330.TW / TSM / USDTWD=X / ^TWII
  TextColumn get name => text().withDefault(const Constant(''))(); // 來源給的名稱
  TextColumn get alias => text().nullable()(); // 使用者自訂顯示名（**不進搜尋**，只是好看）
  TextColumn get currency => text().withDefault(const Constant('TWD'))();
  TextColumn get market => text().withDefault(const Constant('america'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get inWidget => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {symbol};
}

class Holdings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symbol => text()();
  TextColumn get market => text().withDefault(const Constant('taiwan'))();
  TextColumn get ccy => text().withDefault(const Constant('TWD'))();
  RealColumn get shares => real()();
  RealColumn get costPrice => real()();

  /// 買進時「1 ccy = ? 基礎貨幣」；null → 退回現匯率（匯兌損益記 0）。
  RealColumn get costRate => real().nullable()();
  DateTimeColumn get buyDate => dateTime().nullable()();
  TextColumn get broker => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 現金與外幣**同一張表**：外幣本質上就是「會隨匯率變值的現金」，
/// TWD 現金就是 `ccy='TWD', costRate=null` 的一列 → 零新增計算邏輯。
class CashPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get ccy => text()();
  RealColumn get amount => real()();
  RealColumn get costRate => real().nullable()();
  TextColumn get kind => text().withDefault(const Constant('bank'))(); // broker|bank|wallet
  TextColumn get label => text().withDefault(const Constant(''))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 走勢快取（離線也能看最後一次抓到的圖）。`rangeKey` = `<range>/<interval>`。
class Candles extends Table {
  TextColumn get symbol => text()();
  TextColumn get rangeKey => text()();
  IntColumn get time => integer()(); // epoch seconds
  RealColumn get open => real()();
  RealColumn get high => real()();
  RealColumn get low => real()();
  RealColumn get close => real()();
  RealColumn get volume => real().nullable()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {symbol, rangeKey, time};
}

/// 最新報價快取：開機立刻顯示最後-known 的數字與時間，不要白畫面等網路。
class QuoteCache extends Table {
  TextColumn get symbol => text()();
  RealColumn get price => real()();
  RealColumn get previousClose => real().nullable()();
  IntColumn get marketTime => integer().nullable()();
  RealColumn get volume => real().nullable()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get currency => text().withDefault(const Constant('TWD'))();
  TextColumn get market => text().withDefault(const Constant('america'))();

  /// 抓到的時刻（顯示「更新於 HH:mm」與判斷是否過期）
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {symbol};
}

class Alerts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => text()(); // closingDigest|above|below|dayChange|pnl|fx
  TextColumn get symbol => text().nullable()();
  RealColumn get threshold => real().nullable()();
  TextColumn get scope => text().withDefault(const Constant('single'))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 通知歷史，同時是 re-arm 狀態機的唯一來源：
/// 同一條 alert 最後一筆 `triggered == false`（代表條件已回到未成立）→ 重新武裝。
class AlertLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get alertId => integer()();
  DateTimeColumn get firedAt => dateTime()();
  RealColumn get value => real().nullable()();
  BoolColumn get triggered => boolean().withDefault(const Constant(true))();
}

/// scalar 設定（基礎貨幣、刷新間隔、紅漲綠跌、widget 列數…）。
/// 有 drift 了就不再引入 shared_preferences —— 少一個依賴、少一個 aarch64 釘版。
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// ---------------------------------------------------------------- 資料庫

@DriftDatabase(tables: [
  Instruments,
  Holdings,
  CashPositions,
  Candles,
  QuoteCache,
  Alerts,
  AlertLogs,
  Settings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.open() : super(_openConnection());

  /// 測試用：記憶體資料庫（不需要:path_provider，也不需要裝置）
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        // schema 變動時一律走 drift 的 `flutter run build_runner` 產生 migration；
        // 在這裡加 column 一定要同時加 `onUpgrade` 的 ALTER，否則既有使用者的資料會擋住升級。
      );

  static LazyDatabase _openConnection() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 'dquote.sqlite'));
        return NativeDatabase.createInBackground(file);
      });

  /// 第一次啟動種幾档預設自選股，避免使用者打開看到的是白頁。
  /// 只在 Instruments 完全空的時候做（之後完全由使用者增删）。
  Future<void> seedIfEmpty() async {
    final count = await (select(instruments)..limit(1)).get();
    if (count.isNotEmpty) return;
    // market 一律用 `Market` 常數（**不要手打字串**）：分頁是照 `Market.*.name` 過濾的，
    // 打錯一個字（曾經寫成 'index' 而不是 'stockIndex'）會讓那档**在任何分頁都不顯示**，
    // 症狀是「seed 進去了但 UI 永遠看不到」。有測試擋著（instrument_repository_test）。
    const seeds = <(String, String, String, Market)>[
      // (symbol, name, currency, market)
      ('^TWII', '加權指數', 'TWD', Market.stockIndex),
      ('2330.TW', 'TSMC', 'TWD', Market.taiwan),
      ('0050.TW', '元大台灣50', 'TWD', Market.taiwan),
      ('TSM', 'TSMC ADR', 'USD', Market.america),
      ('NVDA', 'NVIDIA', 'USD', Market.america),
      ('USDTWD=X', 'USD/TWD', 'TWD', Market.fx),
    ];
    var i = 0;
    await batch((b) {
      for (final (sym, name, ccy, market) in seeds) {
        i++;
        b.insert(instruments, InstrumentsCompanion.insert(
              symbol: sym,
              name: Value(name),
              currency: Value(ccy),
              market: Value(market.name),
              sortOrder: Value(i),
              addedAt: Value(DateTime.now()),
              inWidget: Value(i <= 4),
            ));
      }
    });
  }
}
