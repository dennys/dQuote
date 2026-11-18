import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import '../core/alerts.dart';
import '../core/models.dart';
import '../generated/l10n/app_localizations.dart';
import 'platform.dart';

/// [NotificationGateway] 的 Android 實作（awesome_notifications 0.12）。
///
/// 三個 channel 分開，使用者可以只關「收盤日報」留「價位觸發」——這比一個全域開關實用。
/// channel 的.sound/重要性是 **channel 等級**，Android 會快取，所以改了要重啟 app 才生效
/// （平台限制，不是實作偷工）。
class AwesomeNotificationGateway implements NotificationGateway {
  AwesomeNotificationGateway({AwesomeNotifications? impl})
      : _impl = impl ?? AwesomeNotifications();

  static const channelDigest = 'dquote_digest';
  static const channelPrice = 'dquote_price';
  static const channelPnl = 'dquote_pnl';

  final AwesomeNotifications _impl;
  bool _initialized = false;

  /// 建 channel。啟動時叫一次；背景 isolate 也要叫（那邊是另一條執行緒）。
  /// 字串由呼叫端傳進來 —— 背景沒有 BuildContext，用 `lookupAppLocalizations(locale)` 取。
  @override
  Future<void> initialize({
    required String digestName,
    required String digestDesc,
    required String priceName,
    required String priceDesc,
    required String pnlName,
    required String pnlDesc,
  }) async {
    if (_initialized) return;
    await _impl.initialize(
      null,
      [
        NotificationChannel(
          channelKey: channelDigest,
          channelName: digestName,
          channelDescription: digestDesc,
          defaultColor: const Color(0xFF3F51B5),
          importance: NotificationImportance.Default,
        ),
        NotificationChannel(
          channelKey: channelPrice,
          channelName: priceName,
          channelDescription: priceDesc,
          defaultColor: const Color(0xFFE53935),
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: channelPnl,
          channelName: pnlName,
          channelDescription: pnlDesc,
          defaultColor: const Color(0xFF43A047),
          importance: NotificationImportance.High,
        ),
      ],
      debug: kDebugMode,
    );
    _initialized = true;
  }

  @override
  Future<bool> ensurePermission() async {
    if (await _impl.isNotificationAllowed()) return true;
    return _impl.requestPermissionToSendNotifications();
  }

  /// 點通知進 app：`_create` 把 deep link 放在 `payload['deep']`，這裡取出來（取過就清）。
  /// 之前這個 payload 沒人讀，點通知只是把 app 帶到前景、停在原本那個畫面。
  @override
  Future<String?> takePendingDeepLink() async {
    try {
      final action = await _impl.getInitialNotificationAction(removeFromActionEvents: true);
      final deep = action?.payload?['deep'];
      return (deep == null || deep.isEmpty) ? null : deep;
    } on Object {
      return null; // 通知層壞掉不能擋住啟動
    }
  }

  @override
  Future<void> showAlert({
    required AlertRule rule,
    required Quote? quote,
    required double? value,
    required String body,
  }) async {
    await _create(
      channelKey: switch (rule.kind) {
        AlertKind.pnl => channelPnl,
        _ => channelPrice,
      },
      title: _titleFor(rule, quote),
      body: body,
      payload: {'symbol': rule.symbol ?? '', 'deep': 'dquote://quote/${rule.symbol ?? ''}'},
    );
  }

  @override
  Future<void> showDigest({required String key, required String title, required String body}) async {
    await _create(
      channelKey: channelDigest,
      title: title,
      body: body,
      // payload 帶 key，點通知進 app 時可以知道是哪份日報（之後要做「點日報看該日明細」用）
      payload: {'digest': key, 'deep': 'dquote://portfolio'},
    );
  }

  static String _titleFor(AlertRule rule, Quote? quote) {
    final name = (quote?.name == null || quote!.name.isEmpty) ? (rule.symbol ?? 'dQuote') : quote.name;
    return name;
  }

  Future<void> _create({
    required String channelKey,
    required String title,
    required String body,
    Map<String, String>? payload,
  }) async {
    await _impl.createNotification(
      content: NotificationContent(
        // id 要每次不同，否則同一條通知會被覆寫（日报一天一條、價位觸發各自獨立）
        id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
        channelKey: channelKey,
        title: title,
        body: notificationBodyToHtml(body),
        notificationLayout: NotificationLayout.BigText,
        payload: payload,
      ),
    );
  }
}

/// awesome_notifications 的 Android 端把 body 當 HTML 排版（`Html.fromHtml`），純文字的 `\n`
/// 會被折成空白，所以改用 `<br>` 斷行；每行先 escape，股名或別名裡的 `<`、`&` 才不會被當成標籤。
@visibleForTesting
String notificationBodyToHtml(String body) =>
    body.split('\n').map(_escapeHtml).join('<br>');

String _escapeHtml(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// 背景 isolate 沒有 BuildContext，用裝置語系直接取翻譯（比照同 family 專案的做法）。
AppLocalizations localizedLocal() =>
    lookupAppLocalizations(PlatformDispatcher.instance.locale);
