import 'package:wedding_me/photos/models/photo.dart';
import 'package:wedding_me/tags/models/tag.dart';

class PhotoTag {
  final int id;
  final int photoId;
  final int tagId;
  final Photo? photo;
  final Tag? tag;

  PhotoTag({
    required this.id,
    required this.photoId,
    required this.tagId,
    this.photo,
    this.tag,
  });

  factory PhotoTag.fromJson(Map<String, dynamic> json) {
    return PhotoTag(
      id: json['id'],
      photoId: json['photo_id'],
      tagId: json['tag_id'],
      photo: json['photo'] != null ? Photo.fromJson(json['photo']) : null,
      tag: json['tag'] != null ? Tag.fromJson(json['tag']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photo_id': photoId,
      'tag_id': tagId,
    };
  }
}
