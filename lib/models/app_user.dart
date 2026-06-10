enum UserRole { customer, admin }

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
    };
  }

  factory AppUser.fromJson(Map<String, Object?> json) {
    final roleName = json['role'] as String?;

    return AppUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.name == roleName,
        orElse: () => UserRole.customer,
      ),
    );
  }
}
