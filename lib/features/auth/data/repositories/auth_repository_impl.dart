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
    required String userType,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendMagicLink(email, userType);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
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
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
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
      } on CacheException catch (e) {
        // No token stored locally - user not authenticated
        return Left(CacheFailure(message: e.message));
      } on ServerException catch (e) {
        // Server error - try to get user from cache if available
        return _getCachedUser() ??
            Left(
              ServerFailure(message: e.message, statusCode: e.statusCode),
            );
      } on NetworkException catch (e) {
        // Network error - try to get user from cache if available
        return _getCachedUser() ?? Left(NetworkFailure(message: e.message));
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

  @override
  Future<Either<Failure, void>> bindDevice() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.bindDevice();
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to bind device: $e'));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot bind device.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> registerFcmToken(String fcmToken) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.registerFcmToken(fcmToken);
        return const Right(null);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to register FCM token: $e'));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot register FCM token.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, dynamic>> registerTrainer({
    required String email,
    required String firstName,
    required String lastName,
    required String specialty,
    String? bio,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final trainer = await remoteDataSource.registerTrainer(
          email: email,
          firstName: firstName,
          lastName: lastName,
          specialty: specialty,
          bio: bio,
        );
        return Right(trainer);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to register trainer: $e'));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot register trainer.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, dynamic>> registerClient({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    required double weightKg,
    required double heightCm,
    required String fitnessLevel,
    required String trainerCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final client = await remoteDataSource.registerClient(
          email: email,
          firstName: firstName,
          lastName: lastName,
          age: age,
          weightKg: weightKg,
          heightCm: heightCm,
          fitnessLevel: fitnessLevel,
          trainerCode: trainerCode,
        );
        return Right(client);
      } on ServerException catch (e) {
        return Left(
          ServerFailure(message: e.message, statusCode: e.statusCode),
        );
      } on NetworkException catch (e) {
        return Left(NetworkFailure(message: e.message));
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to register client: $e'));
      }
    } else {
      return const Left(
        NetworkFailure(
          message: 'No internet connection. Cannot register client.',
        ),
      );
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
