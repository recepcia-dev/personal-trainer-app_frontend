import 'package:drift/drift.dart';
import 'trainers_table.dart';

class ClientsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().unique()();
  TextColumn get trainerId => text()(); // trainer user ID
  TextColumn get userId => text().unique()(); // client user ID
  TextColumn get email => text()();
  TextColumn get firstName => text().nullable()();
  TextColumn get lastName => text().nullable()();
  TextColumn get phone => text().nullable()();
  IntColumn get age => integer().nullable()();
  TextColumn get fitnessLevel => text().nullable()();
  TextColumn get goals => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  // Extended profile fields (added in schema version 5)
  RealColumn get weightKg => real().nullable()();
  RealColumn get heightCm => real().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get gender => text().nullable()();
}
