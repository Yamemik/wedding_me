class User {
  final int id;
  final String email;
  final String surname;
  final String name;
  final String patr;
  final bool isAdmin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.surname,
    required this.name,
    required this.patr,
    required this.isAdmin,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      surname: json['surname'],
      name: json['name'],
      patr: json['patr'],
      isAdmin: json['is_admin'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
