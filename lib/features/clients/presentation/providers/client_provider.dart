import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/client_local_datasource.dart';
import '../../data/datasources/client_remote_datasource.dart';
import '../../data/repositories/client_repository_impl.dart';
import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../../../progress/presentation/providers/exercise_provider.dart';
import '../../../../core/network/dio_provider.dart';

/// Client remote data source provider
final clientRemoteDataSourceProvider =
    Provider<ClientRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientRemoteDataSourceImpl(dio: dio);
});

/// Client local data source provider
final clientLocalDataSourceProvider = Provider<ClientLocalDataSource>((ref) {
  final database = ref.watch(databaseProvider);
  return ClientLocalDataSourceImpl(database: database);
});

/// Client repository provider
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepositoryImpl(
    remoteDataSource: ref.watch(clientRemoteDataSourceProvider),
    localDataSource: ref.watch(clientLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

/// Clients list provider with pagination
final clientsProvider =
    FutureProvider.family<List<Client>, ({int skip, int limit})>(
  (ref, params) async {
    return ref
        .watch(clientRepositoryProvider)
        .fetchClients(skip: params.skip, limit: params.limit)
        .then((result) => result.fold(
          (failure) => throw Exception(failure),
          (clients) => clients,
        ));
  },
);

/// All clients provider (no pagination)
final allClientsProvider = FutureProvider<List<Client>>((ref) async {
  return ref
      .watch(clientsProvider((skip: 0, limit: 100)))
      .maybeWhen(
        data: (clients) => clients,
        orElse: () => throw Exception('Failed to load clients'),
      );
});

/// Single client provider
final clientProvider =
    FutureProvider.family<Client, String>((ref, clientId) async {
  return ref
      .watch(clientRepositoryProvider)
      .getClientById(clientId)
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (client) => client,
      ));
});

/// Create client state notifier
class CreateClientNotifier extends StateNotifier<AsyncValue<Client>> {
  final ClientRepository _repository;

  CreateClientNotifier({required ClientRepository repository})
      : _repository = repository,
        super(AsyncValue.data(
          Client(
            id: '',
            trainerId: '',
            userId: '',
            email: '',
            isActive: false,
            createdAt: DateTime(2000),
            updatedAt: DateTime(2000),
          ),
        ));

  Future<void> createClient({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    if (kDebugMode) {
      debugPrint('🔵 [ClientCreate] Starting client creation for email: $email');
    }

    state = const AsyncValue.loading();

    if (kDebugMode) {
      debugPrint('🔵 [ClientCreate] State set to loading');
    }

    try {
      if (kDebugMode) {
        debugPrint('🔵 [ClientCreate] Calling repository.createClient()...');
      }

      final result = await _repository.createClient(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        age: age,
        fitnessLevel: fitnessLevel,
        goals: goals,
        notes: notes,
      );

      if (kDebugMode) {
        debugPrint('🔵 [ClientCreate] Repository returned result');
      }

      // Handle result
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('❌ [ClientCreate] FAILURE: $failure');
          }
          state = AsyncValue.error(failure, StackTrace.current);
        },
        (client) {
          if (kDebugMode) {
            debugPrint('✅ [ClientCreate] SUCCESS: Client created with ID ${client.id}');
          }
          state = AsyncValue.data(client);
        },
      );

      // Throw exception if creation failed so UI can handle it
      result.fold(
        (failure) {
          if (kDebugMode) {
            debugPrint('🔴 [ClientCreate] Throwing exception with failure: $failure');
          }
          throw Exception('Client creation failed: $failure');
        },
        (client) => null,
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('🔴 [ClientCreate] EXCEPTION CAUGHT: $e');
        debugPrint('🔴 [ClientCreate] Stack trace: $stackTrace');
      }
      rethrow; // Re-throw so UI can catch it
    }
  }
}

/// Create client notifier provider
final createClientNotifierProvider =
    StateNotifierProvider<CreateClientNotifier, AsyncValue<Client>>(
  (ref) {
    return CreateClientNotifier(repository: ref.watch(clientRepositoryProvider));
  },
);

/// Update client state notifier
class UpdateClientNotifier extends StateNotifier<AsyncValue<Client>> {
  final ClientRepository _repository;

  UpdateClientNotifier({required ClientRepository repository})
      : _repository = repository,
        super(AsyncValue.data(
          Client(
            id: '',
            trainerId: '',
            userId: '',
            email: '',
            isActive: false,
            createdAt: DateTime(2000),
            updatedAt: DateTime(2000),
          ),
        ));

  Future<void> updateClient(
    String id, {
    String? firstName,
    String? lastName,
    String? phone,
    int? age,
    String? fitnessLevel,
    String? goals,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    final result = await _repository.updateClient(
      id,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      age: age,
      fitnessLevel: fitnessLevel,
      goals: goals,
      notes: notes,
    );

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (client) => AsyncValue.data(client),
    );

    // Throw exception if update failed so UI can handle it
    result.fold(
      (failure) => throw Exception(failure),
      (client) => null,
    );
  }
}

/// Update client notifier provider
final updateClientNotifierProvider =
    StateNotifierProvider<UpdateClientNotifier, AsyncValue<Client>>(
  (ref) {
    return UpdateClientNotifier(repository: ref.watch(clientRepositoryProvider));
  },
);

/// Delete client provider
final deleteClientProvider =
    FutureProvider.family<void, String>((ref, clientId) async {
  return ref
      .watch(clientRepositoryProvider)
      .deleteClient(clientId)
      .then((result) => result.fold(
        (failure) => throw Exception(failure),
        (unit) => unit,
      ));
});
