import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/failures.dart';
import 'package:personal_trainer_app/features/auth/domain/entities/trainer.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/logout.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/send_magic_link.dart';
import 'package:personal_trainer_app/features/auth/domain/usecases/verify_magic_link.dart';
import 'package:personal_trainer_app/features/auth/presentation/providers/auth_repository_provider.dart';
import 'package:personal_trainer_app/features/auth/presentation/providers/auth_state_provider.dart';

// Mock use cases
class MockSendMagicLink extends Mock implements SendMagicLink {}

class MockVerifyMagicLink extends Mock implements VerifyMagicLink {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockLogout extends Mock implements Logout {}

void main() {
  late MockSendMagicLink mockSendMagicLink;
  late MockVerifyMagicLink mockVerifyMagicLink;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockLogout mockLogout;

  const testEmail = 'test@example.com';
  const testCode = '123456';

  const testTrainer = Trainer(
    email: testEmail,
    name: 'John Doe',
    photoUrl: null,
  );

  setUp(() {
    mockSendMagicLink = MockSendMagicLink();
    mockVerifyMagicLink = MockVerifyMagicLink();
    mockGetCurrentUser = MockGetCurrentUser();
    mockLogout = MockLogout();
  });

  group('AuthStateProvider', () {

    group('sendMagicLink', () {
      test('transitions to loading and then data on success', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(() => mockSendMagicLink.call(email: testEmail, userType: 'trainer')).thenAnswer(
          (_) async => const Right(null),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            sendMagicLinkUseCaseProvider.overrideWithValue(mockSendMagicLink),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.sendMagicLink(testEmail, 'trainer');

        final result = container.read(authStateProvider);
        expect(result, isA<AsyncData<dynamic>>());
        result.whenData((user) {
          expect(user, isNull); // Still null after sending link
        });
      });

      test('transitions to error on failure', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(() => mockSendMagicLink.call(email: testEmail, userType: 'trainer')).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Invalid email'),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            sendMagicLinkUseCaseProvider.overrideWithValue(mockSendMagicLink),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.sendMagicLink(testEmail, 'trainer');

        final result = container.read(authStateProvider);
        expect(result, isA<AsyncError<dynamic>>());
      });

      test('verifies use case is called with correct email', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(() => mockSendMagicLink.call(email: testEmail, userType: 'trainer')).thenAnswer(
          (_) async => const Right(null),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            sendMagicLinkUseCaseProvider.overrideWithValue(mockSendMagicLink),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.sendMagicLink(testEmail, 'trainer');

        verify(() => mockSendMagicLink.call(email: testEmail, userType: 'trainer')).called(1);
      });
    });

    group('verifyMagicLink', () {
      test('transitions to data with user on success', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(
          () => mockVerifyMagicLink.call(email: testEmail, code: testCode),
        ).thenAnswer(
          (_) async => const Right(testTrainer),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            verifyMagicLinkUseCaseProvider.overrideWithValue(
              mockVerifyMagicLink,
            ),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.verifyMagicLink(email: testEmail, code: testCode);

        final result = container.read(authStateProvider);
        expect(result, isA<AsyncData<dynamic>>());
        result.whenData((user) {
          expect(user, equals(testTrainer));
        });
      });

      test('transitions to error on invalid code', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(
          () => mockVerifyMagicLink.call(email: testEmail, code: testCode),
        ).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Invalid code'),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            verifyMagicLinkUseCaseProvider.overrideWithValue(
              mockVerifyMagicLink,
            ),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.verifyMagicLink(email: testEmail, code: testCode);

        final result = container.read(authStateProvider);
        expect(result, isA<AsyncError<dynamic>>());
      });

      test('verifies use case is called with correct parameters', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(
          () => mockVerifyMagicLink.call(email: testEmail, code: testCode),
        ).thenAnswer(
          (_) async => const Right(testTrainer),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            verifyMagicLinkUseCaseProvider.overrideWithValue(
              mockVerifyMagicLink,
            ),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.verifyMagicLink(email: testEmail, code: testCode);

        verify(
          () => mockVerifyMagicLink.call(email: testEmail, code: testCode),
        ).called(1);
      });
    });


    group('logout', () {
      test('transitions to data with null on success', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Right(testTrainer),
        );
        when(() => mockLogout.call()).thenAnswer(
          (_) async => const Right(null),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            logoutUseCaseProvider.overrideWithValue(mockLogout),
          ],
        );

        await container.pump();

        // Verify user is authenticated before logout
        var result = container.read(authStateProvider);
        result.whenData((user) {
          expect(user, equals(testTrainer));
        });

        final notifier = container.read(authStateProvider.notifier);
        await notifier.logout();

        // After logout, user should be null
        result = container.read(authStateProvider);
        expect(result, isA<AsyncData<dynamic>>());
        result.whenData((user) {
          expect(user, isNull);
        });
      });

      test('transitions to error on logout failure', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Right(testTrainer),
        );
        when(() => mockLogout.call()).thenAnswer(
          (_) async => const Left(
            CacheFailure(message: 'Failed to clear tokens'),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            logoutUseCaseProvider.overrideWithValue(mockLogout),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.logout();

        final result = container.read(authStateProvider);
        expect(result, isA<AsyncError<dynamic>>());
      });

      test('verifies use case is called', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Right(testTrainer),
        );
        when(() => mockLogout.call()).thenAnswer(
          (_) async => const Right(null),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            logoutUseCaseProvider.overrideWithValue(mockLogout),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        await notifier.logout();

        verify(() => mockLogout.call()).called(1);
      });
    });

    group('State transitions', () {
      test('sendMagicLink sets loading state before calling use case',
          () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(() => mockSendMagicLink.call(email: testEmail, userType: 'trainer')).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => const Right<Failure, void>(null),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            sendMagicLinkUseCaseProvider.overrideWithValue(mockSendMagicLink),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        final future = notifier.sendMagicLink(testEmail, 'trainer');

        final state = container.read(authStateProvider);
        expect(state, isA<AsyncLoading<dynamic>>());

        await future;
      });

      test('verifyMagicLink sets loading state before calling use case',
          () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Left(ServerFailure(message: 'Not authenticated')),
        );
        when(
          () => mockVerifyMagicLink.call(email: testEmail, code: testCode),
        ).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => const Right<Failure, dynamic>(testTrainer),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            verifyMagicLinkUseCaseProvider.overrideWithValue(
              mockVerifyMagicLink,
            ),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        final future = notifier.verifyMagicLink(
          email: testEmail,
          code: testCode,
        );

        final state = container.read(authStateProvider);
        expect(state, isA<AsyncLoading<dynamic>>());

        await future;
      });

      test('logout sets loading state before calling use case', () async {
        when(() => mockGetCurrentUser.call()).thenAnswer(
          (_) async => const Right(testTrainer),
        );
        when(() => mockLogout.call()).thenAnswer(
          (_) async => Future.delayed(
            const Duration(milliseconds: 100),
            () => const Right<Failure, void>(null),
          ),
        );

        final container = ProviderContainer(
          overrides: [
            getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
            logoutUseCaseProvider.overrideWithValue(mockLogout),
          ],
        );

        await container.pump();

        final notifier = container.read(authStateProvider.notifier);
        final future = notifier.logout();

        var state = container.read(authStateProvider);
        expect(state, isA<AsyncLoading<dynamic>>());

        await future;
      });
    });
  });
}
