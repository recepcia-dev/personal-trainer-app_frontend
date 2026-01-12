import 'package:fpdart/fpdart.dart';

import '../../../../core/failure.dart';
import '../entities/client.dart';

/// Client repository interface - defines contract for client data operations
abstract class ClientRepository {
  /// Fetch trainer's clients from remote, filtered by trainerId
  Future<Either<Failure, List<Client>>> fetchClients({
    required String trainerId,
    int skip,
    int limit,
  });

  /// Get clients from local cache
  Future<Either<Failure, List<Client>>> getLocalClients({
    int skip,
    int limit,
  });

  /// Get single client by ID
  Future<Either<Failure, Client>> getClientById(String id);

  /// Create a new client
  Future<Either<Failure, Client>> createClient({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  });

  /// Update client
  Future<Either<Failure, Client>> updateClient(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  });

  /// Delete client (soft delete)
  Future<Either<Failure, void>> deleteClient(String id);

  /// Cache clients locally
  Future<Either<Failure, void>> cacheClients(List<Client> clients);
}
