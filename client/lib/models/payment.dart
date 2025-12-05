class Payment {
  final int id;
  final DateTime createdAt;
  final String title;
  final int userId;

  Payment({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.userId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
      userId: json['user_id'],
    );
  }
}