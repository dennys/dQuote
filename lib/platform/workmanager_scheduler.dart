import 'package:workmanager/workmanager.dart';

import '../di.dart';
import 'platform.dart';

/// [RefreshScheduler] 的 Android 實作。
///
/// 只用 **periodic WorkManager**，不用 AlarmManager / foreground service：
/// 使用者接受的準確度是 15 分鐘等級，這樣就不需要精確排程權限、不需要向商店交代保活理由，
/// 而且被 Doze 延後之後下次 tick 會自己補上（發過不會重發，key 記在 Settings）。
///
/// 驗收時不必等 15 分鐘：
///   `adb shell cmd jobscheduler run -f com.dennys.dquote <jobId>`
/// 或直接按設定頁的「立即執行一次檢查」。
class WorkmanagerScheduler implements RefreshScheduler {
  static const taskName = 'dquote.heartbeat';
  static const uniqueName = 'dquote-heartbeat';

  @override
  Future<void> registerPeriodic({Duration interval = const Duration(minutes: 15)}) async {
    await Workmanager().initialize(heartbeatDispatcher);
    await Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: interval,
      // keep：已在排程中就不要重排，否則每次開 app 都把時鐘歸零、永遠錯開 15 分鐘
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected), // 有網路才跑
    );
  }

  @override
  Future<void> runNow() async {
    await Workmanager().initialize(heartbeatDispatcher);
    await Workmanager().registerOneOffTask(
      '$uniqueName-now-${DateTime.now().millisecondsSinceEpoch}',
      taskName,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }
}
