// 在 Xcode 中新建 Widget Extension 后，将此文件加入该 Target。
// 需在 App 与 Extension 的 Signing & Capabilities 中启用 Live Activities。

import ActivityKit
import Foundation

/// 与 Flutter 端 TimerBackgroundService 推送的「剩余秒数」对应；
/// Live Activity 使用 endTime 配合 Text(timerInterval:...) 由系统驱动倒计时，省电。
public struct LiveActivitiesAppAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// 当前阶段名称（如 Warm-up / Work / Rest）
        var phaseLabel: String
        /// 计划标题（简单计时可为 "Fitness Timer"）
        var planTitle: String
    }

    /// 活动结束时间（当前 interval 或整次训练的结束时刻），用于 Text(timerInterval:endTime)
    var endTime: Date
    /// 计划标题
    var planTitle: String
    /// 阶段标签
    var phaseLabel: String
}
