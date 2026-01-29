# Fitness Timer

Fitness Timer is a focused, commercial‑grade interval training timer built with Flutter.
It is designed for HIIT / EMOM / tabata‑style workouts with a simple but professional dark UI.

## 功能亮点 (Highlights)

- **高精度计时**：基于 Stopwatch 的物理级时间校准，避免 Dart `Timer` 累积漂移，保证长时间训练不跑偏。
- **后台保活**：跨隔离区前台服务（Foreground Service）保活，状态通过 TimerSnapshot 秒级持久化，5 分钟内可墙钟恢复，异常中断后 UI 提示「已恢复进度」。
- **健康生态**：训练结束时自动将运动时长与卡路里（公式：minutes × 7.5）同步至 **Health Connect**（Android）与 **HealthKit**（iOS），需用户授权。
- **iOS 灵动岛**：提供 SwiftUI 版 Live Activity 布局（Compact / Minimal / Expanded），可集成 Widget Extension 在 Dynamic Island 与锁屏展示倒计时。

## Features

- **Full training flow**: Warm‑up → Work → Rest → Repeat rounds → Done.
- **Persistent configuration**: Last used parameters are saved automatically and restored on launch.
- **Professional dark mode**: Large monospaced digits, colored phase highlight, circular progress ring.
- **Stability**:
  - Screen stays awake during an active session.
  - Local notifications for phase end, even when the app is in the background.
- **Feedback**:
  - Short beeps in the last 3 seconds of each active phase.
  - Distinct sounds and haptic feedback on phase changes and workout completion.
- **iOS Live Activity (灵动岛)**:
  - SwiftUI-based Live Activity layouts (Compact, Minimal, Expanded) are provided in `docs/ios_live_activity/`. Integrate the Widget Extension in Xcode to show the countdown on the Dynamic Island and Lock Screen.
- **Health ecosystem integration**:
  - **Android**: Workout duration and estimated calories are synced to **Health Connect** when a session finishes (Google’s recommended health platform; migration from Google Fit SDK by 2026).
  - **iOS**: Same data is written to **HealthKit** (workout + active energy). Add the Health capability and the provided Info.plist usage descriptions.

## Configuration Model

The workout is configured via four core parameters:

- **Warm‑up (seconds)**: Time before the first work phase starts (can be 0).
- **Work (seconds)**: Duration of each work phase.
- **Rest (seconds)**: Duration of rest between work phases/rounds (can be 0).
- **Rounds**: How many times the pair Work → Rest will repeat after the warm‑up.

These values are stored in `WorkoutConfig` and persisted with `shared_preferences`.

## How to Use the App

1. **Open the app**
   - You will land on the **Home** screen, which shows the last used configuration (warm‑up, work, rest, rounds).

2. **Adjust workout parameters (Settings)**
   - Tap **“Adjust parameters”** on the home screen (or the **settings icon** in the app bar).
   - On the **Settings** page:
     - Use the sliders to set **Warm‑up**, **Work**, and **Rest** seconds.
     - Use the stepper controls to set **Number of rounds**.
     - Tap **“Save”** in the app bar to persist the configuration and go back.

3. **Start a workout**
   - On the **Home** screen, tap **“Start workout”**.
   - You will see the **Timer** screen:
     - A colored pill showing the current phase (`Warm-up`, `Work`, `Rest`, or `Done`).
     - A large circular ring showing progress in the current phase.
     - A giant MM:SS timer in the center.
     - A text indicator showing the current round (e.g. `Round 2 / 8`).

4. **Control the timer**
   - **Start / Pause**: Tap the main button to start or pause the current phase.
   - **Reset**: Resets the session back to the beginning of the flow.
   - **Skip**: Immediately advance to the next logical phase (e.g. from Work to Rest, or to the next round).

5. **Background behavior**
   - While the timer is running:
     - The screen will stay on (no auto‑lock) as long as the Timer screen is visible.
     - A local notification is scheduled for the **end of the current phase**. If you leave the app or lock the device, you will still receive an alert when the phase finishes.

6. **End of workout**
   - When all rounds are completed, the phase becomes **Done**, a completion sound is played, haptic feedback is triggered, and a Lottie “success” animation is shown. The session is saved to local history and, if permission was granted, synced to the system health app (Health Connect on Android, HealthKit on iOS).

## Project Structure (High Level)

- `core/`: Theme, colors, notifications, persistence, and utilities.
- `models/`: Data models, including `WorkoutConfig`.
- `providers/`: State management (`WorkoutConfigProvider`, `TimerProvider`).
- `views/`: Screens (`HomePage`, `SettingsPage`, `TimerPage`).
- `widgets/`: Reusable UI components (big timer text, circular progress ring, controls, dialogs).

## Running the App

1. Ensure you have Flutter installed (matching the SDK constraint in `pubspec.yaml`).
2. Get dependencies:

```bash
flutter pub get
```

3. Run on your desired platform (example for mobile):

```bash
flutter run
```

### 关于构建时的错误信息

**重要提示**：如果在运行 `flutter run` 时看到红色的 Kotlin 编译错误信息（例如 "Daemon compilation failed" 或 "this and base files have different roots"），**这是正常的，不会影响应用运行**。

这些错误是由于：
- Flutter 依赖包可能位于不同的驱动器（如 D: 和 C:）
- Kotlin 增量编译在处理跨驱动器路径时的问题

**解决方案**：
- 应用最终会成功构建并运行（看到 "Built build\app\outputs\flutter-apk\app-debug.apk" 表示成功）
- 如果错误信息太多，可以运行 `flutter clean` 清理缓存后重新构建
- 或者使用提供的 `run_app.ps1` 脚本自动清理并运行

**快速启动脚本**（Windows PowerShell）：
```powershell
.\run_app.ps1
```

This repository is intended as a production‑ready baseline for a focused fitness timer app, with health sync, error monitoring (Sentry), and accessibility (Semantics, live regions) built in.
