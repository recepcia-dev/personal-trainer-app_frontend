import 'package:drift/drift.dart';

class MealsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get mealPlanId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get calories => integer().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatsG => real().nullable()();
  TextColumn get mealType => text()(); // breakfast, lunch, dinner, snack
  IntColumn get orderIndex => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
