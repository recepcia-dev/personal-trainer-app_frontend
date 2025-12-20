import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/progress_remote_datasource.dart';
import '../../data/models/progress_request_model.dart';

/// Provider for progress datasource
final progressDataSourceProvider = Provider<ProgressRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProgressRemoteDataSourceImpl(dio: dio);
});

/// Provider for registering workout progress
final registerProgressProvider =
    FutureProvider.family.autoDispose<ProgressEntryModel, ProgressRequestModel>(
  (ref, request) async {
    final datasource = ref.watch(progressDataSourceProvider);
    return await datasource.registerProgress(request);
  },
);

/// Provider for fetching progress history
final progressHistoryProvider =
    FutureProvider.autoDispose<List<ProgressEntryModel>>((ref) async {
  final datasource = ref.watch(progressDataSourceProvider);
  return await datasource.getProgressHistory();
});
