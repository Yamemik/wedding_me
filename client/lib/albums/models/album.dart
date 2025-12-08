import 'package:wedding_me/users/models/user.dart';

import '../../photos/models/photo.dart';


class Album {
  final int id;
  final String title;
  final bool visible;
  final int userId;
  final List<Photo> photos;
  final User? user;

  Album({
    required this.id,
    required this.title,
    required this.visible,
    required this.userId,
    this.photos = const [],
    this.user,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'] ?? '',
      visible: json['visible'] ?? true,
      userId: json['user_id'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,

      /// ВАЖНО:
      /// Photo.fromJson НЕ должен тянуть Album обратно, иначе рекурсия.
      photos: json['photos'] != null
          ? (json['photos'] as List)
              .map((p) => Photo.fromJson(p))
              .toList()
          : [],
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
