import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:personal_trainer_app/core/error/exceptions.dart';
import 'package:personal_trainer_app/core/payments/stripe_service.dart';
import 'package:personal_trainer_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:personal_trainer_app/features/payments/data/models/payment_intent_model.dart';

class MockAuthRemoteDataSource extends Mock
    implements AuthRemoteDataSource {}

void main() {
  group('StripeService', () {
    late MockAuthRemoteDataSource mockAuthRemoteDataSource;
    late StripeService stripeService;

    setUp(() {
      mockAuthRemoteDataSource = MockAuthRemoteDataSource();
      stripeService = StripeService(
        authRemoteDataSource: mockAuthRemoteDataSource,
      );
    });

    group('createPaymentIntent', () {
      const testAmount = 1000;
      const testCurrency = 'USD';
      const testClientSecret = 'pi_test_secret_123';
      const testPublishableKey = 'pk_test_123';
      const testPaymentIntentId = 'pi_test_123';

      const testPaymentIntentModel = PaymentIntentModel(
        clientSecret: testClientSecret,
        publishableKey: testPublishableKey,
        id: testPaymentIntentId,
        amount: testAmount,
        currency: testCurrency,
      );

      test('returns Right(PaymentIntent) on success', () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: null,
          ),
        ).thenAnswer((_) async => testPaymentIntentModel);

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: testAmount,
          currency: testCurrency,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (paymentIntent) {
            expect(paymentIntent.clientSecret, testClientSecret);
            expect(paymentIntent.id, testPaymentIntentId);
            expect(paymentIntent.amount, testAmount);
            expect(paymentIntent.currency, testCurrency);
          },
        );
      });

      test('returns Right(PaymentIntent) with metadata', () async {
        // Arrange
        final testMetadata = {'orderId': '12345'};
        when(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: testMetadata,
          ),
        ).thenAnswer((_) async => testPaymentIntentModel);

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: testAmount,
          currency: testCurrency,
          metadata: testMetadata,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right, got Left: $failure'),
          (paymentIntent) {
            expect(paymentIntent.clientSecret, testClientSecret);
          },
        );

        // Verify datasource was called with metadata
        verify(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: testMetadata,
          ),
        ).called(1);
      });

      test('returns Left(ServerFailure) on ServerException', () async {
        // Arrange
        final testException = ServerException(
          message: 'Server error',
          statusCode: 500,
        );
        when(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: null,
          ),
        ).thenThrow(testException);

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: testAmount,
          currency: testCurrency,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, 'Server error');
          },
          (paymentIntent) => fail('Expected Left, got Right'),
        );
      });

      test('returns Left(CacheFailure) on CacheException', () async {
        // Arrange
        final testException = CacheException(
          message: 'No access token stored',
        );
        when(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: null,
          ),
        ).thenThrow(testException);

        // Act
        final result = await stripeService.createPaymentIntent(
          amount: testAmount,
          currency: testCurrency,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure.message, 'No access token stored');
          },
          (paymentIntent) => fail('Expected Left, got Right'),
        );
      });

      test('calls authRemoteDataSource.createPaymentIntent with correct params',
          () async {
        // Arrange
        when(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: null,
          ),
        ).thenAnswer((_) async => testPaymentIntentModel);

        // Act
        await stripeService.createPaymentIntent(
          amount: testAmount,
          currency: testCurrency,
        );

        // Assert
        verify(
          () => mockAuthRemoteDataSource.createPaymentIntent(
            amount: testAmount,
            currency: testCurrency,
            metadata: null,
          ),
        ).called(1);
      });
    });
  });
}
