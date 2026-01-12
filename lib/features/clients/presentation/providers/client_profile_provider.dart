import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/client.dart';
import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../auth/data/models/client_model.dart';
import './client_provider.dart';

part 'client_profile_provider.g.dart';

/// Provider for fetching the current client's full profile
@riverpod
Future<Client> clientProfile(ClientProfileRef ref) async {
  final user = ref.watch(authStateProvider);
  if (user is! ClientModel) {
    throw Exception('User is not a client');
  }

  // Fetch client details from repository
  final result =
      await ref.watch(clientRepositoryProvider).getClientById(user.id);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (client) => client,
  );
}
