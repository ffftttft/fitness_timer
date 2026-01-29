import 'package:flutter/foundation.dart';

/// Health center sync status and authorization (decoupled from [HealthSyncService] for stub when health plugin is disabled).
abstract class HealthSyncStatus {
  /// Whether write access to health data (Health Connect / HealthKit) is authorized.
  Future<bool> isAuthorized();

  /// Request authorization; returns true if granted, false if denied or unavailable.
  Future<bool> requestAuthorization();
}

/// Stub implementation when health plugin is disabled; always returns not connected, request is no-op.
class HealthSyncStatusStub implements HealthSyncStatus {
  HealthSyncStatusStub._();
  static final HealthSyncStatusStub _instance = HealthSyncStatusStub._();
  factory HealthSyncStatusStub() => _instance;

  @override
  Future<bool> isAuthorized() async => false;

  @override
  Future<bool> requestAuthorization() async {
    debugPrint('HealthSyncStatusStub: health plugin disabled');
    return false;
  }
}
