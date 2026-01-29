import 'package:flutter/material.dart';

import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  static AppStrings of(BuildContext context, AppLanguage lang) {
    return AppStrings(lang);
  }

  bool get isEn => language == AppLanguage.en;

  // Common
  String get appTitle => isEn ? 'Fitness Timer' : '健身计时器';
  String get ok => isEn ? 'OK' : '确定';
  String get cancel => isEn ? 'Cancel' : '取消';

  // Home
  String get homeTitle => appTitle;
  String get lastConfig =>
      isEn ? 'Last configuration' : '上次配置';
  String get warmup => isEn ? 'Warm-up' : '准备';
  String get work => isEn ? 'Work' : '训练';
  String get rest => isEn ? 'Rest' : '休息';
  String get rounds => isEn ? 'Rounds' : '循环次数';
  String get loadingConfig =>
      isEn ? 'Loading last saved configuration…' : '正在加载上次保存的配置…';
  String get startWorkout =>
      isEn ? 'Start workout' : '开始训练';
  String get adjustParameters =>
      isEn ? 'Adjust parameters' : '调整参数';

  // Settings
  String get settingsTitle =>
      isEn ? 'Settings' : '设置';
  String get save =>
      isEn ? 'Save' : '保存';
  String get workoutParameters =>
      isEn ? 'Workout parameters' : '训练参数';
  String get warmupSeconds =>
      isEn ? 'Warm-up (seconds)' : '准备（秒）';
  String get workSeconds =>
      isEn ? 'Work (seconds)' : '训练（秒）';
  String get restSeconds =>
      isEn ? 'Rest (seconds)' : '休息（秒）';
  String get numberOfRounds =>
      isEn ? 'Number of rounds' : '循环组数';
  String get decrease =>
      isEn ? 'Decrease' : '减少';
  String get increase =>
      isEn ? 'Increase' : '增加';
  String get hintsTitle =>
      isEn ? 'Hints' : '提示';
  String get hintsBody => isEn
      ? 'You will hear short beeps in the last 3 seconds, get haptic feedback when phases change, keep the screen on during workouts, and receive a notification when a phase ends in the background.'
      : '最后 3 秒会有短促提示音，阶段切换会有触觉反馈；训练过程中屏幕保持常亮，并在后台通过通知提醒阶段结束。';

  // Language section
  String get languageSectionTitle =>
      isEn ? 'Language' : '语言';
  String get languageDescription =>
      isEn ? 'Choose the display language for the app.'
           : '选择应用界面显示的语言。';
  String get languageEnglish =>
      isEn ? 'English' : '英语';
  String get languageChinese =>
      isEn ? 'Chinese (Simplified)' : '简体中文';

  // Timer page
  String get backTooltip => isEn ? 'Back' : '返回';
  String get workoutCompleted =>
      isEn ? 'Workout completed' : '训练完成';
  String roundProgress(int round, int total) =>
      isEn ? 'Round $round / $total' : '第 $round / $total 轮';
  String get timerHintIdle => isEn
      ? 'Tap start to run the flow (warm-up → work → rest → repeat).'
      : '点击开始进入训练流（准备 → 训练 → 休息 → 循环）。';
  String get timerHintRunning => isEn
      ? 'Stay focused and keep moving.'
      : '保持专注，坚持下去。';

  // Timer controls
  String get start => isEn ? 'Start' : '开始';
  String get pause => isEn ? 'Pause' : '暂停';
  String get reset => isEn ? 'Reset' : '重置';
  String get skip => isEn ? 'Skip' : '跳过';

  // Plan list & editor
  String get plansTitle => isEn ? 'Workout plans' : '训练计划';
  String get createPlan => isEn ? 'New plan' : '新建计划';
  String get editPlan => isEn ? 'Edit plan' : '编辑计划';
  String get planTitleLabel => isEn ? 'Title' : '标题';
  String get planDescriptionLabel =>
      isEn ? 'Description (optional)' : '描述（可选）';
  String get emptyPlansHint => isEn
      ? 'No workout plans yet. Tap "New plan" to create one.'
      : '还没有任何训练计划，点击“新建计划”开始创建。';
  String get untitledPlan => isEn ? 'Untitled plan' : '未命名训练计划';
  String totalDurationLabel(String duration) => isEn
      ? 'Total duration: $duration'
      : '总时长：$duration';
  /// Short label for time picker total (e.g. "Total: 01:30" / "总计：01:30").
  String get timePickerTotal => isEn ? 'Total' : '总计';
  /// Time picker label for minutes (Min / 分).
  String get timePickerMin => isEn ? 'Min' : '分';
  /// Time picker label for seconds (Sec / 秒).
  String get timePickerSec => isEn ? 'Sec' : '秒';
  String stepsCountLabel(int count) => isEn
      ? '$count steps'
      : '$count 个步骤';
  String get addStep => isEn ? 'Add step' : '添加步骤';
  String get stepNameLabel => isEn ? 'Step name' : '步骤名称';
  String get stepDurationLabel =>
      isEn ? 'Duration (seconds)' : '持续时间（秒）';
  String get warmupInputLabel =>
      isEn ? 'Warm-up (seconds)' : '准备时间（秒）';
  String get setsLabel => isEn ? 'Sets' : '组数';
  String get restBetweenSetsLabel =>
      isEn ? 'Rest between sets' : '组内休息时间';
  String get restBetweenPlansLabel =>
      isEn ? 'Rest between plans' : '组间休息时间';
  String get stepTypeWork => isEn ? 'Work' : '训练';
  String get stepTypeRest => isEn ? 'Rest' : '休息';
  String get deletePlan => isEn ? 'Delete plan' : '删除计划';
  String get deletePlanConfirm =>
      isEn ? 'Delete this plan?' : '确定要删除该训练计划吗？';
  String get deleteStep => isEn ? 'Delete step' : '删除步骤';
  String get reorderHint => isEn
      ? 'Long-press the handle to reorder steps.'
      : '长按右侧拖动图标可以调整步骤顺序。';
  String get titleRequiredMessage =>
      isEn ? 'Title is required.' : '标题不能为空。';

  // Phases
  String get phaseWarmup => warmup;
  String get phaseWork => work;
  String get phaseRest => rest;
  String get phaseDone => isEn ? 'Done' : '完成';

  String get lastStepLabel =>
      isEn ? 'Last step' : '最后一个步骤';
  String nextStepLabel(String name) =>
      isEn ? 'Next: $name' : '下一个：$name';

  // Notifications
  String get notificationChannelDescription =>
      isEn ? 'Phase end reminders' : '阶段结束提醒';
  String phaseFinishedBody(String phaseLabel) =>
      isEn ? '$phaseLabel finished' : '$phaseLabel结束';

  // Export
  String get exportWorkoutHistory =>
      isEn ? 'Export workout history' : '导出训练历史';
  String get exportWorkoutHistoryTooltip =>
      isEn ? 'Export history as CSV and share' : '导出历史为 CSV 并分享';
  String get exportNoData =>
      isEn ? 'No workout history yet.' : '暂无训练历史。';
  String get importWorkoutHistory =>
      isEn ? 'Import backup' : '导入备份';
  String get importWorkoutHistoryTooltip =>
      isEn ? 'Select CSV file to restore workout history' : '选择 CSV 文件恢复训练历史';
  String importSuccess(int count) =>
      isEn ? 'Imported $count record(s).' : '已导入 $count 条记录。';
  String get importFailed =>
      isEn ? 'Invalid CSV or file error.' : 'CSV 格式无效或文件错误。';
  String get batteryOptimizationHint =>
      isEn ? 'Allow ignoring battery optimization so the timer keeps running in background.'
          : '允许忽略电池优化，以便计时器在后台持续运行。';
  String get openBatterySettings =>
      isEn ? 'Open settings' : '打开设置';
  String get batteryOnboardingTitle =>
      isEn ? 'Keep timer running in background' : '保持后台计时不中断';
  String get batteryOnboardingMessage =>
      isEn
          ? 'To prevent the system (e.g. Xiaomi, Huawei) from killing the timer when the screen is off, please allow "Ignore battery optimization" for this app. Tap below to open system settings.'
          : '为防止小米、华为等系统在锁屏后强杀计时，请为本应用开启「忽略电池优化」。点击下方按钮打开系统设置。';
  String get timerPermissionDialogTitle =>
      isEn ? 'For a stable timer' : '为了计时更稳定';
  String get timerPermissionDialogMessage =>
      isEn
          ? 'We need notification permission to show the countdown in the status bar, and "Ignore battery optimization" so that manufacturers (e.g. Xiaomi, Huawei) do not kill the timer in the background. You can change these in system settings.'
          : '需要「通知权限」以在状态栏显示倒计时，并建议「忽略电池优化」以免小米、华为等厂商在后台强杀计时。可在系统设置中修改。';
  String get gotIt => isEn ? 'Got it' : '知道了';

  // Accessibility (timer & gestures)
  String remainingTimeLabel(String mmss) =>
      isEn ? 'Remaining time $mmss' : '当前剩余时间 $mmss';
  String get progressLabel =>
      isEn ? 'Workout progress' : '训练进度';
  String get gestureHintDoubleTapLongPress =>
      isEn ? 'Double tap to pause or resume, long press to reset.'
          : '双击切换暂停或恢复，长按重置。';

  // Health center sync status
  String get healthSyncStatusTitle =>
      isEn ? 'Health center sync' : '系统健康中心同步状态';
  String get healthSyncConnected => isEn ? 'Connected' : '已连接';
  String get healthSyncNotConnected => isEn ? 'Not connected' : '未连接';
  String get healthSyncRequestAuth => isEn ? 'Request access' : '请求授权';

  // Recovery hint (after background interrupt, restore from snapshot)
  String get recoveryHintMessage =>
      isEn
          ? 'Background service was interrupted. Progress has been restored from the last snapshot—you can continue the timer.'
          : '检测到异常中断，已从上次进度恢复，可继续计时。';
}

