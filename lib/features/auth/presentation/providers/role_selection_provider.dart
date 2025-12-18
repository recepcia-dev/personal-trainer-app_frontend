import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to store the user's selected role (trainer or client)
/// Used before authentication to determine which dashboard to show
final roleSelectionProvider = StateProvider<String?>((ref) => null);
