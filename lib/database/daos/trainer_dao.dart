import 'package:drift/drift.dart';

import '../app_database.dart';

part 'trainer_dao.g.dart';

@DriftAccessor()
class TrainerDao extends DatabaseAccessor<AppDatabase> {
  TrainerDao(super.db);

  /// Get a trainer by their ID
  Future<TrainersTableData?> getTrainerById(int id) =>
      (select(db.trainersTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Insert or update a trainer
  Future<int> upsertTrainer(TrainersTableCompanion trainer) =>
      into(db.trainersTable).insertOnConflictUpdate(trainer);

  /// Get all clients for a specific trainer
  Future<List<ClientsTableData>> getClientsForTrainer(String trainerId) =>
      (select(db.clientsTable)..where((c) => c.trainerId.equals(trainerId)))
          .get();
}
