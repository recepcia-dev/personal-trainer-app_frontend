import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/client_diet_datasource.dart';
import '../../data/models/assigned_diet_model.dart';

/// Provider for client diet datasource
final clientDietDataSourceProvider = Provider<ClientDietDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ClientDietDataSourceImpl(dio: dio);
});

/// Provider for fetching assigned diet/meals for the authenticated client
final assignedDietProvider = FutureProvider.autoDispose<List<AssignedDietModel>>((ref) async {
  final datasource = ref.watch(clientDietDataSourceProvider);
  return await datasource.getAssignedDiet();
});
