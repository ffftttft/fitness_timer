# Fitness Timer

Fitness Timer is a professional-grade interval training timer built with Flutter.
It supports custom workout plans with multiple steps, voice announcements, real-time calorie tracking, and health ecosystem integration.

## Features

### Core Training Features

- **Custom Workout Plans**: Create, edit, delete, and reorder multiple workout plans
- **Multi-step Workouts**: Each plan can have multiple steps with:
  - Custom step name
  - Number of sets (1-20)
  - Work duration per set
  - Intra-rest (rest between sets within the same step)
  - Inter-rest (rest between different steps)
- **Warm-up Time**: Optional preparation time before the first step
- **Full Training Flow**: Warm-up → Step 1 (Set 1 → Intra-rest → Set 2...) → Inter-rest → Step 2... → Done

### Voice Announcements (TTS)

- **"Get ready to start"** at workout begin
- **"Start [Step Name]"** when a new step begins
- **"Take a rest"** during rest periods
- **"Rest is over, continue [Step Name]"** when resuming within the same step
- **"[Step Name] finished, take a rest"** when transitioning between steps
- **"Workout finished, results saved, keep it up"** at completion
- **Countdown (3, 2, 1)** in the last 3 seconds of each phase

### Real-time Display

- **Flip Clock Calorie Counter**: Animated calorie display above the countdown timer, updates every second (formula: seconds × 7.5 / 60)
- **Progress Indicator**: Shows current set progress, e.g., "Step 1: 2/3"
- **Phase Colors**: Different colors for warm-up (yellow), work (orange), and rest (blue)
- **Circular Progress Ring**: Visual progress within current phase

### Workout History

- **Auto-save**: Completed workouts are automatically saved
- **Manual End with Choice**: End workout early and choose whether to save
- **Export/Import**: Export history to CSV, import from backup files
- **Batch Operations**: Select multiple records to export or delete

### Safety & UX

- **Unsaved Changes Protection**: Prompts when leaving plan or step editor without saving
- **Exit Confirmation**: Confirms before exiting an active workout
- **Auto-pause on End Dialog**: Timer pauses automatically when the "End workout" dialog appears
- **Screen Wake Lock**: Screen stays on during active workouts
- **Background Notifications**: Phase-end notifications even when app is in background

### Health Integration

- **Android**: Syncs to Health Connect (workout duration + calories)
- **iOS**: Syncs to HealthKit (workout + active energy burned)

### Localization

- **English & Chinese**: Full bilingual support
- **Strict Separation**: No language mixing (except user-entered step names)

## How to Use

### Creating a Workout Plan

1. Open the app → tap **"New plan"** button
2. Enter a **title** and optional **description**
3. Set **warm-up time** (default: 30 seconds)
4. Tap **"Add step"** to add workout steps:
   - Enter step name (e.g., "Push-ups")
   - Set number of sets
   - Set work duration per set
   - Set rest between sets (only if sets > 1)
   - Set rest after this step
5. Reorder steps by dragging the handle on the right
6. Tap **Save** icon to save the plan

### Starting a Workout

1. On the home screen, find your plan and tap the **play button**
2. The timer screen shows:
   - Current step name with set progress (e.g., "Push-ups: 2/3")
   - Real-time calorie counter (flip animation)
   - Large countdown timer
   - Circular progress ring
   - Next step preview

### Controlling the Workout

- **Double-tap** anywhere: Start/Pause
- **Long-press** anywhere: Reset
- **Start/Pause button**: Toggle timer
- **Reset button**: Restart from beginning
- **Skip button**: Jump to next phase
- **End workout button** (visible when running): End early with save option

### Viewing History

1. Tap the **history icon** in the top bar
2. View all past workouts with:
   - Workout ID (6-digit format)
   - Plan name
   - Date and time
   - Duration, calories, completion rate
3. Long-press to enter selection mode for batch export/delete

### Settings

- **Language**: Switch between English and Chinese via the language icon
- **Import**: Restore workout history from CSV backup

## Project Structure

```
lib/
├── core/           # Theme, colors, localization, services
├── data/           # Repositories, models (Isar database)
├── domain/         # Interval engine, builders
├── models/         # Workout config, plan models
├── presentation/   # Controllers (Riverpod)
├── providers/      # State management
├── views/          # Screens (Home, Editor, Workout, History)
└── widgets/        # Reusable UI components
```

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Or use the provided script (Windows)
.\run_app.ps1
```

## Build Notes

If you see Kotlin compilation warnings about "different roots", this is normal when Flutter packages are on different drives. The app will still build and run successfully.

## Technical Highlights

- **High-precision Timing**: Stopwatch-based monotonic clock prevents drift
- **Crash Recovery**: Timer state persisted every second, recoverable within 5 minutes
- **iOS Live Activity**: SwiftUI layouts provided in `docs/ios_live_activity/`
- **Error Monitoring**: Sentry integration ready
- **Accessibility**: Semantic labels and live regions for screen readers
