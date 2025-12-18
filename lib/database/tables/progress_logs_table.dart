import 'package:drift/drift.dart';

class ProgressLogsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique().nullable()(); // null until synced with backend
  TextColumn get clientId => text()(); // User ID from auth
  TextColumn get exerciseId => text()(); // Remote exercise ID (string from backend)
  IntColumn get setsCompleted => integer()();
  IntColumn get repsPerSet => integer()();
  RealColumn get weightKg => real().nullable()(); // for strength exercises
  IntColumn get durationSeconds => integer().nullable()(); // for cardio exercises
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
