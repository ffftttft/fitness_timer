# iOS 灵动岛 / Live Activity 集成说明

## 1. 在 Xcode 中新建 Widget Extension

1. 打开 `ios/Runner.xcworkspace`。
2. File → New → Target → **Widget Extension**。
3. 命名如 `FitnessTimerLiveActivity`，勾选 **Include Live Activity**。
4. 在 App 与 Extension 的 **Signing & Capabilities** 中为 App 添加 **Live Activities** 能力。

## 2. 替换 / 添加代码

- 将本目录下 `LiveActivitiesAppAttributes.swift` 加入 **主 App (Runner)** 与 **Widget Extension** 两个 Target（或仅在 Extension 中，若主 App 用 Flutter 仅通过 Method Channel 传参）。
- 将 `FitnessTimerLiveActivity.swift` 加入 **Widget Extension** Target，并在 Extension 的 `Bundle` 入口中注册该 Widget（通常 Xcode 会生成 `@main struct FitnessTimerLiveActivityWidget: WidgetBundle`，把 `FitnessTimerLiveActivity()` 加入其中）。

## 3. Flutter 端与 Live Activity 的联动

- 在 iOS 端实现 `TimerBackgroundService` 时，在 `startService` / `updateNotification` 中除通知外，可调用 ActivityKit 的 `Activity.request(attributes:contentState:...)` 启动/更新 Live Activity。
- `LiveActivitiesAppAttributes` 的 `endTime` 建议设为「当前剩余时间对应的结束时间」：`Date().addingTimeInterval(TimeInterval(remainingSeconds))`，这样 `Text(timerInterval: Date.now...endTime, countsDown: true)` 会由系统自动倒计时，无需频繁 push 更新，省电。

## 4. 布局说明

- **Expanded**：锁屏或展开灵动岛时显示计划名、阶段名与系统倒计时。
- **Compact Leading/Trailing**：灵动岛紧凑条左右两侧，左侧倒计时、右侧阶段名。
- **Minimal**：极简小圆点，仅显示倒计时。
