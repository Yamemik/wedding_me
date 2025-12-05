import 'package:wedding_me/models/comment.dart';
import 'package:wedding_me/models/tag.dart';

class Photo {
  final int id;
  final DateTime createdAt;
  final String? title;
  final String? name;
  final String path;
  final bool visible;
  final int albumId;
  final int? likesCount;
  final int? commentsCount;
  final List<Tag>? tags;
  final bool? isLiked; // Для текущего пользователя
  final List<Comment>? comments; // Для детального просмотра

  Photo({
    required this.id,
    required this.createdAt,
    this.title,
    this.name,
    required this.path,
    required this.visible,
    required this.albumId,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.tags,
    this.isLiked = false,
    this.comments,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
      name: json['name'],
      path: json['path'],
      visible: json['visible'] ?? true,
      albumId: json['album_id'],
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      tags: json['tags'] != null 
          ? (json['tags'] as List).map((t) => Tag.fromJson(t)).toList()
          : null,
      isLiked: json['is_liked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'name': name,
      'path': path,
      'visible': visible,
      'album_id': albumId,
    };
  }

  String get displayName => title ?? name ?? 'Без названия';
  bool get isVideo => path.toLowerCase().endsWith('.mp4') || 
                      path.toLowerCase().endsWith('.mov') ||
                      path.toLowerCase().endsWith('.avi');
}
