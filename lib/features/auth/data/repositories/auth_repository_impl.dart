import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] with offline-first pattern.
///
/// Combines [AuthRemoteDataSource] (HTTP API) and [AuthLocalDataSource] (secure storage)
/// to provide authentication operations with offline-first fallback.
///
/// Pattern (from CLAUDE.md):
/// 1. Check network connectivity
/// 2. If online: Try remote, on success cache/store, on error fallback to cache
/// 3. If offline: Use cache
///
/// For mutations (sendMagicLink), errors are returned without cache fallback since
/// there's no previous data to fall back to. Magic links must be requested online.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, void>> sendMagicLink({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendMagicLink(email);
        return const Right(null);
      } on ServerException {
        return const Left(
          ServerFailure(message: 'Failed to send magic link'),
        );
      } on NetworkException {
        return const Left(NetworkFailure(message: 'Network error'));
      } catch (_) {
        return const Left(
          ServerFailure(message: 'Unexpected error occurred'),
        );
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot send magic link.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, dynamic>> verifyMagicLink({
    required String email,
    required String code,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.verifyMagicLink(
          email: email,
          code: code,
        );
        return Right(user);
      } on ServerException {
        return const Left(
          ServerFailure(message: 'Failed to verify magic link'),
        );
      } on NetworkException {
        return const Left(NetworkFailure(message: 'Network error'));
      } catch (_) {
        return const Left(
          ServerFailure(message: 'Unexpected error occurred'),
        );
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot verify magic link.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, dynamic>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getCurrentUser();
        return Right(user);
      } on CacheException {
        // No token stored locally - user not authenticated
        return const Left(CacheFailure(message: 'No authentication token'));
      } on ServerException {
        // Server error - try to get user from cache if available
        return _getCachedUser() ??
            const Left(
              ServerFailure(message: 'Failed to get current user'),
            );
      } on NetworkException {
        // Network error - try to get user from cache if available
        return _getCachedUser() ??
            const Left(NetworkFailure(message: 'Network error'));
      } catch (_) {
        return const Left(ServerFailure(message: 'Unexpected error occurred'));
      }
    } else {
      // Offline - no cached user data available (getCurrentUser is read-only with remote source)
      return const Left(
        NetworkFailure(
          message: 'No internet connection.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Always clear local tokens first
      await localDataSource.clearTokens();

      // Try to notify remote if connected (best effort - don't fail if this fails)
      if (await networkInfo.isConnected) {
        try {
          // Backend logout endpoint can be added here if needed
          // For now, clearing local tokens is sufficient
        } catch (_) {
          // Ignore remote errors - local logout succeeded
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during logout: $e'));
    }
  }

  /// Helper method to attempt getting cached user data.
  ///
  /// Returns Right(null) if no cached user data is available.
  /// Note: This is a placeholder for future local user caching.
  /// Currently, user data is not cached locally - only tokens are stored.
  ///
  /// Returns Either<Failure, dynamic> or null if cache access fails.
  Either<Failure, dynamic>? _getCachedUser() =>
      // TODO: Implement caching of user data in local database (Drift)
      // For now, returns null since user data is not cached locally
      null;
}
