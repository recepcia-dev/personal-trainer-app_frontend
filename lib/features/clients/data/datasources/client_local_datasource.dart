import 'package:drift/drift.dart' as drift;

import '../../../../database/app_database.dart';
import '../models/client_model.dart';

/// Local data source for client data - handles Drift database operations
abstract class ClientLocalDataSource {
  /// Get all clients from local database
  Future<List<ClientModel>> getClients({
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

  /// Check if clients exist in cache
  Future<bool> hasClients();
}

class ClientLocalDataSourceImpl implements ClientLocalDataSource {
  final AppDatabase database;

  ClientLocalDataSourceImpl({required this.database});

  @override
  Future<List<ClientModel>> getClients({
    int skip = 0,
    int limit = 50,
  }) async {
    final results = await (database.select(database.clientsTable)
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
