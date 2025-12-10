import 'package:drift/drift.dart';
import 'trainers_table.dart';

class ClientsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  IntColumn get trainerId => integer().references(TrainersTable, #id)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
