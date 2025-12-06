import '../../albums/models/album.dart';
import '../../comments/models/comment.dart';
import '../../likes/models/like.dart';
import '../../tags/models/tag.dart';


class Photo {
  final int id;
  final String path;
  final String? title;
  final String? name;
  final bool visible;
  final int albumId;
  final DateTime? createdAt;
  final Album? album;
  final List<Tag>? tags;
  final List<Comment>? comments;
  final List<Like>? likes;

  Photo({
    required this.id,
    required this.path,
    this.title,
    this.name,
    this.visible = true,
    required this.albumId,
    this.createdAt,
    this.album,
    this.tags,
    this.comments,
    this.likes,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      id: json['id'],
      path: json['path'] ?? '',
      title: json['title'],
      name: json['name'],
      visible: json['visible'] ?? true,
      albumId: json['album_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      album: json['album'] != null ? Album.fromJson(json['album']) : null,
      tags: json['tags'] != null ? (json['tags'] as List).map((e) => Tag.fromJson(e)).toList() : null,
      comments: json['comments'] != null ? (json['comments'] as List).map((e) => Comment.fromJson(e)).toList() : null,
      likes: json['likes'] != null ? (json['likes'] as List).map((e) => Like.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'name': name,
      'visible': visible,
      'album_id': albumId,
    };
  }
}
