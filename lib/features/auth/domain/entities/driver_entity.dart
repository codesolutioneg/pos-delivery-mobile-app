import 'package:equatable/equatable.dart';

/// Authenticated driver session entity (pure Dart).
class DriverEntity extends Equatable {
  const DriverEntity({
    required this.id,
    required this.name,
    required this.username,
    this.branchId,
    this.phone,
  });

  final String id;
  final String name;
  final String username;
  final String? branchId;
  final String? phone;

  @override
  List<Object?> get props => [id, name, username, branchId, phone];
}
