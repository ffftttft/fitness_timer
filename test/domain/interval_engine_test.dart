import 'package:flutter_test/flutter_test.dart';

import 'package:fitness_timer_app/domain/timer/interval_engine.dart';

void main() {
  group('IntervalEngine - basic timing', () {
    test('start -> tick advances elapsed and remaining using monotonic clock', () {
      var now = Duration.zero;
      final engine = IntervalEngine(
        intervals: const [
          Interval(duration: Duration(seconds: 10), type: IntervalType.work),
        ],
        now: () => now,
      );

      // 初始为 ready
      expect(engine.state.status, TimerStatus.ready);
      expect(engine.state.elapsed, Duration.zero);
      expect(engine.state.remaining, const Duration(seconds: 10));

      engine.start();
      expect(engine.state.status, TimerStatus.running);

      // 推进 3 秒
      now += const Duration(seconds: 3);
      engine.tick();
      expect(engine.state.elapsed, const Duration(seconds: 3));
      expect(engine.state.remaining, const Duration(seconds: 7));
      expect(engine.state.status, TimerStatus.running);
    });

    test('pause / resume do not lose elapsed time', () {
      var now = Duration.zero;
      final engine = IntervalEngine(
        intervals: const [
          Interval(duration: Duration(seconds: 10), type: IntervalType.work),
        ],
        now: () => now,
      );

      engine.start();
      now += const Duration(seconds: 3);
      engine.tick();
      expect(engine.state.elapsed, const Duration(seconds: 3));

      // 暂停
      engine.pause();
      expect(engine.state.status, TimerStatus.paused);

      // 时间继续流逝，但在暂停期间不应累计
      now += const Duration(seconds: 5);
      engine.tick();
      expect(engine.state.elapsed, const Duration(seconds: 3));
      expect(engine.state.remaining, const Duration(seconds: 7));

      // 恢复
      engine.resume();
      expect(engine.state.status, TimerStatus.running);

      // 再过 2 秒
      now += const Duration(seconds: 2);
      engine.tick();
      expect(engine.state.elapsed, const Duration(seconds: 5));
      expect(engine.state.remaining, const Duration(seconds: 5));
    });
  });

  group('IntervalEngine - multi-interval timeline', () {
    test('elapsed time crosses intervals and finishes correctly', () {
      var now = Duration.zero;
      final engine = IntervalEngine(
        intervals: const [
          Interval(duration: Duration(seconds: 3), type: IntervalType.work),
          Interval(duration: Duration(seconds: 2), type: IntervalType.rest),
          Interval(duration: Duration(seconds: 5), type: IntervalType.work),
        ],
        now: () => now,
      );

      engine.start();

      // 1s -> 仍在第 0 段
      now += const Duration(seconds: 1);
      engine.tick();
      expect(engine.state.currentIntervalIndex, 0);

      // 3.1s -> 进入第 1 段
      now += const Duration(milliseconds: 2100);
      engine.tick();
      expect(engine.state.currentIntervalIndex, 1);

      // 5.1s -> 进入第 2 段
      now += const Duration(seconds: 2);
      engine.tick();
      expect(engine.state.currentIntervalIndex, 2);

      // 总时长 10s，走到末尾
      now += const Duration(seconds: 5);
      engine.tick();
      expect(engine.state.status, TimerStatus.finished);
      expect(engine.state.elapsed, const Duration(seconds: 10));
      expect(engine.state.remaining, Duration.zero);
      expect(engine.state.currentIntervalIndex, 2);
    });

    test('skipCurrentInterval jumps to next interval boundary', () {
      var now = Duration.zero;
      final engine = IntervalEngine(
        intervals: const [
          Interval(duration: Duration(seconds: 3), type: IntervalType.work),
          Interval(duration: Duration(seconds: 2), type: IntervalType.rest),
          Interval(duration: Duration(seconds: 5), type: IntervalType.work),
        ],
        now: () => now,
      );

      engine.start();

      // 跳过第 0 段，直接进入第 1 段起点
      engine.skipCurrentInterval();
      engine.tick();
      expect(engine.state.currentIntervalIndex, 1);
      expect(engine.state.elapsed, const Duration(seconds: 3));

      // 再跳过第 1 段，进入第 2 段起点
      engine.skipCurrentInterval();
      engine.tick();
      expect(engine.state.currentIntervalIndex, 2);
      expect(engine.state.elapsed, const Duration(seconds: 5));
    });
  });
}

