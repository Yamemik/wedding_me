import 'package:wedding_me/users/models/user.dart';

class Comment {
  final int id;
  final DateTime createdAt;
  final String text;
  final int userId;
  final int photoId;
  final bool isDeleted;
  final User? user; // Для JOIN запросов

  Comment({
    required this.id,
    required this.createdAt,
    required this.text,
    required this.userId,
    required this.photoId,
    required this.isDeleted,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      text: json['text'],
      userId: json['user_id'],
      photoId: json['photo_id'],
      isDeleted: json['is_deleted'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'photo_id': photoId,
    };
  }
}