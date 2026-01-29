// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWorkoutHistoryCollection on Isar {
  IsarCollection<WorkoutHistory> get workoutHistorys => this.collection();
}

const WorkoutHistorySchema = CollectionSchema(
  name: r'WorkoutHistory',
  id: 4471065416268783057,
  properties: {
    r'calories': PropertySchema(
      id: 0,
      name: r'calories',
      type: IsarType.long,
    ),
    r'completionRate': PropertySchema(
      id: 1,
      name: r'completionRate',
      type: IsarType.double,
    ),
    r'planId': PropertySchema(
      id: 2,
      name: r'planId',
      type: IsarType.string,
    ),
    r'planTitle': PropertySchema(
      id: 3,
      name: r'planTitle',
      type: IsarType.string,
    ),
    r'startTime': PropertySchema(
      id: 4,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'totalDurationSeconds': PropertySchema(
      id: 5,
      name: r'totalDurationSeconds',
      type: IsarType.long,
    )
  },
  estimateSize: _workoutHistoryEstimateSize,
  serialize: _workoutHistorySerialize,
  deserialize: _workoutHistoryDeserialize,
  deserializeProp: _workoutHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'startTime': IndexSchema(
      id: -3870335341264752872,
      name: r'startTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _workoutHistoryGetId,
  getLinks: _workoutHistoryGetLinks,
  attach: _workoutHistoryAttach,
  version: '3.1.0+1',
);

int _workoutHistoryEstimateSize(
  WorkoutHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.planId.length * 3;
  bytesCount += 3 + object.planTitle.length * 3;
  return bytesCount;
}

void _workoutHistorySerialize(
  WorkoutHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.calories);
  writer.writeDouble(offsets[1], object.completionRate);
  writer.writeString(offsets[2], object.planId);
  writer.writeString(offsets[3], object.planTitle);
  writer.writeDateTime(offsets[4], object.startTime);
  writer.writeLong(offsets[5], object.totalDurationSeconds);
}

WorkoutHistory _workoutHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WorkoutHistory();
  object.calories = reader.readLong(offsets[0]);
  object.completionRate = reader.readDouble(offsets[1]);
  object.id = id;
  object.planId = reader.readString(offsets[2]);
  object.planTitle = reader.readString(offsets[3]);
  object.startTime = reader.readDateTime(offsets[4]);
  object.totalDurationSeconds = reader.readLong(offsets[5]);
  return object;
}

P _workoutHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _workoutHistoryGetId(WorkoutHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _workoutHistoryGetLinks(WorkoutHistory object) {
  return [];
}

void _workoutHistoryAttach(
    IsarCollection<dynamic> col, Id id, WorkoutHistory object) {
  object.id = id;
}

extension WorkoutHistoryQueryWhereSort
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QWhere> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhere> anyStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startTime'),
      );
    });
  }
}

extension WorkoutHistoryQueryWhere
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QWhereClause> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause>
      startTimeEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startTime',
        value: [startTime],
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause>
      startTimeNotEqualTo(DateTime startTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [startTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startTime',
              lower: [],
              upper: [startTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause>
      startTimeGreaterThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [startTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause>
      startTimeLessThan(
    DateTime startTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [],
        upper: [startTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterWhereClause>
      startTimeBetween(
    DateTime lowerStartTime,
    DateTime upperStartTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startTime',
        lower: [lowerStartTime],
        includeLower: includeLower,
        upper: [upperStartTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutHistoryQueryFilter
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QFilterCondition> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      caloriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      caloriesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      caloriesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      caloriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      completionRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completionRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      completionRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completionRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      completionRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completionRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      completionRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completionRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
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

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planId',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'planTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'planTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'planTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'planTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      planTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'planTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      startTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      totalDurationSecondsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      totalDurationSecondsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      totalDurationSecondsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDurationSeconds',
        value: value,
      ));
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterFilterCondition>
      totalDurationSecondsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDurationSeconds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WorkoutHistoryQueryObject
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QFilterCondition> {}

extension WorkoutHistoryQueryLinks
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QFilterCondition> {}

extension WorkoutHistoryQuerySortBy
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QSortBy> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByCompletionRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionRate', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByCompletionRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionRate', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> sortByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> sortByPlanTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTitle', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByPlanTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTitle', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      sortByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }
}

extension WorkoutHistoryQuerySortThenBy
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QSortThenBy> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByCompletionRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionRate', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByCompletionRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completionRate', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenByPlanId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByPlanIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planId', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenByPlanTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTitle', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByPlanTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'planTitle', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.asc);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QAfterSortBy>
      thenByTotalDurationSecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDurationSeconds', Sort.desc);
    });
  }
}

extension WorkoutHistoryQueryWhereDistinct
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct> {
  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct>
      distinctByCompletionRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completionRate');
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct> distinctByPlanId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct> distinctByPlanTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'planTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct>
      distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<WorkoutHistory, WorkoutHistory, QDistinct>
      distinctByTotalDurationSeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDurationSeconds');
    });
  }
}

extension WorkoutHistoryQueryProperty
    on QueryBuilder<WorkoutHistory, WorkoutHistory, QQueryProperty> {
  QueryBuilder<WorkoutHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WorkoutHistory, int, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<WorkoutHistory, double, QQueryOperations>
      completionRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completionRate');
    });
  }

  QueryBuilder<WorkoutHistory, String, QQueryOperations> planIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planId');
    });
  }

  QueryBuilder<WorkoutHistory, String, QQueryOperations> planTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'planTitle');
    });
  }

  QueryBuilder<WorkoutHistory, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<WorkoutHistory, int, QQueryOperations>
      totalDurationSecondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDurationSeconds');
    });
  }
}
