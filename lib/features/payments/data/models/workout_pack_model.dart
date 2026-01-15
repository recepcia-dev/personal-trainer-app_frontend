/// Workout pack model for purchasable premium workouts
class WorkoutPackModel {
  final String id;
  final String name;
  final String description;
  final int priceCents;
  final String currency;
  final int workoutCount;
  final String category;
  final String difficulty;
  final String? previewImageUrl;
  final bool isPurchased;
  final String? trainerName;

  WorkoutPackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.priceCents,
    required this.currency,
    required this.workoutCount,
    required this.category,
    required this.difficulty,
    this.previewImageUrl,
    required this.isPurchased,
    this.trainerName,
  });

  factory WorkoutPackModel.fromJson(Map<String, dynamic> json) {
    return WorkoutPackModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      priceCents: json['price_cents'] as int,
      currency: json['currency'] as String? ?? 'usd',
      workoutCount: json['workout_count'] as int,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      previewImageUrl: json['preview_image_url'] as String?,
      isPurchased: json['is_purchased'] as bool? ?? false,
      trainerName: json['trainer_name'] as String?,
    );
  }

  /// Get formatted price string (e.g., "$9.99")
  String get formattedPrice {
    final dollars = priceCents / 100;
    final symbol = currency.toLowerCase() == 'usd' ? '\$' : currency.toUpperCase();
    return '$symbol${dollars.toStringAsFixed(2)}';
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'strength':
        return '💪 Strength';
      case 'cardio':
        return '🏃 Cardio';
      case 'flexibility':
        return '🧘 Flexibility';
      case 'hiit':
        return '🔥 HIIT';
      case 'yoga':
        return '🧘‍♀️ Yoga';
      default:
        return category;
    }
  }

  /// Get difficulty badge color
  String get difficultyDisplayName {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return '🟢 Beginner';
      case 'intermediate':
        return '🟡 Intermediate';
      case 'advanced':
        return '🔴 Advanced';
      default:
        return difficulty;
    }
  }
}

/// Response for list of workout packs
class WorkoutPackListResponse {
  final List<WorkoutPackModel> items;
  final int total;

  WorkoutPackListResponse({
    required this.items,
    required this.total,
  });

  factory WorkoutPackListResponse.fromJson(Map<String, dynamic> json) {
    return WorkoutPackListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => WorkoutPackModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
    );
  }
}
