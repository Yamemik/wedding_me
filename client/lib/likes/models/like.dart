import 'package:wedding_me/users/models/user.dart';
import '../../photos/models/photo.dart';


class Like {
  final int id;
  final int userId;
  final int photoId;
  final DateTime? createdAt;
  final User? user;
  final Photo? photo;

  Like({
    required this.id,
    required this.userId,
    required this.photoId,
    this.createdAt,
    this.user,
    this.photo,
  });

  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id: json['id'],
      userId: json['user_id'],
      photoId: json['photo_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'photo_id': photoId,
    };
  }
}
