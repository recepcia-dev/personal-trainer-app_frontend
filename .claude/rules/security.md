# Security Guidelines

## Authentication System (Mandatory)

### Magic Link + Device Biometric Flow
```
1. User enters email → Backend sends magic link code via email
2. User enters code from email → Backend verifies code validity
3. User authenticates locally via device (biometric/PIN) → local_auth package
4. Token stored securely → flutter_secure_storage
```

### Token Management
- **Storage:** ALWAYS use `flutter_secure_storage` with platform-native encryption
- **NEVER:** Store tokens in `shared_preferences` (plaintext, insecure)
- **Tokens:** Short-lived (15-30 min) with refresh mechanism
- **Refresh Token:** Store securely, use for getting new access tokens
- **Logout:** Delete both access and refresh tokens

### Code Example
```dart
// ✓ Correct: Using flutter_secure_storage
final secureStorage = FlutterSecureStorage();
await secureStorage.write(key: 'access_token', value: token);

// ✓ Correct: Device-bound authentication
final result = await LocalAuthentication().authenticate(
  localizedReason: 'Authenticate to access your account',
  options: const AuthenticationOptions(biometricOnly: true),
);

// ✗ Wrong: Using shared_preferences for tokens
SharedPreferences.getInstance().then((sp) => sp.setString('token', token));
```

---

## Sensitive Data Protection

### Client Health Data (PII)
- Fitness data, health metrics, measurements are **Personally Identifiable Information**
- Implement field-level encryption for health data at rest
- Use HTTPS for all transit (enforced by Dio + certificate pinning)
- Implement GDPR compliance:
  - Data retention policies
  - Right to deletion/export
  - Consent tracking

### Stripe & Payment Data
- **NEVER** handle raw card numbers - use Stripe SDK only
- **NEVER** commit Stripe keys (`.env` files excluded from git)
- Store `stripe_customer_id` locally (not sensitive)
- Store `payment_intent_id` for failed payment recovery
- Verify webhook signatures to prevent fraud

### Environment Variables
```bash
# .env.development (NEVER commit)
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
FIREBASE_PROJECT_ID=...
FIREBASE_API_KEY=...

# NEVER commit - add to .gitignore
.env
.env.development
.env.production
.env.local
```

---

## API Security

### Dio Configuration
```dart
// Configure Dio with security headers
final dio = Dio(BaseOptions(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
))
  ..interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add fresh token before each request
        final token = secureStorage.read(key: 'access_token');
        options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle 401 - refresh token and retry
        if (error.response?.statusCode == 401) {
          return _handleTokenRefresh(error, handler);
        }
        return handler.next(error);
      },
    ),
  );
```

### Certificate Pinning (Optional but Recommended)
```dart
class SecurityConfig {
  static SecurityContext getSecurityContext() {
    final context = SecurityContext.defaultContext;
    final certificate = File('assets/certificates/api.pem').readAsBytesSync();
    context.setTrustedCertificatesBytes(certificate);
    return context;
  }
}

// Use in Dio
dio.httpClientAdapter = IOHttpClientAdapter(
  createHttpClient: () {
    final client = HttpClient(context: SecurityConfig.getSecurityContext());
    client.badCertificateCallback = (cert, host, port) => false;
    return client;
  },
);
```

---

## Stripe Webhook Security

### Verify Signatures (MANDATORY)
All Stripe webhooks must have signatures verified server-side (backend responsibility):
```
POST /api/v1/webhooks/stripe
Header: Stripe-Signature: <signature>
Body: JSON payload

Backend MUST:
1. Retrieve webhook endpoint secret
2. Verify signature using endpoint secret
3. Only process if signature is valid
```

Frontend responsibility:
- Listen for webhook events via Riverpod provider
- Update local state based on webhook (subscription status, payment success, etc.)
- NEVER trust client-side payment completion - wait for webhook confirmation

---

## Input Validation

### Server Boundary Validation
Validate all external inputs (user, API, webhooks):
```dart
// ✓ Validate at API boundary
Future<Either<Failure, User>> getUser(String userId) async {
  // Validate input
  if (userId.isEmpty) return Left(ValidationFailure('Invalid user ID'));

  try {
    final response = await dio.get('/users/$userId');
    final user = User.fromJson(response.data);
    return Right(user);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}

// ✓ Validate Pydantic models on backend
class UserModel(BaseModel):
  id: str  # Required
  email: EmailStr  # Validated email format
  age: int = Field(ge=0, le=120)  # Range validation
```

### Form Validation (Presentation Layer)
```dart
TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Email required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
      return 'Invalid email';
    }
    return null;
  },
)
```

---

## GDPR & Privacy Compliance

### Data Retention
- Client account data: Keep for account lifetime + 90 days after deletion
- Workout history: Allow user-configurable retention (default 1 year)
- Payment records: Keep for 7 years (legal requirement)
- Logs/analytics: Keep for 30 days

### User Rights
- **Right to Access:** Export all user data in standard format
- **Right to Deletion:** Delete all PII, keep anonymized records for 90 days
- **Right to Portability:** Export data in JSON/CSV format
- **Consent:** Explicit opt-in for marketing/analytics

### Implementation
```dart
// Export user data
Future<Either<Failure, String>> exportUserData(String userId) async {
  // Gather all user data
  final profile = await getProfile(userId);
  final workouts = await getWorkouts(userId);
  final payments = await getPayments(userId);

  // Convert to JSON
  final data = {
    'profile': profile.toJson(),
    'workouts': workouts.map((w) => w.toJson()).toList(),
    'payments': payments.map((p) => p.toJson()).toList(),
  };

  return Right(jsonEncode(data));
}

// Delete user account
Future<Either<Failure, void>> deleteAccount(String userId) async {
  // 1. Delete PII (profile, health data)
  // 2. Anonymize (workouts, payments)
  // 3. Delete tokens
  // 4. Schedule final deletion after 90 days
}
```

---

## Security Checklist

- [ ] **Auth Tokens:** Using `flutter_secure_storage` (not `shared_preferences`)
- [ ] **Passwords:** Zero password storage (magic links only)
- [ ] **Biometrics:** Enabled via `local_auth` package
- [ ] **Stripe Keys:** In `.env` (never in code)
- [ ] **API Calls:** HTTPS only with valid certificates
- [ ] **Secrets:** Never logged or exposed in error messages
- [ ] **Token Refresh:** Implemented with 401 interception
- [ ] **Webhook Signatures:** Verified server-side (backend)
- [ ] **Input Validation:** All external data validated
- [ ] **Encryption:** Health data encrypted at rest
- [ ] **GDPR:** Export/delete functionality implemented
- [ ] **Testing:** No real API keys in test fixtures
