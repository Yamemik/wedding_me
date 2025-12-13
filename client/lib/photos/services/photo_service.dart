import 'package:dio/dio.dart';
import '../models/photo.dart';
import '../models/photo_tag.dart';

class PhotoService {
  final Dio _dio;

  PhotoService(this._dio);

  // Все фото альбома
  Future<List<Photo>> getPhotosByAlbum(int albumId) async {
    final response = await _dio.get("/albums/$albumId/photos");
    return (response.data as List).map((e) => Photo.fromJson(e)).toList();
  }

  // Конкретное фото
  Future<Photo> getPhoto(int id) async {
    final response = await _dio.get("/photos/$id");
    return Photo.fromJson(response.data);
  }

  // Загрузка фото
  Future<Photo> uploadPhoto({
    required int albumId,
    required String filePath,
    String? title,
    bool visible = true,
  }) async {
    final formData = FormData.fromMap({
      "album_id": albumId,
      "title": title,
      "visible": visible,
      "file": await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post("/photos", data: formData);
    return Photo.fromJson(response.data);
  }

  // Лайкнуть
  Future<void> likePhoto(int id) async {
    await _dio.post("/photos/$id/like");
  }

  // Удалить лайк
  Future<void> unlikePhoto(int id) async {
    await _dio.delete("/photos/$id/like");
  }

  // Добавить тег
  Future<PhotoTag> addTag(int photoId, int tagId) async {
    final response = await _dio.post("/photo-tags", data: {
      "photo_id": photoId,
      "tag_id": tagId,
    });
    return PhotoTag.fromJson(response.data);
  }

  // Удалить тег
  Future<void> removeTag(int photoTagId) async {
    await _dio.delete("/photo-tags/$photoTagId");
  }
}
