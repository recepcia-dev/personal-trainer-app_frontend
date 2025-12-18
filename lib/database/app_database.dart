import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'tables/clients_table.dart';
import 'tables/trainers_table.dart';
import 'tables/workouts_table.dart';
import 'tables/workout_assignments_table.dart';
import 'tables/exercises_table.dart';
import 'tables/progress_logs_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TrainersTable,
  ClientsTable,
  WorkoutsTable,
  WorkoutAssignmentsTable,
  ExercisesTable,
  ProgressLogsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  static LazyDatabase _openConnection() => LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase(file);
    },
  );
}
