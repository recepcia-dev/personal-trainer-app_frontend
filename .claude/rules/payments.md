# Stripe Payment Integration

## Setup

### Keys Management
```bash
# .env.development (NEVER commit)
STRIPE_PUBLISHABLE_KEY=pk_test_...     # Frontend only
STRIPE_SECRET_KEY=sk_test_...          # Backend only (NEVER in frontend)
STRIPE_WEBHOOK_SECRET=whsec_test_...   # Backend only

# .env.production
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...          # Backend only
STRIPE_WEBHOOK_SECRET=whsec_live_...   # Backend only
```

### Flutter Setup
```yaml
# pubspec.yaml
dependencies:
  flutter_stripe: ^11.0.0

# Initialize in main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}
```

---

## Payment Flow

### One-Time Payment
```dart
Future<Either<Failure, PaymentResult>> processPayment(
  double amount,
  String currency, {
  String? description,
  Map<String, String>? metadata,
}) async {
  try {
    // 1. Create payment intent on backend
    final response = await dio.post(
      '/api/v1/payments/intent',
      data: {
        'amount': (amount * 100).toInt(),  // Amount in cents
        'currency': currency.toLowerCase(),
        'description': description,
        'metadata': metadata,
      },
    );

    final clientSecret = response.data['client_secret'] as String;
    final paymentIntentId = response.data['id'] as String;

    // 2. Present payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Personal Trainer App',
        // googlePay: const PaymentSheetGooglePay(
        //   testEnv: true,
        //   currencyCode: 'USD',
        // ),
      ),
    );

    // 3. Show payment UI
    await Stripe.instance.presentPaymentSheet();

    // 4. Confirm payment successful (if no exception thrown)
    return Right(
      PaymentResult(
        success: true,
        paymentIntentId: paymentIntentId,
        amount: amount,
        currency: currency,
      ),
    );
  } on StripeException catch (e) {
    return Left(PaymentFailure('Payment declined: ${e.error.localizedMessage}'));
  } catch (e) {
    return Left(PaymentFailure('Payment failed: $e'));
  }
}
```

### Subscription Payment
```dart
Future<Either<Failure, SubscriptionResult>> createSubscription(
  String priceId,
  Map<String, dynamic> metadata,
) async {
  try {
    // 1. Create subscription intent on backend
    final response = await dio.post(
      '/api/v1/subscriptions/intent',
      data: {
        'price_id': priceId,
        'metadata': metadata,
      },
    );

    final clientSecret = response.data['client_secret'] as String;
    final subscriptionId = response.data['subscription_id'] as String;

    // 2. Present payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Personal Trainer App',
        customFlow: true,  // For subscription setup
      ),
    );

    // 3. Show payment UI
    await Stripe.instance.presentPaymentSheet();

    // 4. Confirm subscription
    return Right(
      SubscriptionResult(
        subscriptionId: subscriptionId,
        priceId: priceId,
        status: 'active',
      ),
    );
  } on StripeException catch (e) {
    return Left(SubscriptionFailure('Setup failed: ${e.error.localizedMessage}'));
  }
}
```

---

## Error Handling

### Payment Failure Recovery
```dart
// Model to track failed payments
class FailedPayment {
  final String paymentIntentId;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;

  FailedPayment({
    required this.paymentIntentId,
    required this.amount,
    required this.currency,
    DateTime? createdAt,
    this.retryCount = 0,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now();
}

// Store failed payments for manual retry
@Riverpod()
class PaymentRetryService extends _$PaymentRetryService {
  @override
  FutureOr<List<FailedPayment>> build() async {
    return ref.watch(databaseProvider).getFailedPayments();
  }

  Future<void> recordFailedPayment(
    String paymentIntentId,
    double amount,
    String currency,
    String error,
  ) async {
    final failed = FailedPayment(
      paymentIntentId: paymentIntentId,
      amount: amount,
      currency: currency,
      lastError: error,
    );

    await ref.watch(databaseProvider).saveFailedPayment(failed);
  }

  Future<Either<Failure, void>> retryPayment(FailedPayment payment) async {
    try {
      // Show payment sheet again
      final result = await ref
          .watch(paymentRepositoryProvider)
          .processPayment(payment.amount, payment.currency);

      if (result.isRight()) {
        // Clear from failed payments
        await ref.watch(databaseProvider).deleteFailedPayment(
          payment.paymentIntentId,
        );
      }

      return result;
    } catch (e) {
      return Left(PaymentFailure('Retry failed: $e'));
    }
  }
}
```

### Handle Different Failure Types
```dart
enum PaymentErrorType {
  cardDeclined,          // Customer's card was declined
  insufficientFunds,     // Not enough money
  expiredCard,           // Card expired
  networkError,          // Connection issue
  cancelled,             // User cancelled
  unknown,
}

PaymentErrorType _parseStripeError(StripeException e) {
  final errorCode = e.error.code;

  return switch (errorCode) {
    'card_error' => PaymentErrorType.cardDeclined,
    'rate_limit' => PaymentErrorType.networkError,
    'api_connection_error' => PaymentErrorType.networkError,
    'api_error' => PaymentErrorType.unknown,
    'authentication_error' => PaymentErrorType.networkError,
    'invalid_request_error' => PaymentErrorType.unknown,
    _ => PaymentErrorType.unknown,
  };
}

// UI handling
void _handlePaymentError(PaymentErrorType type) {
  final message = switch (type) {
    PaymentErrorType.cardDeclined => 'Your card was declined. Try another card.',
    PaymentErrorType.insufficientFunds => 'Insufficient funds. Please check your account.',
    PaymentErrorType.expiredCard => 'Your card has expired.',
    PaymentErrorType.networkError => 'Network error. Please try again.',
    PaymentErrorType.cancelled => 'Payment cancelled.',
    PaymentErrorType.unknown => 'Payment failed. Please try again.',
  };

  showErrorSnackbar(message);
}
```

---

## Testing in Development

### Test Mode Keys
```bash
# Use only these in development
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Test card numbers:
# Success: 4242 4242 4242 4242
# Decline: 4000 0000 0000 0002
# Requires authentication: 4000 0025 0000 3155
```

### NEVER Do This in Development
```dart
// ✗ WRONG: Testing with real card
final cardNumber = '4111 1111 1111 1111';  // Real test card
final result = await Stripe.instance.confirmPaymentSheetPayment();

// ✗ WRONG: Using live keys in development
Stripe.publishableKey = 'pk_live_...';
```

### Correct Testing Approach
```dart
// ✓ CORRECT: Use test keys
Stripe.publishableKey = const String.fromEnvironment(
  'STRIPE_PUBLISHABLE_KEY',
  defaultValue: 'pk_test_...',
);

// ✓ CORRECT: Provide UI for testing
// In development build only:
if (kDebugMode) {
  // Show test card input UI
  // Or use 4242 4242 4242 4242 from test card selector
}
```

---

## Webhook Handling (Backend Responsibility)

### Webhook Events to Monitor
Frontend should listen for these events (via polling or WebSocket):
```
payment_intent.succeeded
payment_intent.payment_failed
customer.subscription.created
customer.subscription.updated
customer.subscription.deleted
invoice.paid
invoice.payment_failed
```

### Frontend Webhook Integration
```dart
// Listen for webhook updates via Riverpod provider
@riverpod
Stream<PaymentStatus> paymentStatusStream(
  PaymentStatusStreamRef ref,
  String paymentIntentId,
) {
  return Stream.periodic(
    const Duration(seconds: 5),
    (_) => paymentIntentId,
  ).asyncMap((id) async {
    final response = await Dio().get(
      '/api/v1/payments/$id/status',
    );
    return PaymentStatus.fromJson(response.data);
  });
}

// Use in UI
class PaymentStatusWidget extends ConsumerWidget {
  final String paymentIntentId;

  const PaymentStatusWidget({required this.paymentIntentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(paymentStatusStream(paymentIntentId));

    return status.when(
      loading: () => const CircularProgressIndicator(),
      error: (err, st) => Text('Error: $err'),
      data: (status) {
        if (status.succeeded) {
          return const Text('Payment successful!');
        } else if (status.failed) {
          return const Text('Payment failed. Please try again.');
        }
        return const Text('Processing...');
      },
    );
  }
}
```

---

## Subscription Management

### Subscription States
```dart
enum SubscriptionStatus {
  incomplete,              // Setup not complete
  incompleteExpired,       // Setup expired
  trialing,                // In free trial
  active,                  // Active subscription
  pastDue,                 // Payment overdue
  canceled,                // Cancelled (may be reactivated)
  unpaid,                  // Payment issue
}

class Subscription {
  final String id;
  final String customerId;
  final String priceId;
  final SubscriptionStatus status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime? cancelAt;
  final bool cancelAtPeriodEnd;

  Subscription({
    required this.id,
    required this.customerId,
    required this.priceId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.cancelAt,
    this.cancelAtPeriodEnd = false,
  });
}
```

### Cancel Subscription with Grace Period
```dart
Future<Either<Failure, Subscription>> cancelSubscription(
  String subscriptionId,
  {Duration gracePeriod = const Duration(hours: 48)}
) async {
  try {
    // Schedule cancellation at end of period (with grace)
    final response = await dio.post(
      '/api/v1/subscriptions/$subscriptionId/cancel',
      data: {
        'cancel_at_period_end': true,
        'grace_period_hours': gracePeriod.inHours,
      },
    );

    return Right(Subscription.fromJson(response.data));
  } catch (e) {
    return Left(SubscriptionFailure('Cancellation failed: $e'));
  }
}

// Show reactivation UI during grace period
class SubscriptionCancellationWidget extends ConsumerWidget {
  final Subscription subscription;

  const SubscriptionCancellationWidget({required this.subscription});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeUntilCancel = subscription.currentPeriodEnd.difference(
      DateTime.now(),
    );

    return AlertDialog(
      title: const Text('Subscription Cancelling'),
      content: Text(
        'Your subscription will cancel in ${timeUntilCancel.inDays} days.\n\n'
        'You can reactivate anytime.',
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final result = await ref
                .read(subscriptionRepositoryProvider)
                .reactivateSubscription(subscription.id);

            result.fold(
              (failure) => showErrorSnackbar(failure.message),
              (_) => showSuccessSnackbar('Subscription reactivated!'),
            );
          },
          child: const Text('Reactivate'),
        ),
      ],
    );
  }
}
```

---

## Idempotency & Deduplication

### Idempotent Keys
```dart
// Always include idempotency key to prevent double-charging
Future<PaymentResult> processPayment(
  double amount,
  String currency,
) async {
  final idempotencyKey = generateIdempotencyKey();

  try {
    final response = await dio.post(
      '/api/v1/payments/intent',
      data: {
        'amount': (amount * 100).toInt(),
        'currency': currency,
        'idempotency_key': idempotencyKey,  // Prevent duplicates
      },
      options: Options(
        headers: {'Idempotency-Key': idempotencyKey},
      ),
    );

    return PaymentResult.fromJson(response.data);
  } catch (e) {
    // If error, safe to retry with same key
    // Backend will return existing payment, not create duplicate
  }
}

String generateIdempotencyKey() {
  return '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
}
```

---

## Payment Checklist

- [ ] **Keys:** Using environment variables (not hardcoded)
- [ ] **Test Mode:** Using `pk_test_` in development
- [ ] **Card Data:** NEVER handle raw card numbers (use Stripe SDK)
- [ ] **Error Handling:** All payment errors caught and displayed
- [ ] **Failed Payments:** Logged with payment intent IDs for recovery
- [ ] **Webhooks:** Backend verifies signatures before processing
- [ ] **Idempotency:** Idempotency keys prevent double-charging
- [ ] **Grace Period:** Subscriptions have 24-48hr cancellation grace
- [ ] **Testing:** Test cards used in development/staging
- [ ] **Live:** Live keys used only in production
