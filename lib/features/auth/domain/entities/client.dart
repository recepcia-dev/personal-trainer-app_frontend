import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.email,
    required this.name,
    required this.trainerId,
  });

  final String email;
  final String name;
  final int trainerId;

  @override
  List<Object> get props => [email, name, trainerId];
}
