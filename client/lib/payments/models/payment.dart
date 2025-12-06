import 'package:wedding_me/users/models/user.dart';

class Payment {
  final int id;
  final DateTime createdAt;
  final String title;
  final int userId;
  final User? user;

  Payment({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.userId,
    this.user,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      title: json['title'],
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'user_id': userId,
    };
  }
}
