// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interval_engine.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TimerState {
  TimerStatus get status => throw _privateConstructorUsedError;
  Duration get total => throw _privateConstructorUsedError;
  Duration get elapsed => throw _privateConstructorUsedError;
  Duration get remaining => throw _privateConstructorUsedError;
  int get currentIntervalIndex => throw _privateConstructorUsedError;
  List<Interval> get intervals => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TimerStateCopyWith<TimerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimerStateCopyWith<$Res> {
  factory $TimerStateCopyWith(
          TimerState value, $Res Function(TimerState) then) =
      _$TimerStateCopyWithImpl<$Res, TimerState>;
  @useResult
  $Res call(
      {TimerStatus status,
      Duration total,
      Duration elapsed,
      Duration remaining,
      int currentIntervalIndex,
      List<Interval> intervals});
}

/// @nodoc
class _$TimerStateCopyWithImpl<$Res, $Val extends TimerState>
    implements $TimerStateCopyWith<$Res> {
  _$TimerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? total = null,
    Object? elapsed = null,
    Object? remaining = null,
    Object? currentIntervalIndex = null,
    Object? intervals = null,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as Duration,
      elapsed: null == elapsed
          ? _value.elapsed
          : elapsed // ignore: cast_nullable_to_non_nullable
              as Duration,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      currentIntervalIndex: null == currentIntervalIndex
          ? _value.currentIntervalIndex
          : currentIntervalIndex // ignore: cast_nullable_to_non_nullable
              as int,
      intervals: null == intervals
          ? _value.intervals
          : intervals // ignore: cast_nullable_to_non_nullable
              as List<Interval>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimerStateImplCopyWith<$Res>
    implements $TimerStateCopyWith<$Res> {
  factory _$$TimerStateImplCopyWith(
          _$TimerStateImpl value, $Res Function(_$TimerStateImpl) then) =
      __$$TimerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TimerStatus status,
      Duration total,
      Duration elapsed,
      Duration remaining,
      int currentIntervalIndex,
      List<Interval> intervals});
}

/// @nodoc
class __$$TimerStateImplCopyWithImpl<$Res>
    extends _$TimerStateCopyWithImpl<$Res, _$TimerStateImpl>
    implements _$$TimerStateImplCopyWith<$Res> {
  __$$TimerStateImplCopyWithImpl(
      _$TimerStateImpl _value, $Res Function(_$TimerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? total = null,
    Object? elapsed = null,
    Object? remaining = null,
    Object? currentIntervalIndex = null,
    Object? intervals = null,
  }) {
    return _then(_$TimerStateImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TimerStatus,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as Duration,
      elapsed: null == elapsed
          ? _value.elapsed
          : elapsed // ignore: cast_nullable_to_non_nullable
              as Duration,
      remaining: null == remaining
          ? _value.remaining
          : remaining // ignore: cast_nullable_to_non_nullable
              as Duration,
      currentIntervalIndex: null == currentIntervalIndex
          ? _value.currentIntervalIndex
          : currentIntervalIndex // ignore: cast_nullable_to_non_nullable
              as int,
      intervals: null == intervals
          ? _value._intervals
          : intervals // ignore: cast_nullable_to_non_nullable
              as List<Interval>,
    ));
  }
}

/// @nodoc

class _$TimerStateImpl extends _TimerState {
  const _$TimerStateImpl(
      {required this.status,
      required this.total,
      required this.elapsed,
      required this.remaining,
      required this.currentIntervalIndex,
      required final List<Interval> intervals})
      : _intervals = intervals,
        super._();

  @override
  final TimerStatus status;
  @override
  final Duration total;
  @override
  final Duration elapsed;
  @override
  final Duration remaining;
  @override
  final int currentIntervalIndex;
  final List<Interval> _intervals;
  @override
  List<Interval> get intervals {
    if (_intervals is EqualUnmodifiableListView) return _intervals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_intervals);
  }

  @override
  String toString() {
    return 'TimerState(status: $status, total: $total, elapsed: $elapsed, remaining: $remaining, currentIntervalIndex: $currentIntervalIndex, intervals: $intervals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimerStateImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.elapsed, elapsed) || other.elapsed == elapsed) &&
            (identical(other.remaining, remaining) ||
                other.remaining == remaining) &&
            (identical(other.currentIntervalIndex, currentIntervalIndex) ||
                other.currentIntervalIndex == currentIntervalIndex) &&
            const DeepCollectionEquality()
                .equals(other._intervals, _intervals));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      total,
      elapsed,
      remaining,
      currentIntervalIndex,
      const DeepCollectionEquality().hash(_intervals));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      __$$TimerStateImplCopyWithImpl<_$TimerStateImpl>(this, _$identity);
}

abstract class _TimerState extends TimerState {
  const factory _TimerState(
      {required final TimerStatus status,
      required final Duration total,
      required final Duration elapsed,
      required final Duration remaining,
      required final int currentIntervalIndex,
      required final List<Interval> intervals}) = _$TimerStateImpl;
  const _TimerState._() : super._();

  @override
  TimerStatus get status;
  @override
  Duration get total;
  @override
  Duration get elapsed;
  @override
  Duration get remaining;
  @override
  int get currentIntervalIndex;
  @override
  List<Interval> get intervals;
  @override
  @JsonKey(ignore: true)
  _$$TimerStateImplCopyWith<_$TimerStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
