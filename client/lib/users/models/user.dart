class User {
  final int id;
  final String email;
  final String? name;
  final String? surname;
  final String? patr;
  final bool isAdmin;
  final DateTime? createdAt;
  final String? accessToken;

  User({
    required this.id,
    required this.email,
    this.name,
    this.surname,
    this.patr,
    this.isAdmin = false,
    this.createdAt,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'] ?? '',
      name: json['name'],
      surname: json['surname'],
      patr: json['patr'],
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'surname': surname,
      'patr': patr,
      'is_admin': isAdmin,
    };
  }
}
