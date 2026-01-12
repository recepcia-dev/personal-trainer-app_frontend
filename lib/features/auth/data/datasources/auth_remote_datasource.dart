import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/device/device_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../payments/data/models/payment_intent_model.dart';
import '../models/client_model.dart';
import '../models/trainer_model.dart';
import '../models/verify_magic_link_response_model.dart';

/// Abstract interface for remote authentication data operations.
///
/// Implementations communicate with the backend API for authentication flows.
/// All methods throw exceptions on failure (exceptions are caught by repositories).
///
/// Despite having a single method initially, this interface enables:
/// - Dependency inversion: repository depends on interface, not implementation
/// - Testability: mock implementations for unit tests
/// - Extensibility: future methods will follow this interface
/// - Loose coupling: implementations can change without affecting repository
// ignore: one_member_abstracts
abstract class AuthRemoteDataSource {
  /// Send a magic link to the provided email.
  ///
  /// The backend will send an email containing a code that the user can use
  /// for passwordless authentication.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///   - userType: The user type (trainer or client)
  ///
  /// Throws:
  ///   - ServerException: If the server returns an error response
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<void> sendMagicLink(String email, String userType);

  /// Verify the magic link code and authenticate the user.
  ///
  /// Called after user receives the magic link email and enters the verification code.
  /// Returns the authenticated user (Trainer or Client) and stores tokens securely.
  ///
  /// Parameters:
  ///   - email: The user's email address
  ///   - code: The verification code from the email
  ///
  /// Returns:
  ///   - Trainer or Client model depending on user role
  ///   - Tokens are automatically stored to flutter_secure_storage
  ///
  /// Throws:
  ///   - ServerException: If code is invalid, expired, or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<dynamic> verifyMagicLink({
    required String email,
    required String code,
  });

  /// Get the current authenticated user from the server.
  ///
  /// Retrieves the authenticated user (Trainer or Client) from the backend using
  /// the stored access token. This method is called to check if a user is still
  /// authenticated and to refresh their user data from the server.
  ///
  /// No parameters required - uses the access token stored in flutter_secure_storage.
  ///
  /// Returns:
  ///   - Trainer or Client model depending on user role
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored in flutter_secure_storage
  ///   - ServerException: If token is invalid, expired, or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<dynamic> getCurrentUser();

  /// Bind the current device to the user's authenticated session.
  ///
  /// Called after successful biometric/PIN authentication.
  /// Registers this device with the backend to enable device-bound authentication.
  /// Prevents the same authentication token from being used on different devices.
  ///
  /// Requires an existing access token in flutter_secure_storage.
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored
  ///   - ServerException: If device binding fails or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  ///   - DeviceException: If device ID cannot be retrieved
  Future<void> bindDevice();

  /// Create a payment intent for payment processing.
  ///
  /// Calls the backend to create a Stripe payment intent.
  /// Returns a PaymentIntent model containing the client secret needed
  /// to initialize the Stripe payment sheet on the client side.
  ///
  /// Parameters:
  ///   - amount: Payment amount in cents (e.g., 1000 = $10.00)
  ///   - currency: Currency code (e.g., 'USD')
  ///   - metadata: Optional metadata to attach to the payment intent
  ///
  /// Returns:
  ///   - PaymentIntentModel with client secret and other payment details
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored
  ///   - ServerException: If payment intent creation fails or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<PaymentIntentModel> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, String>? metadata,
  });

  /// Register the device's FCM token for push notifications.
  ///
  /// Sends the Firebase Cloud Messaging token to the backend so that
  /// the server can send push notifications to this device.
  ///
  /// Parameters:
  ///   - fcmToken: The FCM token from Firebase Cloud Messaging
  ///
  /// Throws:
  ///   - CacheException: If no access token is stored
  ///   - ServerException: If token registration fails or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<void> registerFcmToken(String fcmToken);

  /// Register a new trainer account.
  ///
  /// Creates a new trainer account with the provided information.
  /// The backend will generate a unique trainer code (e.g., "TRAINER-ABC123").
  ///
  /// Parameters:
  ///   - email: The trainer's email address
  ///   - firstName: The trainer's first name
  ///   - lastName: The trainer's last name
  ///   - specialty: The trainer's specialization (e.g., "Strength & Conditioning")
  ///   - bio: Optional biography/description
  ///
  /// Returns:
  ///   - TrainerModel with unique code and other trainer details
  ///
  /// Throws:
  ///   - ServerException: If registration fails or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<TrainerModel> registerTrainer({
    required String email,
    required String firstName,
    required String lastName,
    required String specialty,
    String? bio,
  });

  /// Register a new client account.
  ///
  /// Creates a new client account linked to a trainer via trainer code.
  /// Stores client health data for fitness tracking.
  ///
  /// Parameters:
  ///   - email: The client's email address
  ///   - firstName: The client's first name
  ///   - lastName: The client's last name
  ///   - age: The client's age in years
  ///   - weightKg: The client's weight in kilograms
  ///   - heightCm: The client's height in centimeters
  ///   - fitnessLevel: Fitness level (e.g., "beginner", "intermediate", "advanced")
  ///   - trainerCode: The unique trainer code to link to a trainer
  ///
  /// Returns:
  ///   - ClientModel with trainer linking and health data
  ///
  /// Throws:
  ///   - ServerException: If registration fails or server error occurs
  ///   - NetworkException: If network connectivity issues prevent the request
  Future<ClientModel> registerClient({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    required double weightKg,
    required double heightCm,
    required String fitnessLevel,
    required String trainerCode,
  });
}

/// Implementation of [AuthRemoteDataSource].
///
/// Uses Dio HTTP client to communicate with the backend API.
/// Handles secure token storage to flutter_secure_storage.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.dioClient,
    FlutterSecureStorage? secureStorage,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage();

  final DioClient dioClient;
  final FlutterSecureStorage secureStorage;

  @override
  Future<void> sendMagicLink(String email, String userType) async {
    try {
      await dioClient.dio.post(
        '/api/v1/auth/magic-link',
        data: {'email': email, 'user_type': userType},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to send magic link: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<dynamic> verifyMagicLink({
    required String email,
    required String code,
  }) async {
    try {
      print('\n🔍 DEBUG Frontend: verifyMagicLink starting - email=$email, code=$code');

      final response = await dioClient.dio.post(
        '/api/v1/auth/verify-magic-link',
        data: {'email': email, 'code': code},
      );

      print('✅ DEBUG Frontend: POST request successful, status=${response.statusCode}');
      print('📦 DEBUG Frontend: response.data type = ${response.data.runtimeType}');
      print('📦 DEBUG Frontend: response.data = ${response.data}');

      // Parse the response
      try {
        final responseData = response.data as Map<String, dynamic>;
        print('🔍 DEBUG Frontend: Response keys: ${responseData.keys}');

        // Check if response has the standard VerifyMagicLinkResponseModel structure
        if (responseData.containsKey('accessToken') && responseData.containsKey('role')) {
          print('🔍 DEBUG Frontend: Parsing as VerifyMagicLinkResponseModel');
          final responseModel = VerifyMagicLinkResponseModel.fromJson(responseData);
          print('✅ DEBUG Frontend: Response parsed successfully');

          // Store tokens securely
          await secureStorage.write(
            key: 'accessToken',
            value: responseModel.accessToken,
          );
          await secureStorage.write(
            key: 'refreshToken',
            value: responseModel.refreshToken,
          );
          print('✅ DEBUG Frontend: Tokens stored successfully');

          final user = responseModel.parseUser();
          print('✅ DEBUG Frontend: User model parsed: $user');
          return user;
        } else if (responseData.containsKey('user_type')) {
          // Response is just user data (like /api/v1/auth/me format)
          print('🔍 DEBUG Frontend: Parsing as direct user data');
          final userType = responseData['user_type'] as String?;

          if (userType == 'trainer') {
            final trainer = TrainerModel.fromApi(responseData);
            print('✅ DEBUG Frontend: TrainerModel parsed: $trainer');
            return trainer;
          } else if (userType == 'client') {
            final client = ClientModel.fromApi(responseData);
            print('✅ DEBUG Frontend: ClientModel parsed: $client');
            return client;
          }
        }

        throw Exception('Unknown response format');

      } catch (parseError) {
        print('❌ DEBUG Frontend: Error parsing response: ${parseError.runtimeType}: $parseError');
        rethrow;
      }

    } on DioException catch (e) {
      print('❌ DEBUG Frontend: DioException - ${e.message}');
      print('❌ DEBUG Frontend: Status code = ${e.response?.statusCode}');
      print('❌ DEBUG Frontend: Response = ${e.response?.data}');
      throw ServerException(
        message: 'Failed to verify magic link: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    } catch (e) {
      print('❌ DEBUG Frontend: Unexpected exception: ${e.runtimeType}: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getCurrentUser() async {
    try {
      // Retrieve access token from secure storage
      final accessToken = await secureStorage.read(key: 'accessToken');

      // Throw CacheException if no token is stored
      if (accessToken == null || accessToken.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }

      // Make request to /api/v1/auth/me endpoint
      final response = await dioClient.dio.get(
        '/api/v1/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      print('✅ DEBUG Frontend: getCurrentUser response status=${response.statusCode}');
      print('📦 DEBUG Frontend: getCurrentUser response.data type = ${response.data.runtimeType}');
      print('📦 DEBUG Frontend: getCurrentUser response.data = ${response.data}');

      // Parse the response - /api/v1/auth/me returns user data directly
      try {
        final userResponse = response.data as Map<String, dynamic>;
        print('🔍 DEBUG Frontend: Parsing user directly from /api/v1/auth/me response');
        final userType = userResponse['user_type'] as String?;
        print('🔍 DEBUG Frontend: user_type = $userType');

        if (userType == 'trainer') {
          print('🔍 DEBUG Frontend: Parsing as TrainerModel');
          print('🔍 DEBUG Frontend: userResponse keys: ${userResponse.keys}');
          final trainer = TrainerModel.fromApi(userResponse);
          print('✅ DEBUG Frontend: TrainerModel parsed: $trainer');
          return trainer;
        } else if (userType == 'client') {
          print('🔍 DEBUG Frontend: Parsing as ClientModel');
          print('🔍 DEBUG Frontend: userResponse keys: ${userResponse.keys}');
          print('🔍 DEBUG Frontend: userResponse values: ${userResponse.values}');

          final client = ClientModel.fromApi(userResponse);
          print('✅ DEBUG Frontend: ClientModel parsed: $client');
          return client;
        } else {
          throw ArgumentError('Unknown user_type: $userType');
        }

      } catch (parseError) {
        print('❌ DEBUG Frontend: Error parsing user from /api/v1/auth/me: ${parseError.runtimeType}: $parseError');
        rethrow;
      }

    } on CacheException {
      rethrow;
    } on DioException catch (e) {
      print('❌ DEBUG Frontend: DioException in getCurrentUser: ${e.message}');
      throw ServerException(
        message: 'Failed to get current user: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    } catch (e) {
      print('❌ DEBUG Frontend: Unexpected error in getCurrentUser: ${e.runtimeType}: $e');
      rethrow;
    }
  }

  @override
  Future<void> bindDevice() async {
    try {
      // Retrieve access token from secure storage
      final accessToken = await secureStorage.read(key: 'accessToken');

      // Throw CacheException if no token is stored
      if (accessToken == null || accessToken.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }

      // Get device ID
      final deviceService = DeviceService();
      final deviceId = await deviceService.getDeviceId();
      final deviceName = await deviceService.getDeviceName();

      // Send device binding request to backend
      await dioClient.dio.post(
        '/api/v1/auth/bind-device',
        data: {
          'deviceId': deviceId,
          'deviceName': deviceName,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on CacheException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to bind device: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<PaymentIntentModel> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, String>? metadata,
  }) async {
    try {
      // Retrieve access token from secure storage
      final accessToken = await secureStorage.read(key: 'accessToken');

      // Throw CacheException if no token is stored
      if (accessToken == null || accessToken.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }

      // Prepare request body
      final data = {
        'amount': amount,
        'currency': currency,
        if (metadata != null) 'metadata': metadata,
      };

      // Send request to create payment intent
      final response = await dioClient.dio.post(
        '/api/v1/payments/create-intent',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      // Parse and return the payment intent model
      return PaymentIntentModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on CacheException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to create payment intent: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<void> registerFcmToken(String fcmToken) async {
    try {
      // Retrieve access token from secure storage
      final accessToken = await secureStorage.read(key: 'accessToken');

      // Throw CacheException if no token is stored
      if (accessToken == null || accessToken.isEmpty) {
        throw CacheException(
          message: 'No access token stored. User must authenticate first.',
        );
      }

      // Send request to register FCM token
      await dioClient.dio.post(
        '/api/v1/notifications/register-token',
        data: {'fcmToken': fcmToken},
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on CacheException {
      rethrow;
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to register FCM token: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<TrainerModel> registerTrainer({
    required String email,
    required String firstName,
    required String lastName,
    required String specialty,
    String? bio,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/api/v1/auth/registration/trainer',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'specialty': specialty,
          if (bio != null) 'bio': bio,
        },
      );

      return TrainerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to register trainer: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }

  @override
  Future<ClientModel> registerClient({
    required String email,
    required String firstName,
    required String lastName,
    required int age,
    required double weightKg,
    required double heightCm,
    required String fitnessLevel,
    required String trainerCode,
  }) async {
    try {
      final response = await dioClient.dio.post(
        '/api/v1/auth/registration/client',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'age': age,
          'weight_kg': weightKg,
          'height_cm': heightCm,
          'fitness_level': fitnessLevel,
          'trainer_code': trainerCode,
        },
      );

      // Parse response to ClientModel
      final responseData = response.data as Map<String, dynamic>;
      final mappedResponse = {
        'id': responseData['id'],
        'email': responseData['email'],
        'name': '${responseData['first_name'] ?? ''} ${responseData['last_name'] ?? ''}'
            .trim(),
        'trainerId': 0, // Will be populated from trainer_id if available
        'user_type': responseData['user_type'],
      };

      return ClientModel.fromJson(mappedResponse);
    } on DioException catch (e) {
      throw ServerException(
        message: 'Failed to register client: ${e.message}',
        statusCode: e.response?.statusCode,
        responseBody: e.response?.toString(),
      );
    }
  }
}
