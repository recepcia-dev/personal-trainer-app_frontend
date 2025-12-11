import 'package:equatable/equatable.dart';

class Trainer extends Equatable {
  const Trainer({
    required this.email,
    required this.name,
    this.photoUrl,
  });

  final String email;
  final String name;
  final String? photoUrl;

  @override
  List<Object?> get props => [email, name, photoUrl];
}
