/// Domain entity for Client
///
/// Pure data holder - equality is handled by data layer (Freezed models)
class Client {
  const Client({
    required this.email,
    required this.name,
    required this.trainerId,
  });

  final String email;
  final String name;
  final int trainerId;
}
