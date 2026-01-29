# Fitness Timer — 对话总结与交接记忆

本文档为对话废弃前的详细总结，包含**已实现功能**与**待实现/待办事项**，供后续开发或新对话参考。

---

## 一、项目概览

- **项目名**：Fitness Timer（健身计时器）
- **技术栈**：Flutter，Riverpod + Provider，Isar 持久化，`flutter_foreground_task` 前台服务
- **核心能力**：简单计时（warmup/work/rest/rounds）、计划训练（多步骤、组数、组内/组间休息）、断点续传（TimerSnapshot + 墙钟校准）、前台通知倒计时、TTS 语音提示、训练历史导出/导入、中英双语 UI
- **架构要点**：见项目根目录 `ARCHITECTURE.md` 与 `docs/ARCHITECTURE_WHITEPAPER.md`（Stopwatch 防漂移、快照自愈、主/从 isolate 状态同步）

---

## 二、已实现功能（详细）

### 2.1 计划编辑器（Editor）

- **时间与总时长**：计划编辑页时间选择器与「总时长」计算正确展示；去除重复/冗余时间展示。
- **未保存更改**：
  - 退出步骤编辑弹窗时，若有未保存修改，会弹出「未保存更改」确认（中英双语）；用户可选择放弃或留下继续编辑。
  - 使用 `WillPopScope` 拦截返回（后续可考虑迁移到 `PopScope`，因 `WillPopScope` 已弃用）。
- **空计划**：允许保存「仅有标题、无步骤」的计划；在首页点击「运行」空计划时，会拦截并提示「计划为空，请先添加至少一个步骤」（或英文等价），不进入计时页。
- **步骤校验**：标题不能为空、标题/步骤名不重复、总时长 > 0、组数 1–20、持续时间 > 0、组数 > 1 时组内休息不可为 0；错误提示已中英双语（通过 `lang` 或 `AppStrings`）。
- **步骤列表**：显示组数、持续时间、组内/组间休息；删除步骤有确认；拖拽手柄在列表项右侧（与播放按钮同侧）。

### 2.2 训练页（Workout View）

- **结束/退出逻辑**：
  - 用户点击「结束训练」弹出对话框时，计时器**立即暂停**（`controller.pause()`）；若用户取消对话框，则**恢复**（`controller.resume()`）。
  - 通过 `finishWithChoice` 处理「保存 / 不保存」训练结果到历史。
- **实时卡路里**：使用 `_FlipClockChip` 在倒计时上方展示实时估算卡路里，仅统计 **Work** 阶段时间（热身、休息不计入），算法依赖 `workElapsedWithin`（见 `interval_engine.dart`）。
- **进度与阶段**：当前步骤名 + 组进度（如「步骤一：1/2」）、阶段标签（训练/休息等）已本地化。
- **手势引导**：首次进入计时页且处于「准备就绪」状态时，展示一次**手势说明浮层**（`GestureGuideOverlayGate`），说明全屏双击暂停/恢复、长按重置；是否已展示由 `gesture_guide_prefs.dart` 持久化。

### 2.3 语音与提示（TTS / 音效）

- **TTS 流程**：  
  `tts_service.dart` 提供：`speakStartStep`、`speakContinueStep`、`speakStepFinishedThenRest`、`speakRestOverThenStep`、`speakWorkoutFinishedSaved` 等，与阶段严格对应（如「准备开始训练」「开始步骤一」「休息一下」「步骤一结束休息一下」「休息结束继续步骤一」「训练结束，训练结果已保存，继续加油」）。热身不再单独播报。
- **计划训练控制器**：`plan_workout_controller.dart` 在适当时机调用上述 TTS，逻辑与产品示例一致。

### 2.4 权限与后台体验

- **计时器权限弹窗（A）**：  
  `timer_permission_dialog.dart` 先直接请求系统权限（Android：通知、精确闹钟）。仅当通知权限被拒绝后，再展示「引导去设置」的自定义说明弹窗。
- **音频 ducking（B）**：  
  `audio_session_service.dart` 中 iOS 已设置 `AVAudioSessionCategoryOptions.duckOthers`，TTS 播放时压低背景音乐；Android 使用 `AndroidAudioFocusGainType.gainTransientMayDuck`，行为一致。

### 2.5 健康同步与设置页

- **健康同步状态（F）**：  
  - 抽象接口 `HealthSyncStatus` + 占位实现 `HealthSyncStatusStub`（`health_sync_status.dart`），并在 `injection.dart` 注册。  
  - 设置页有「系统健康中心同步状态」区块：显示「未连接」、提供「请求授权」按钮；当前仅调用 stub（打日志），为后续接入 Health Connect / HealthKit 预留。
- **注意**：`health` 插件当前未加入依赖，`health_sync_service.dart` 若取消注释会报错；`simple_timer_controller.dart` 内健康上传调用已注释，避免编译错误。

### 2.6 训练历史与导出

- **训练历史页**：`workout_history_view.dart` 支持列表、批量选择、删除、导出选中为 CSV；记录展示 6 位 ID、时长、卡路里、完成率等；日期显示「今天/昨天 HH:mm」等。
- **导出/导入**：`DataExportService`、`DataImportService` 已用；首页不再重复放导出入口，导出集中在历史页。

### 2.7 代码与文档语言

- **注释与文档字符串**：`lib/` 下所有 Dart 文件的**注释、docstring** 已统一改为英文（不含翻译字面量）。
- **保留中文**：  
  - 中文文档（如 `README_CN.md`、`ARCHITECTURE.md` 等）。  
  - 代码中的**中文模式翻译**：`app_strings.dart` 及所有 `lang == AppLanguage.en ? '...' : '...'` / `isEn ? '...' : '...'` 的 UI 文案保持不变。
- **默认按钮文案**：`confirm_dialog.dart` 默认「确定/取消」改为英文 "OK"/"Cancel"；调用处传入 l10n 时仍为中文。
- **TimePicker**：内部标签「总计/分钟/秒」已改为英文 "Total"/"Min"/"Sec"（如需中文可后续通过参数传入）。

---

## 三、待实现 / 待办事项

### 3.1 功能层面

- **健康同步真实接入**：  
  - 在 `pubspec.yaml` 中启用 `health`（或对应 Health Connect/HealthKit 插件）。  
  - 用真实实现替换 `HealthSyncStatusStub`，在设置页展示真实连接状态与授权结果。  
  - 在 `simple_timer_controller.dart`（及计划训练完成路径）取消注释并调用 `_healthSync.uploadWorkout(...)`。
- **Android 14+ 后台与权限**：  
  - 若遇后台限制或通知/精确闹钟权限问题，需在真机与不同厂商（小米、华为等）上复测权限流程与前台服务保活。
- **iOS Live Activity**：  
  - 文档见 `docs/ios_live_activity/`，若需锁屏/灵动岛展示倒计时，需按 Apple 要求实现并配置。

### 3.2 代码质量与迁移

- **WillPopScope 弃用**：  
  - `lib/views/editor_view.dart` 中步骤编辑弹窗仍使用 `WillPopScope`（约 279、472 行）。  
  - 建议迁移到 `PopScope`，以支持 Android 预测性返回并消除弃用告警。
- **未使用成员**：  
  - `editor_view.dart`：`_formatTotalTime` 未使用，可删除或复用。  
  - `workout_history_view.dart`：局部变量 `completionPercent` 未使用，可删除或使用。
- **异步与 BuildContext**：  
  - `workout_history_view.dart` 约 200 行：异步间隙后使用 `BuildContext`，需用「与当前 widget 对应的 mounted 检查」保护（例如先 `if (!mounted) return;` 再 `context.xxx`），避免 `use_build_context_synchronously` 类问题。
- **deprecated API**：  
  - `workout_history_view.dart` 中 `withOpacity` 已弃用，可改为 `withValues()` 等新 API。

### 3.3 分析器与依赖

- **flutter analyze**：  
  - 当前存在：`health` 包未依赖导致的错误、`WillPopScope` 与 `withOpacity` 等 info、以及上述未使用元素等 warning。  
  - 建议在完成健康插件接入或彻底移除健康相关代码后，再跑一次 `flutter analyze` 并逐项清理。
- **TTS doc comment**：  
  - `lib/core/audio/tts_service.dart` 中部分 doc 含 `<>` 被解析为 HTML，可改为转义或普通括号描述，消除 `unintended_html_in_doc_comment`。

---

## 四、关键文件索引（便于后续查找）

| 功能/模块           | 主要文件 |
|--------------------|----------|
| 计划编辑、校验、空计划拦截 | `lib/views/editor_view.dart`，`lib/views/home_view.dart` |
| 计时页、结束/退出、卡路里、手势引导 | `lib/views/workout_view.dart`，`lib/widgets/gesture_guide_overlay.dart`，`lib/core/persistence/gesture_guide_prefs.dart` |
| 计划训练控制与 TTS 调用 | `lib/presentation/timer/plan_workout_controller.dart`，`lib/core/audio/tts_service.dart` |
| 简单计时与快照恢复   | `lib/presentation/timer/simple_timer_controller.dart`，`lib/domain/timer/interval_engine.dart`，`lib/data/timer_snapshot_repository.dart` |
| 权限与电池优化      | `lib/widgets/timer_permission_dialog.dart`，`lib/widgets/battery_onboarding_dialog.dart`，`lib/core/services/audio_session_service.dart` |
| 健康同步占位        | `lib/core/services/health_sync_status.dart`，`lib/views/settings_page.dart` |
| 训练历史与导出/导入 | `lib/views/workout_history_view.dart`，`lib/core/services/data_export_service.dart`，`lib/core/services/data_import_service.dart` |
| 依赖注入            | `lib/core/di/injection.dart` |
| 本地化              | `lib/core/localization/app_strings.dart`，`lib/core/localization/app_language.dart` |

---

## 五、小结

- **已实现**：计划编辑（含空计划与校验）、未保存提示、结束/退出时暂停与保存选择、TTS 与阶段播报、实时卡路里（仅 Work）、手势引导、权限与电池优化引导、音频 ducking、健康同步占位与设置页入口、训练历史与导出/导入、以及全库注释与 docstring 英文化（保留中文文档与 UI 翻译）。
- **待实现/待办**：健康同步真实接入、WillPopScope→PopScope 迁移、删除或使用未使用成员、修复异步 BuildContext 使用与弃用 API、解决 `health` 依赖与 analyze 告警、以及按需实现 iOS Live Activity。

废弃本对话后，可直接以本文档为「记忆」继续开发或与新对话交接。
