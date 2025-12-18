/// Domain entity for Admin
///
/// Pure data holder - equality is handled by data layer (Freezed models)
class Admin {
  const Admin({
    required this.email,
    required this.name,
  });

  final String email;
  final String name;
}
