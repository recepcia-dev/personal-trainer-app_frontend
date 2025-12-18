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
import 'tables/workout_exercises_table.dart';
import 'tables/meal_plans_table.dart';
import 'tables/meals_table.dart';
import 'tables/meal_assignments_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  TrainersTable,
  ClientsTable,
  WorkoutsTable,
  WorkoutAssignmentsTable,
  ExercisesTable,
  ProgressLogsTable,
  WorkoutExercisesTable,
  MealPlansTable,
  MealsTable,
  MealAssignmentsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 5) {
        // Add new columns to clients_table
        await migrator.addColumn(clientsTable, clientsTable.weightKg);
        await migrator.addColumn(clientsTable, clientsTable.heightCm);
        await migrator.addColumn(clientsTable, clientsTable.dateOfBirth);
        await migrator.addColumn(clientsTable, clientsTable.gender);

        // Create new tables
        await migrator.createTable(workoutExercisesTable);
        await migrator.createTable(mealPlansTable);
        await migrator.createTable(mealsTable);
        await migrator.createTable(mealAssignmentsTable);
      }
    },
  );

  static LazyDatabase _openConnection() => LazyDatabase(
    () async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(path.join(dbFolder.path, 'app_database.sqlite'));
      return NativeDatabase(file);
    },
  );
}
