import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store the pending email waiting for magic link verification
/// Persists across app rebuilds unlike instance variables
final pendingEmailProvider = StateProvider<String>((ref) => '');
