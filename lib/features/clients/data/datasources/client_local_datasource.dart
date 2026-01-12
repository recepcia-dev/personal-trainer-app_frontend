import 'package:drift/drift.dart' as drift;

import '../../../../database/app_database.dart';
import '../models/client_model.dart';

/// Local data source for client data - handles Drift database operations
abstract class ClientLocalDataSource {
  /// Get all clients from local database, filtered by trainer
  Future<List<ClientModel>> getClients({
    required String trainerId,
    int skip,
    int limit,
  });

  /// Get single client by ID
  Future<ClientModel?> getClientById(String id);

  /// Cache clients to local database
  Future<void> cacheClients(List<ClientModel> clients);

  /// Save single client locally
  Future<void> saveClient(ClientModel client);

  /// Update client locally
  Future<void> updateClient(ClientModel client);

  /// Clear all clients from cache
  Future<void> clearClients();

  /// Clear clients for a specific trainer
  Future<void> clearClientsByTrainer(String trainerId);

  /// Check if clients exist in cache
  Future<bool> hasClients();
}

class ClientLocalDataSourceImpl implements ClientLocalDataSource {
  final AppDatabase database;

  ClientLocalDataSourceImpl({required this.database});

  @override
  Future<List<ClientModel>> getClients({
    required String trainerId,
    int skip = 0,
    int limit = 50,
  }) async {
    // Filter by trainer_id to prevent cross-trainer data leakage
    final results = await (database.select(database.clientsTable)
          ..where((c) => c.trainerId.equals(trainerId))
          ..limit(limit, offset: skip))
        .get();

    return results
        .map(_mapToModel)
        .toList();
  }

  @override
  Future<ClientModel?> getClientById(String id) async {
    final result = await (database.select(database.clientsTable)
          ..where((c) => c.remoteId.equals(id)))
        .getSingleOrNull();

    if (result == null) return null;

    return _mapToModel(result);
  }

  @override
  Future<void> cacheClients(List<ClientModel> clients) async {
    // Get trainer ID from first client (all should have same trainer)
    if (clients.isEmpty) return;

    final trainerId = clients.first.trainerId;

    // CRITICAL: Delete ALL clients for this trainer first
    // This clears both active and deleted clients from cache, avoiding UNIQUE constraint violations
    // on userId field when backend hard-deletes clients.
    // Example: If cache has Client A (user_id=X), and backend now has Client B (user_id=X from new user),
    // we MUST clear all old clients so the new ones can be inserted.
    await (database.delete(database.clientsTable)
          ..where((c) => c.trainerId.equals(trainerId)))
        .go();

    // Now cache fresh clients
    await database.batch((batch) {
      batch.insertAllOnConflictUpdate(
        database.clientsTable,
        clients.map((client) => ClientsTableCompanion(
          remoteId: drift.Value(client.id),
          trainerId: drift.Value(client.trainerId),
          userId: drift.Value(client.userId),
          email: drift.Value(client.email),
          firstName: drift.Value(client.firstName),
          lastName: drift.Value(client.lastName),
          phone: drift.Value(client.phone),
          age: drift.Value(client.age),
          fitnessLevel: drift.Value(client.fitnessLevel),
          goals: drift.Value(client.goals),
          notes: drift.Value(client.notes),
          isActive: drift.Value(client.isActive),
          isSynced: drift.Value(true),
          createdAt: drift.Value(client.createdAt),
          updatedAt: drift.Value(client.updatedAt),
        )),
      );
    });
  }

  @override
  Future<void> saveClient(ClientModel client) async {
    await database.into(database.clientsTable).insert(
      ClientsTableCompanion(
        remoteId: drift.Value(client.id),
        trainerId: drift.Value(client.trainerId),
        userId: drift.Value(client.userId),
        email: drift.Value(client.email),
        firstName: drift.Value(client.firstName),
        lastName: drift.Value(client.lastName),
        phone: drift.Value(client.phone),
        age: drift.Value(client.age),
        fitnessLevel: drift.Value(client.fitnessLevel),
        goals: drift.Value(client.goals),
        notes: drift.Value(client.notes),
        isActive: drift.Value(client.isActive),
        isSynced: drift.Value(true),
        createdAt: drift.Value(client.createdAt),
        updatedAt: drift.Value(client.updatedAt),
      ),
      mode: drift.InsertMode.insertOrReplace,
    );
  }

  @override
  Future<void> updateClient(ClientModel client) async {
    await (database.update(database.clientsTable)
          ..where((c) => c.remoteId.equals(client.id)))
        .write(
      ClientsTableCompanion(
        firstName: drift.Value(client.firstName),
        lastName: drift.Value(client.lastName),
        phone: drift.Value(client.phone),
        age: drift.Value(client.age),
        fitnessLevel: drift.Value(client.fitnessLevel),
        goals: drift.Value(client.goals),
        notes: drift.Value(client.notes),
        isActive: drift.Value(client.isActive),
        updatedAt: drift.Value(client.updatedAt),
      ),
    );
  }

  @override
  Future<void> clearClients() async {
    await database.delete(database.clientsTable).go();
  }

  @override
  Future<void> clearClientsByTrainer(String trainerId) async {
    await (database.delete(database.clientsTable)
          ..where((c) => c.trainerId.equals(trainerId)))
        .go();
  }

  @override
  Future<bool> hasClients() async {
    final count = await database.select(database.clientsTable).get();
    return count.isNotEmpty;
  }

  ClientModel _mapToModel(ClientsTableData row) => ClientModel(
    id: row.remoteId,
    trainerId: row.trainerId,
    userId: row.userId,
    email: row.email,
    firstName: row.firstName,
    lastName: row.lastName,
    phone: row.phone,
    age: row.age,
    fitnessLevel: row.fitnessLevel,
    goals: row.goals,
    notes: row.notes,
    isActive: row.isActive,
    createdAt: row.createdAt ?? DateTime.now(),
    updatedAt: row.updatedAt ?? DateTime.now(),
  );
}
