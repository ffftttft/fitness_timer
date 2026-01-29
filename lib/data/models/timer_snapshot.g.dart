// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTimerSnapshotCollection on Isar {
  IsarCollection<TimerSnapshot> get timerSnapshots => this.collection();
}

const TimerSnapshotSchema = CollectionSchema(
  name: r'TimerSnapshot',
  id: 6555948069519662285,
  properties: {
    r'currentIntervalIndex': PropertySchema(
      id: 0,
      name: r'currentIntervalIndex',
      type: IsarType.long,
    ),
    r'elapsedAtLastUpdateMicros': PropertySchema(
      id: 1,
      name: r'elapsedAtLastUpdateMicros',
      type: IsarType.long,
    ),
    r'kind': PropertySchema(
      id: 2,
      name: r'kind',
      type: IsarType.string,
    ),
    r'lastUpdatedAtWall': PropertySchema(
      id: 3,
      name: r'lastUpdatedAtWall',
      type: IsarType.dateTime,
    ),
    r'pausedAccumulatedMicros': PropertySchema(
      id: 4,
      name: r'pausedAccumulatedMicros',
      type: IsarType.long,
    ),
    r'sourceId': PropertySchema(
      id: 5,
      name: r'sourceId',
      type: IsarType.string,
    ),
    r'startedAtWall': PropertySchema(
      id: 6,
      name: r'startedAtWall',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 7,
      name: r'status',
      type: IsarType.long,
    )
  },
  estimateSize: _timerSnapshotEstimateSize,
  serialize: _timerSnapshotSerialize,
  deserialize: _timerSnapshotDeserialize,
  deserializeProp: _timerSnapshotDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _timerSnapshotGetId,
  getLinks: _timerSnapshotGetLinks,
  attach: _timerSnapshotAttach,
  version: '3.1.0+1',
);

int _timerSnapshotEstimateSize(
  TimerSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.kind.length * 3;
  bytesCount += 3 + object.sourceId.length * 3;
  return bytesCount;
}

void _timerSnapshotSerialize(
  TimerSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentIntervalIndex);
  writer.writeLong(offsets[1], object.elapsedAtLastUpdateMicros);
  writer.writeString(offsets[2], object.kind);
  writer.writeDateTime(offsets[3], object.lastUpdatedAtWall);
  writer.writeLong(offsets[4], object.pausedAccumulatedMicros);
  writer.writeString(offsets[5], object.sourceId);
  writer.writeDateTime(offsets[6], object.startedAtWall);
  writer.writeLong(offsets[7], object.status);
}

TimerSnapshot _timerSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TimerSnapshot();
  object.currentIntervalIndex = reader.readLong(offsets[0]);
  object.elapsedAtLastUpdateMicros = reader.readLong(offsets[1]);
  object.id = id;
  object.kind = reader.readString(offsets[2]);
  object.lastUpdatedAtWall = reader.readDateTime(offsets[3]);
  object.pausedAccumulatedMicros = reader.readLong(offsets[4]);
  object.sourceId = reader.readString(offsets[5]);
  object.startedAtWall = reader.readDateTime(offsets[6]);
  object.status = reader.readLong(offsets[7]);
  return object;
}

P _timerSnapshotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _timerSnapshotGetId(TimerSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _timerSnapshotGetLinks(TimerSnapshot object) {
  return [];
}

void _timerSnapshotAttach(
    IsarCollection<dynamic> col, Id id, TimerSnapshot object) {
  object.id = id;
}

extension TimerSnapshotQueryWhereSort
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QWhere> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TimerSnapshotQueryWhere
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QWhereClause> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimerSnapshotQueryFilter
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QFilterCondition> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      currentIntervalIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentIntervalIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      currentIntervalIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentIntervalIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      currentIntervalIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentIntervalIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      currentIntervalIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentIntervalIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      elapsedAtLastUpdateMicrosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elapsedAtLastUpdateMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      elapsedAtLastUpdateMicrosGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elapsedAtLastUpdateMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      elapsedAtLastUpdateMicrosLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elapsedAtLastUpdateMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      elapsedAtLastUpdateMicrosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elapsedAtLastUpdateMicros',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> kindEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> kindBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'kind',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'kind',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition> kindMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'kind',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      kindIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'kind',
        value: '',
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      lastUpdatedAtWallEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdatedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      lastUpdatedAtWallGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdatedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      lastUpdatedAtWallLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdatedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      lastUpdatedAtWallBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdatedAtWall',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      pausedAccumulatedMicrosEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pausedAccumulatedMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      pausedAccumulatedMicrosGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pausedAccumulatedMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      pausedAccumulatedMicrosLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pausedAccumulatedMicros',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      pausedAccumulatedMicrosBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pausedAccumulatedMicros',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      sourceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceId',
        value: '',
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      startedAtWallEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      startedAtWallGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      startedAtWallLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedAtWall',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      startedAtWallBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedAtWall',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      statusEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      statusGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      statusLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
      ));
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterFilterCondition>
      statusBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TimerSnapshotQueryObject
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QFilterCondition> {}

extension TimerSnapshotQueryLinks
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QFilterCondition> {}

extension TimerSnapshotQuerySortBy
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QSortBy> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByCurrentIntervalIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIntervalIndex', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByCurrentIntervalIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIntervalIndex', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByElapsedAtLastUpdateMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedAtLastUpdateMicros', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByElapsedAtLastUpdateMicrosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedAtLastUpdateMicros', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> sortByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> sortByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByLastUpdatedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAtWall', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByLastUpdatedAtWallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAtWall', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByPausedAccumulatedMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAccumulatedMicros', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByPausedAccumulatedMicrosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAccumulatedMicros', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByStartedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAtWall', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      sortByStartedAtWallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAtWall', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension TimerSnapshotQuerySortThenBy
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QSortThenBy> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByCurrentIntervalIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIntervalIndex', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByCurrentIntervalIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentIntervalIndex', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByElapsedAtLastUpdateMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedAtLastUpdateMicros', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByElapsedAtLastUpdateMicrosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elapsedAtLastUpdateMicros', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenByKind() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenByKindDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'kind', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByLastUpdatedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAtWall', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByLastUpdatedAtWallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdatedAtWall', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByPausedAccumulatedMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAccumulatedMicros', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByPausedAccumulatedMicrosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pausedAccumulatedMicros', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByStartedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAtWall', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy>
      thenByStartedAtWallDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedAtWall', Sort.desc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension TimerSnapshotQueryWhereDistinct
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct> {
  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct>
      distinctByCurrentIntervalIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentIntervalIndex');
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct>
      distinctByElapsedAtLastUpdateMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elapsedAtLastUpdateMicros');
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct> distinctByKind(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'kind', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct>
      distinctByLastUpdatedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdatedAtWall');
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct>
      distinctByPausedAccumulatedMicros() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pausedAccumulatedMicros');
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct> distinctBySourceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct>
      distinctByStartedAtWall() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedAtWall');
    });
  }

  QueryBuilder<TimerSnapshot, TimerSnapshot, QDistinct> distinctByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status');
    });
  }
}

extension TimerSnapshotQueryProperty
    on QueryBuilder<TimerSnapshot, TimerSnapshot, QQueryProperty> {
  QueryBuilder<TimerSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TimerSnapshot, int, QQueryOperations>
      currentIntervalIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentIntervalIndex');
    });
  }

  QueryBuilder<TimerSnapshot, int, QQueryOperations>
      elapsedAtLastUpdateMicrosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elapsedAtLastUpdateMicros');
    });
  }

  QueryBuilder<TimerSnapshot, String, QQueryOperations> kindProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'kind');
    });
  }

  QueryBuilder<TimerSnapshot, DateTime, QQueryOperations>
      lastUpdatedAtWallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdatedAtWall');
    });
  }

  QueryBuilder<TimerSnapshot, int, QQueryOperations>
      pausedAccumulatedMicrosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pausedAccumulatedMicros');
    });
  }

  QueryBuilder<TimerSnapshot, String, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<TimerSnapshot, DateTime, QQueryOperations>
      startedAtWallProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedAtWall');
    });
  }

  QueryBuilder<TimerSnapshot, int, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
