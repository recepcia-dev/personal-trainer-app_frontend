import 'package:drift/drift.dart';

class WorkoutExercisesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get workoutId => text()();
  TextColumn get exerciseId => text()();
  IntColumn get orderIndex => integer()();
  IntColumn get sets => integer()();
  IntColumn get reps => integer()();
  IntColumn get restSeconds => integer().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
