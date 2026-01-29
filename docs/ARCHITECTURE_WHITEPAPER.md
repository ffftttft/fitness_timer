# Fitness Timer — 项目架构白皮书

本文档面向技术评审与对外展示，概括本项目的分层设计、数据流、平台适配与工程化实践。

---

## 1. 总体架构

项目采用 **Clean Architecture** 思想，按职责分层，依赖由外向内、业务与平台解耦。

```
┌─────────────────────────────────────────────────────────────────┐
│  Presentation (UI)                                               │
│  views/ · widgets/ · presentation/timer/ (Riverpod Controller)  │
├─────────────────────────────────────────────────────────────────┤
│  Application / State                                             │
│  providers/ · main.dart (DI 入口)                                │
├─────────────────────────────────────────────────────────────────┤
│  Domain                                                          │
│  domain/timer/ (IntervalEngine, Interval, TimerState)             │
├─────────────────────────────────────────────────────────────────┤
│  Data & Infrastructure                                           │
│  data/ (Isar 实体与仓储) · core/services/ · core/notifications/  │
│  core/persistence/ · core/di/                                    │
├─────────────────────────────────────────────────────────────────┤
│  Models (共享)                                                    │
│  models/ (WorkoutConfig, WorkoutPlan, PlanItem)                   │
└─────────────────────────────────────────────────────────────────┘
```

- **Domain**：纯 Dart 计时引擎（IntervalEngine），基于单调时钟、不依赖 UI 或平台。
- **Data**：Isar 持久化（快照、历史）、仓储抽象与实现。
- **Presentation**：Riverpod StateNotifier 控制器 + Flutter 视图；控制器内聚 tick、快照、通知、触觉与后台服务。

---

## 2. 核心领域：计时引擎

- **IntervalEngine**（`domain/timer/interval_engine.dart`）
  - 输入：`List<Interval>`（每段 duration + type + 可选 label）。
  - 状态：`TimerState`（status, total, elapsed, remaining, currentIntervalIndex, intervals）。
  - 时间源：单调时钟（Stopwatch），避免系统改时导致计时漂移。
  - 能力：start / pause / resume / reset / tick、restoreFromSnapshot（断点续传）。
- **IntervalBuilder**：由 `WorkoutConfig` 或 `WorkoutPlan` 生成 `List<Interval>`，供引擎使用。

---

## 3. 数据层与持久化

| 用途       | 存储        | 实体/模型              | 说明 |
|------------|-------------|------------------------|------|
| 断点续传   | Isar        | TimerSnapshot          | 5 分钟效期，按 kind+sourceId 恢复 |
| 训练历史   | Isar        | WorkoutHistory         | 完成后自动写入；支持 CSV 导出/导入 |
| 配置/计划  | JSON + 路径 | WorkoutConfig / 计划列表 | shared_preferences 或 path_provider + JSON |

- **快照**：秒级节流写入，Controller 在 tick 中仅在「当前秒数变化」时写 Isar，避免写放大。
- **历史**：SimpleTimerController / PlanWorkoutController 在 `state.isFinished` 时调用 `_saveHistoryIfFinished()`，通过 `WorkoutHistoryRepository` 写入 Isar。
- **碎片整理**：应用启动时若 `timerSnapshots.count() >= 200` 则执行 `isar.compact()`，减轻碎片与读放大。

---

## 4. 后台与多端展示

- **抽象**：`TimerBackgroundService`（startService / stopService / updateNotification）。
- **Android**：`TimerBackgroundServiceImpl` 基于 `flutter_foreground_task`；主 isolate 每秒 `sendDataToTask` 推送 MM:SS，TaskHandler 在后台 isolate 中 `updateService` 更新通知栏；`foregroundServiceType: health`，符合 Android 14+ 要求。
- **iOS**：提供 `docs/ios_live_activity/` 下 SwiftUI 代码，匹配 Live Activity（灵动岛）的 Compact / Minimal / Expanded 布局，倒计时使用系统 `Text(timerInterval:...)` 由系统驱动，省电。

---

## 5. 感官与无障碍

- **触觉**：`HapticService`（selection / success / heavy / medium）在控制器内接入；场景包括最后 3 秒滴答、阶段切换、完成、用户操作（暂停/恢复/重置）。
- **全屏手势**：TimerPage / WorkoutView 最外层 `GestureDetector(behavior: HitTestBehavior.translucent)`，双击切换暂停/恢复，长按重置；手势成功后触发触觉。
- **无障碍**：计时数字与进度圆环包裹 `Semantics(label/value, liveRegion: true)`；手势层提供 `hint`（如「双击切换暂停，长按重置」），便于 TalkBack / VoiceOver。

---

## 6. 数据出口与回装

- **导出**：`DataExportService.exportAndShareCsv()` 从 Isar 读取全部 `WorkoutHistory`，用 `csv` 转 CSV，写入 `getTemporaryDirectory()`，通过 `share_plus` 唤起系统分享。
- **导入**：`DataImportService.importFromCsvFile()` 使用 `file_picker` 选择 CSV，解析后映射为 `WorkoutHistory`，批量 `WorkoutHistoryRepository.save()` 写入 Isar；首页提供「导入备份」入口。

---

## 7. 平台兼容与策略

- **Android 15 / 16KB**：`compileSdk`/`targetSdk` 35；`AndroidManifest` 中 `android:extractNativeLibs="true"`；Isar 仍为 3.x，若遇 native 崩溃可考虑迁移至 `isar_plus` 或 NDK r27+ 对齐 16KB。
- **电池优化**：首页 `BatteryOptimizationBanner` 在未忽略电池优化时展示引导；首次启动计时器时弹窗说明「通知权限」与「忽略电池优化」，并提供「打开设置」与「知道了」。
- **内存与泄漏**：无 `StreamSubscription` 未取消；计时使用 `Timer.periodic`，在 Controller 的 `dispose` 中通过 `_stopTicker()` 统一 cancel。

---

## 8. 依赖注入与入口

- **GetIt**（`core/di/injection.dart`）：注册引擎工厂、Builder 工厂、TonePlayer / TtsService / 通知 / 触觉 / 前后台服务、导出/导入服务、Isar 与各仓储；`configureDependencies()` 在 `main()` 中调用，Isar 打开后按快照数量决定是否 compact。
- **Riverpod**：`simpleTimerControllerProvider(config)`、`planWorkoutControllerProvider(args)` 为 family StateNotifier，autoDispose；视图层只读 state、调用 notifier 方法。

---

## 9. 目录与职责速览

| 目录/文件           | 职责 |
|--------------------|------|
| `lib/domain/timer/` | 计时引擎、Interval、TimerState、Builder |
| `lib/data/`         | Isar 实体（TimerSnapshot, WorkoutHistory）、仓储实现 |
| `lib/core/di/`      | GetIt 配置与 Isar 打开/compact |
| `lib/core/services/`| 触觉、前后台服务、导出/导入 |
| `lib/core/notifications/` | 本地通知抽象与实现 |
| `lib/core/persistence/` | 配置/计划/权限弹窗偏好 |
| `lib/presentation/timer/` | SimpleTimerController、PlanWorkoutController |
| `lib/views/`        | HomeView、TimerPage、WorkoutView、EditorView 等 |
| `lib/widgets/`       | 计时数字、圆环、控制栏、电池横幅、权限弹窗 |
| `docs/ios_live_activity/` | iOS Live Activity（灵动岛）SwiftUI 示例与说明 |

---

## 10. 总结

本项目在保持清晰分层的前提下，实现了高精度计时、断点续传、前台通知、历史闭环、CSV 导出/导入、触觉与无障碍、Android 15 与电池优化引导，以及 iOS 灵动岛的可落地方案说明。适合作为商业级健身计时产品的技术底座与展示案例。
