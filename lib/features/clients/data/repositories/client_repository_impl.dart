import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_local_datasource.dart';
import '../datasources/client_remote_datasource.dart';
import '../models/client_model.dart';

/// Client repository implementation with offline-first pattern
class ClientRepositoryImpl implements ClientRepository {
  final ClientRemoteDataSource remoteDataSource;
  final ClientLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ClientRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Client>>> fetchClients({
    required String trainerId,
    int skip = 0,
    int limit = 50,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        if (kDebugMode) {
          debugPrint('🔵 [ClientRepositoryImpl] Fetching clients for trainer: $trainerId');
        }

        final remoteClients = await remoteDataSource.fetchClients(
          trainerId: trainerId,
          skip: skip,
          limit: limit,
        );

        if (kDebugMode) {
          debugPrint('✅ [ClientRepositoryImpl] Fetched ${remoteClients.length} remote clients');
        }

        await localDataSource.cacheClients(remoteClients);

        // Convert to entities and filter by trainer (SECURITY: Additional client-side check)
        final entities = remoteClients.map((m) => m.toEntity()).toList();
        final filtered = entities.where((client) => client.trainerId == trainerId).toList();

        if (kDebugMode && filtered.length != entities.length) {
          debugPrint('⚠️ [ClientRepositoryImpl] SECURITY ALERT: Filtered out ${entities.length - filtered.length} clients not belonging to trainer $trainerId');
          if (entities.length > filtered.length) {
            for (var client in entities) {
              if (client.trainerId != trainerId) {
                debugPrint('   - Filtered client: ${client.email} (trainer_id: ${client.trainerId})');
              }
            }
          }
        }

        return Right(filtered);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('❌ [ClientRepositoryImpl] Error fetching remote clients: $e');
        }
        return _getLocalClients(trainerId: trainerId, skip: skip, limit: limit);
      }
    } else {
      return _getLocalClients(trainerId: trainerId, skip: skip, limit: limit);
    }
  }

  @override
  Future<Either<Failure, List<Client>>> getLocalClients({
    int skip = 0,
    int limit = 50,
  }) async {
    // This method is deprecated - use fetchClients instead
    // Cannot call _getLocalClients without trainerId
    return Left(CacheFailure('getLocalClients deprecated - trainerId required'));
  }

  @override
  Future<Either<Failure, Client>> getClientById(String id) async {
    try {
      final client = await localDataSource.getClientById(id);

      if (client != null) {
        return Right(client.toEntity());
      }

      if (await networkInfo.isConnected) {
        try {
          final remoteClient = await remoteDataSource.getClientById(id);
          await localDataSource.saveClient(remoteClient);
          return Right(remoteClient.toEntity());
        } catch (e) {
          return Left(ServerFailure('Failed to fetch client: $e'));
        }
      }

      return Left(CacheFailure('Client not found'));
    } catch (e) {
      return Left(CacheFailure('Failed to get client: $e'));
    }
  }

  @override
  Future<Either<Failure, Client>> createClient({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final remoteClient = await remoteDataSource.createClient(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        fitnessLevel: fitnessLevel,
        goals: goals,
        notes: notes,
      );

      await localDataSource.saveClient(remoteClient);
      return Right(remoteClient.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to create client: $e'));
    }
  }

  @override
  Future<Either<Failure, Client>> updateClient(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final remoteClient = await remoteDataSource.updateClient(
        id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        fitnessLevel: fitnessLevel,
        goals: goals,
        notes: notes,
      );

      await localDataSource.updateClient(remoteClient);
      return Right(remoteClient.toEntity());
    } catch (e) {
      return Left(ServerFailure('Failed to update client: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteClient(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.deleteClient(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to delete client: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cacheClients(List<Client> clients) async {
    try {
      final models = clients.map((c) => ClientModel.fromEntity(c)).toList();
      await localDataSource.cacheClients(models);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to cache clients: $e'));
    }
  }

  Future<Either<Failure, List<Client>>> _getLocalClients({
    required String trainerId,
    int skip = 0,
    int limit = 50,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('🔵 [ClientRepositoryImpl] Fetching local clients for trainer: $trainerId');
      }

      final localClients = await localDataSource.getClients(
        trainerId: trainerId,
        skip: skip,
        limit: limit,
      );

      if (kDebugMode) {
        debugPrint('✅ [ClientRepositoryImpl] Fetched ${localClients.length} local clients');
      }

      return Right(localClients.map((m) => m.toEntity()).toList());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [ClientRepositoryImpl] Error getting local clients: $e');
      }
      return Left(CacheFailure('Failed to get local clients: $e'));
    }
  }
}
