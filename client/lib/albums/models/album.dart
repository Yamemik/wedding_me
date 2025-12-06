import 'package:wedding_me/users/models/user.dart';

class Album {
  final int id;
  final String title;
  final bool visible;
  final int userId;
  final int photoCount;
  final int videoCount;
  final User? user;

  Album({
    required this.id,
    required this.title,
    required this.visible,
    required this.userId,
    this.photoCount = 0,
    this.videoCount = 0,
    this.user,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'] ?? '',
      visible: json['visible'] ?? true,
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'visible': visible,
      'user_id': userId,
    };
  }
}
