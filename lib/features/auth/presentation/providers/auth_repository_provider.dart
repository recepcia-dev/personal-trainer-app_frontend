import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/send_magic_link.dart';
import '../../domain/usecases/verify_magic_link.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';

part 'auth_repository_provider.g.dart';

/// Provider for the remote data source (API client)
@riverpod
AuthRemoteDataSource authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  final dioClient = DioClient();
  return AuthRemoteDataSourceImpl(dioClient: dioClient);
}

/// Provider for the local data source (secure token storage)
@riverpod
AuthLocalDataSource authLocalDataSource(AuthLocalDataSourceRef ref) {
  return const AuthLocalDataSourceImpl();
}

/// Provider for the auth repository
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  final networkInfo = NetworkInfoImpl(Connectivity());

  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
}

/// Provider for SendMagicLink use case
@riverpod
SendMagicLink sendMagicLinkUseCase(SendMagicLinkUseCaseRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendMagicLink(repository);
}

/// Provider for VerifyMagicLink use case
@riverpod
VerifyMagicLink verifyMagicLinkUseCase(VerifyMagicLinkUseCaseRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyMagicLink(repository);
}

/// Provider for GetCurrentUser use case
@riverpod
GetCurrentUser getCurrentUserUseCase(GetCurrentUserUseCaseRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository);
}

/// Provider for Logout use case
@riverpod
Logout logoutUseCase(LogoutUseCaseRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return Logout(repository);
}
