import 'package:drift/drift.dart';

class TrainersTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}
