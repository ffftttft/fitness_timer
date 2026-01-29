# Fitness Timer — 项目架构白皮书

本文档说明本项目的核心设计：**如何利用 Stopwatch 解决 Dart Timer 漂移**、**TimerSnapshot 配合墙钟校准的自愈逻辑**、以及**通过 TaskHandler 实现主/从隔离区的状态同步**。

---

## 1. 核心亮点：用 Stopwatch 解决 Dart Timer 漂移

### 问题背景

Dart 的 `Timer.periodic` 与 `Future.delayed` 基于事件循环调度，会受到以下影响而产生**累积漂移**：

- 事件队列拥堵时，回调执行被推迟，下一次触发仍按「固定间隔」从上次调度点算起，导致实际经过的墙上时间与「理论经过时间」不一致。
- 若用「每次 tick 累加固定时长」来推算当前时间，误差会随运行时间线性放大，无法满足健身计时对**秒级精度**的要求。

### 本项目的做法：单调时钟 + 按「已过时间」推算状态

我们**不**用 `Timer.periodic` 的触发次数来推算时间，而是：

1. **用单调时钟作为唯一时间源**  
   在 `IntervalEngine` 中引入 `MonotonicNow`（默认实现为基于 `Stopwatch` 的单例）。`Stopwatch` 从第一次 `start()` 起累计的是**进程内单调时间**，不受系统改时、NTP 校时影响，也不会因事件循环延迟而「少计」。

2. **用 Timer.periodic 只做「采样」**  
   主 isolate 中仍使用 `Timer.periodic(Duration(milliseconds: 200), ...)`，但回调里**不累加 200ms**，而是：
   - 每次回调调用 `_engine.tick()`；
   - `IntervalEngine.tick()` 内部用 `_now()`（即 Stopwatch 的 elapsed）得到**当前单调已过时间**，再根据 `_startedAt`、`_pausedAccumulated` 等推算出**本次训练已用时间**，进而得到 `elapsed`、`remaining`、`currentIntervalIndex` 等状态。

这样，**时间语义由 Stopwatch 的单调时间唯一决定**，Timer 只负责「每隔约 200ms 去问一次引擎当前状态」，即使某几次回调晚了几十毫秒，也不会在引擎内部产生累积误差。

### 代码位置与要点

- `lib/domain/timer/interval_engine.dart`  
  - `_defaultMonotonicNow()`：使用 `_MonotonicStopwatchHolder.stopwatch.elapsed`。  
  - `start()` 时记录 `_startedAt = _now()`；`tick()` 时用 `_now() - _startedAt - _pausedAccumulated` 得到当前有效已用时间，再与 `_cumulativeEnds` 比较得到当前 interval 与剩余时间。  
- 控制器层（如 `SimpleTimerController`）通过 `Timer.periodic(200ms, ...)` 调用 `_engine.tick()` 并同步 `state = _engine.state`，UI 只消费引擎输出的状态，不参与时间计算。

---

## 2. 稳定性方案：TimerSnapshot 配合墙钟校准的自愈逻辑

### 设计目标

- 应用在计时过程中被系统回收或用户切走后，再次打开时能在**5 分钟内**恢复「运行中」或「已暂停」的进度，且恢复后的剩余时间与墙钟一致（自愈）。

### 数据与语义

- **TimerSnapshot**（Isar 持久化）保存：  
  `kind` / `sourceId`、`status`（ready/running/paused/finished）、`startedAtWall`、`lastUpdatedAtWall`、`elapsedAtLastUpdate`、`pausedAccumulated`、`currentIntervalIndex`。  
- 关键点：**用墙钟（DateTime）记录「开始时间」和「上次写入时间」**，恢复时用「当前墙钟 − 上次写入墙钟」推算「自上次快照以来又过了多久」，从而得到**校准后的已用时间**，而不是依赖主进程内 Stopwatch 的连续性（进程可能已被杀）。

### 自愈流程（以 SimpleTimerController 为例）

1. **写入**  
   在 tick 回调中做**秒级节流**：仅当 `state.elapsed.inSeconds` 相对上次写入发生变化、且状态为 running/paused 时，才执行一次 `_persistSnapshot()`，将当前 `startedAtWall`、`lastUpdatedAtWall = DateTime.now()`、`elapsedAtLastUpdate = state.elapsed`、`pausedAccumulated`、`currentIntervalIndex` 写入 Isar。

2. **恢复**  
   Controller 构造时调用 `_runRecovery()`：  
   - 从 Isar 按 `kind + sourceId` 取**5 分钟内**最新的一条快照；若不存在或状态不是 running/paused，则跳过恢复。  
   - 若状态为 **running**：  
     `recoveredElapsed = elapsedAtLastUpdate + (DateTime.now() - lastUpdatedAtWall)`（即「上次快照时的已用时间」+「自上次快照到现在的墙上时间」）。  
   - 若状态为 **paused**：  
     `recoveredElapsed = elapsedAtLastUpdate`（不加上间隔，因为暂停期间时间不计）。  
   - 调用 `_engine.restoreFromSnapshot(recoveredElapsed: ..., pausedAccumulated: ..., wasPaused: ...)`，引擎内部根据 `recoveredElapsed` 重算当前 interval 与剩余时间；Controller 再恢复 `_startedAtWall`，并若原状态为 running 则重新启动 ticker 与前台通知。

3. **清理**  
   恢复成功后删除该 kind+sourceId 的快照，避免下次启动再次用同一份快照覆盖当前运行。

这样，**恢复后的时间语义完全由墙钟校准**，与进程是否被杀死、Stopwatch 是否连续无关，实现「断点续传 + 自愈」。

---

## 3. 跨端架构：TaskHandler 实现主/从隔离区的状态同步

### 背景

Android 上为在后台/锁屏下继续更新通知栏倒计时，我们使用 `flutter_foreground_task`：**主 isolate** 负责 UI 与 IntervalEngine 的 tick，**后台 isolate** 负责前台通知的展示与更新。两者之间不能共享内存，需要显式「推送状态」。

### 同步方式：主推从显

- **主 isolate（Controller）**  
  - 在 200ms 的 tick 中，除更新 `state` 外，做**秒级节流**：当 `state.elapsed.inSeconds` 相对上次推送发生变化且状态为 running 时，调用 `TimerBackgroundService.updateNotification(title, body)`，其中 `body` 为当前剩余时间的 `formatMMSS(remainingSeconds)`。  
  - 实现类内部通过 `FlutterForegroundTask.sendDataToTask({'title': title, 'body': body})` 把**已格式化好的 MM:SS 字符串**发给后台 isolate。

- **后台 isolate（TaskHandler）**  
  - 插件在独立 isolate 中运行 `TimerForegroundTaskHandler`。  
  - `onReceiveData(Object data)` 在收到主 isolate 发来的 Map 时，取出 `title`、`body`，调用 `FlutterForegroundTask.updateService(notificationTitle: ..., notificationText: ...)` 更新系统通知栏。  
  - **不**在后台 isolate 内再次跑计时或解析剩余秒数；倒计时语义完全由主 isolate 的引擎计算，后台只负责「把主 isolate 算好的 MM:SS 显示出来」，因此主/从状态一致且无需在后台打开 Isar 或重复逻辑。

### 数据流小结

```
主 isolate: IntervalEngine.tick() → state.remaining
         → 秒级节流 → sendDataToTask({ title, body: MM:SS })
         → 后台 isolate: onReceiveData(data) → updateService(title, body)
         → 系统通知栏显示 MM:SS
```

这样，**主 isolate 是唯一真实源**，TaskHandler 仅作「状态展示通道」，实现跨隔离区的**单向、秒级节流**的状态同步，同时避免在后台做重计算或数据库访问。

---

## 4. 文档与扩展

- iOS 灵动岛 / Live Activity 的 SwiftUI 示例与接入说明见 `docs/ios_live_activity/`（含 `LiveActivitiesAppAttributes`、`TimerLiveActivity.swift` 与 README）。  
- 数据导出/导入、历史闭环、无障碍与电池引导等见项目 README 与 `docs/ARCHITECTURE_WHITEPAPER.md`（若存在）。

本架构使计时在**精度**（Stopwatch 单调时间）、**可恢复性**（TimerSnapshot + 墙钟校准）和**跨端一致性**（TaskHandler 主推从显）上达到生产级要求，适合作为商业健身计时产品的技术底座。
