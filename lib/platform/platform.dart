import '../core/widget_data.dart';
import '../core/alerts.dart';
import '../core/models.dart';

/// 平台能力的介面層。只為一件事存在：**讓核心邏輯可以在沒有 Android 外掛的環境下被測試**，
/// 同時把「以後做 iOS 要換的東西」集中在這三個介面，不散落在各頁。
///
/// Android 實作：`workmanager`／`awesome_notifications`／`home_widget`
/// iOS（以後）：`workmanager_apple`(BGTaskScheduler)／UNUserNotificationCenter／WidgetKit
/// 測試：`test/fakes.dart`

/// 排程。Android 下限 15 分鐘；iOS 由系統決定額度，實作只要「盡量排」即可。
abstract class RefreshScheduler {
  Future<void> registerPeriodic({Duration interval = const Duration(minutes: 15)});

  /// 立刻跑一次（開發者按鈕與 adb 之外的第二条驗收路徑）。
  Future<void> runNow();
}

/// 通知。實作必須自己處理 Android 13+ 的 POST_NOTIFICATIONS。
abstract class NotificationGateway {
  /// 建立三個通知 channel。背景 isolate 沒有 BuildContext，所以顯示文字由呼叫端給
  /// （見 `di.dart` 的 `backgroundChannelTexts()`）。啟動時-call-一次即可。
  Future<void> initialize({
    required String digestName,
    required String digestDesc,
    required String priceName,
    required String priceDesc,
    required String pnlName,
    required String pnlDesc,
  });

  /// 回傳「是否可以發通知」。第一次要請求權限時自己彈說明，不要一進 app 就問。
  Future<bool> ensurePermission();

  /// 使用者是「點通知」進來的話，回那條通知帶的 deep link（`dquote://...`），否則 null。
  /// **讀過就清掉**，同一條不會被取兩次（`main.dart` 在啟動與 resume 時問）。
  Future<String?> takePendingDeepLink();

  Future<void> showAlert({
    required AlertRule rule,
    required Quote? quote,
    required double? value,
    required String body,
  });

  Future<void> showDigest({required String key, required String title, required String body});
}

/// 桌面小工具的資料發布。契約見 [WidgetContract]。
abstract class WidgetBridge {
  Future<void> publish(WidgetPayload payload);
}
