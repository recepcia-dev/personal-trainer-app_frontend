/// Domain entity for Trainer
///
/// Pure data holder - equality is handled by data layer (Freezed models)
class Trainer {
  const Trainer({
    required this.email,
    required this.name,
    this.photoUrl,
  });

  final String email;
  final String name;
  final String? photoUrl;
}
