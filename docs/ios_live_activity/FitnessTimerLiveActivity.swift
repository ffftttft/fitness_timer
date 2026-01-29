// 放入 Widget Extension Target。依赖 LiveActivitiesAppAttributes。
// 支持灵动岛：紧凑（左右）、极简、扩展；倒计时使用系统 Text(timerInterval:...) 渲染。

import ActivityKit
import SwiftUI
import WidgetKit

struct FitnessTimerLiveActivity: Widget {
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
            CompactTrailingView(phaseLabel: context.state.phaseLabel)
        } minimal: { context in
            MinimalView(endTime: context.attributes.endTime)
        }
    }
}

// MARK: - Expanded
private struct ExpandedView: View {
    let endTime: Date
    let phaseLabel: String
    let planTitle: String

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(planTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(phaseLabel)
                    .font(.headline)
            }
            Spacer()
            Text(timerInterval: Date.now...endTime, countsDown: true)
                .font(.system(.title2, design: .monospaced))
                .multilineTextAlignment(.trailing)
        }
        .padding()
    }
}

// MARK: - Compact Leading
private struct CompactLeadingView: View {
    let endTime: Date

    var body: some View {
        Text(timerInterval: Date.now...endTime, countsDown: true)
            .font(.system(.body, design: .monospaced))
    }
}

// MARK: - Compact Trailing
private struct CompactTrailingView: View {
    let phaseLabel: String

    var body: some View {
        Text(phaseLabel)
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Minimal
private struct MinimalView: View {
    let endTime: Date

    var body: some View {
        Text(timerInterval: Date.now...endTime, countsDown: true)
            .font(.system(.caption, design: .monospaced))
    }
}
