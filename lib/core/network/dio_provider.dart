import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dio_client.dart';

/// Provider for Dio HTTP client instance
///
/// This provider gives access to the configured Dio instance
/// that includes authentication interceptors and logging
final dioProvider = Provider<Dio>((ref) {
  return DioClient().dio;
});
