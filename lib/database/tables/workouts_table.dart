import 'package:drift/drift.dart';
import 'trainers_table.dart';

class WorkoutsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get trainerId => integer().references(TrainersTable, #id)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
