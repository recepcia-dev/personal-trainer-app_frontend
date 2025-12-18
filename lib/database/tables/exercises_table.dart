import 'package:drift/drift.dart';

class ExercisesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // strength, cardio, flexibility, plyometrics, etc.
  TextColumn get description => text().nullable()();
  TextColumn get muscleGroup => text().nullable()(); // chest, back, legs, arms, core, full_body, etc.
  TextColumn get equipment => text().nullable()(); // barbell, dumbbells, kettlebell, machine, etc.
  TextColumn get videoUrl => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
