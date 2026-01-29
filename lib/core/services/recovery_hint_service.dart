import 'package:flutter/foundation.dart';

/// Notifies the UI when timer state is recovered from a TimerSnapshot (e.g. "Recovered interrupted session").
///
/// Controller calls [notifyRecovered] after [TimerSnapshotRepository] recovery; UI listens to [recoveredNotifier],
/// shows a SnackBar, then calls [consumeRecovered].
abstract class RecoveryHintService {
  ValueListenable<bool> get recoveredNotifier;

  void notifyRecovered();

  void consumeRecovered();
}

class RecoveryHintServiceImpl implements RecoveryHintService {
  RecoveryHintServiceImpl._();
  static final RecoveryHintServiceImpl _instance = RecoveryHintServiceImpl._();
  factory RecoveryHintServiceImpl() => _instance;

  final ValueNotifier<bool> _recovered = ValueNotifier<bool>(false);

  @override
  ValueListenable<bool> get recoveredNotifier => _recovered;

  @override
  void notifyRecovered() {
    _recovered.value = true;
  }

  @override
  void consumeRecovered() {
    _recovered.value = false;
  }
}
