import 'package:drift/drift.dart';

class MealAssignmentsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get mealPlanId => text()();
  TextColumn get clientId => text()();
  TextColumn get assignedBy => text()(); // trainer_id
  DateTimeColumn get assignedAt => dateTime().nullable()();
  DateTimeColumn get startsAt => dateTime().nullable()();
  DateTimeColumn get endsAt => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
