// 可直接粘贴到 Xcode Widget Extension Target 中，与 LiveActivitiesAppAttributes 配套使用。
// 布局：Compact（左侧图标、右侧剩余时间）、Minimal（圆环进度）、Expanded（动作名、剩余时间、暂停/跳过按钮）。
// 倒计时统一使用 Text(timerInterval:...) 由系统驱动，秒级自动刷新且不额外耗电。

import ActivityKit
import SwiftUI
import WidgetKit

struct TimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
            ExpandedView(
                endTime: context.attributes.endTime,
                phaseLabel: context.state.phaseLabel,
                planTitle: context.state.planTitle
            )
        } compactLeading: { context in
            CompactLeadingView(endTime: context.attributes.endTime)
        } compactTrailing: { context in
            CompactTrailingView(endTime: context.attributes.endTime)
        } minimal: { context in
            MinimalView(endTime: context.attributes.endTime)
        }
    }
}

// MARK: - Expanded：当前动作名称、剩余时间、暂停/跳过按钮
private struct ExpandedView: View {
    let endTime: Date
    let phaseLabel: String
    let planTitle: String

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(planTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(phaseLabel)
                        .font(.headline)
                }
                Spacer()
                Text(timerInterval: Date.now...endTime, countsDown: true)
                    .font(.system(.title2, design: .monospaced))
                    .contentTransition(.numericText())
            }
            HStack(spacing: 12) {
                Link(destination: URL(string: "fitness-timer://pause")!) {
                    Label("Pause", systemImage: "pause.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                Link(destination: URL(string: "fitness-timer://skip")!) {
                    Label("Skip", systemImage: "forward.circle.fill")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
// 若需真正控制暂停/跳过，请在主 App Target 中实现 AppIntent 并在 Info.plist 注册 URL Scheme：fitness-timer

// MARK: - Compact Leading：左侧图标
private struct CompactLeadingView: View {
    let endTime: Date

    var body: some View {
        Image(systemName: "figure.run")
            .font(.title2)
            .foregroundStyle(.orange)
    }
}

// MARK: - Compact Trailing：右侧剩余时间（系统驱动）
private struct CompactTrailingView: View {
    let endTime: Date

    var body: some View {
        Text(timerInterval: Date.now...endTime, countsDown: true)
            .font(.system(.body, design: .monospaced))
            .contentTransition(.numericText())
    }
}

// MARK: - Minimal：圆环进度
private struct MinimalView: View {
    let endTime: Date

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(Color.orange.opacity(0.3), lineWidth: 3)
                .rotationEffect(.degrees(-90))
            Text(timerInterval: Date.now...endTime, countsDown: true)
                .font(.system(.caption2, design: .monospaced))
                .contentTransition(.numericText())
        }
        .frame(width: 36, height: 36)
    }
}
