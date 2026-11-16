import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import 'app.dart';
import 'di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = await AppContainer.bootstrap();

  // 排程在啟動時就註冊（冪等：已在排程中不會重排）。
  await container.scheduler.registerPeriodic();

  // 小工具的按鈕回呼要在 app 開過一次後才存得下來（home_widget 把 handle 存進 SharedPreferences）。
  await HomeWidget.registerInteractivityCallback(widgetInteractivityDispatcher);

  // 點通知進來的話優先去那條通知指的頁面（app 已在背景跑時由 app.dart 的 resume 補問）。
  final deep = await container.notification.takePendingDeepLink();
  runApp(DQuoteApp(
      initialRoute: initialRouteOf(deep ?? PlatformDispatcher.instance.defaultRouteName)));
}
