import 'package:wedding_me/users/models/user.dart';
import '../../photos/models/photo.dart';


class Comment {
  final int id;
  final String text;
  final bool isDeleted;
  final int userId;
  final int photoId;
  final DateTime? createdAt;
  final User? user;
  final Photo? photo;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.photoId,
    this.isDeleted = false,
    this.createdAt,
    this.user,
    this.photo,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      text: json['text'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      userId: json['user_id'],
      photoId: json['photo_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'user_id': userId,
      'photo_id': photoId,
      'is_deleted': isDeleted,
    };
  }
}
