class User {
  final String id;
  final String email;
  final String role;
  final String? fullName;

  User({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    email: json['email'] as String,
    role: json['role'] as String,
    fullName: json['fullName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'fullName': fullName,
  };
}

class AuthResult {
  final String token;
  final User user;

  AuthResult({required this.token, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
    token: json['token'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}
