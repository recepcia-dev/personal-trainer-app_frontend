/// Domain entity for Client
///
/// Pure data holder - equality is handled by data layer (Freezed models)
class Client {
  const Client({
    required this.email,
    required this.name,
    this.trainerId,  // Optional - may not be assigned yet
  });

  final String email;
  final String name;
  final String? trainerId;  // Changed to String to match backend UUID
}
