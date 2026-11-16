import 'package:home_widget/home_widget.dart';

import '../core/widget_data.dart';
import 'platform.dart';

/// [WidgetBridge] 的 Android 實作（Jetpack Glance 那端讀同一份 JSON）。
///
/// Flutter 的 Dart **不會在桌面上執行** —— 小工具是 launcher 用 RemoteViews/Glance 畫的。
/// 這裡只做兩件事：把資料寫進共用的 SharedPreferences、叫系統重畫。
/// 契約（key 與 JSON 形狀）凍結在 [WidgetContract]，iOS 那期讀同一份，不用重寫。
class HomeWidgetBridge implements WidgetBridge {
  /// Glance 的 receiver 類別名（不含套件前綴）。必須和 android 端的檔案同名，
  /// 對不上時 `updateWidget` 不會報錯、只會「小工具都不更新」—— 這是第 6 期最容易踩的坑。
  static const androidProvider = 'DquoteWidget';

  @override
  Future<void> publish(WidgetPayload payload) async {
    await HomeWidget.saveWidgetData(WidgetContract.quotesKey, payload.encode());
    await HomeWidget.updateWidget(androidName: androidProvider, name: androidProvider);
  }
}
