import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../albums/models/album.dart';
import '../photos/models/photo.dart';
import '../comments/models/comment.dart';
import '../tags/models/tag.dart';
import '../users/models/user.dart';


class ApiService extends ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';
  final Dio _dio;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _token;
  String? get token => _token;

  ApiService(this._dio) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers['Content-Type'] = 'application/json';

    // _dio.options.followRedirects = true;
    // _dio.options.maxRedirects = 5;
    // _dio.options.validateStatus = (status) => status! < 500;
    _init();
  }

  Future<void> _init() async {
    _token = await AuthService.getToken();
    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
      await getCurrentUser();
    }
  }

  Map<String, String> _defaultHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }

  /// ================= USER =================
  Future<User?> getCurrentUser() async {
    try {
      final response = await _dio.get(
        '/users/me',
        options: Options(headers: _defaultHeaders()),
      );
      _currentUser = User.fromJson(response.data);
      notifyListeners();
      return _currentUser;
    } on DioException catch (e) {
      debugPrint('Failed to fetch current user: ${e.response?.data}');
      _currentUser = null;
      notifyListeners();
      return null;
    }
  }

  /// ================= ALBUMS =================
  Future<List<Album>> getMyAlbums() async {
    try {
      final user = AuthService.currentUser!;
      final userId = user.id;

      final response = await _dio.get(
        "/albums/user/$userId/albums",
        options: Options(headers: _defaultHeaders()),
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Album.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print("Ошибка при получении альбомов: $e");
      return [];
    }
  }

  Future<List<Album>> getPublicAlbums() async {
    try {
      final response = await _dio.get(
        "/albums",
        options: Options(headers: _defaultHeaders()),
      );

      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((json) => Album.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print("Ошибка при получении публичных альбомов: $e");
      return [];
    }
  }

  Future<Album> createAlbum(Album album) async {
    try {
      final response = await _dio.post(
        '/albums/',
        data: album.toJson(),
        options: Options(headers: _defaultHeaders()),
      );
      return Album.fromJson(response.data);
    } on DioException catch (e) {
      print("Ошибка при создании альбома: $e");
      rethrow;
    }
  }

  Future<Album> getAlbum(int albumId) async {
    try {
      final response = await _dio.get('/albums/$albumId');
      return Album.fromJson(response.data);
    } on DioException catch (e) {
      print("Ошибка при получении альбома: $e");
      rethrow;
    }
  }

  Future<List<Album>> searchAlbums(String query) async {
    final res = await _dio.get(
      '/albums/search',
      queryParameters: {'q': query},
    );

    return (res.data as List).map((e) => Album.fromJson(e)).toList();
  }

  Future<void> uploadAlbumFiles(
    int albumId,
    FormData formData, {
    Function(int, int)? onSendProgress,
  }) async {
    try {
      await _dio.post(
        '/albums/$albumId/files/',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      print("Ошибка при загрузке файлов в альбом: $e");
      rethrow;
    }
  }

  Future<void> deleteAlbum(int albumId) async {
    try {
      final response = await _dio.delete(
        '/albums/$albumId',
        options: Options(headers: _defaultHeaders()),
      );
      print('Альбом успешно удалено: ${response.data}');
    } catch (e) {
      print('Ошибка при удалении альбома: $e');
    }
  }

  /// ================= PHOTOS =================
  Future<List<Photo>> getAlbumPhotos(int albumId) async {
    try {
      final response = await _dio.get(
        '/albums/$albumId/photos',
        options: Options(headers: _defaultHeaders()),
      );
      final data = response.data;
      if (data is List)
        return data.map((json) => Photo.fromJson(json)).toList();
      return [];
    } on DioException catch (e) {
      print("Ошибка при получении фотографий альбома: $e");
      return [];
    }
  }

  Future<void> uploadPhoto(
    int albumId,
    File file, {
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        "album_id": albumId,
        "file": await MultipartFile.fromFile(
          file.path,
          filename: file.path.split("/").last,
        ),
      });

      await _dio.post(
        "/photos/upload",
        data: formData,
        options: Options(
          headers: {
            "Authorization": _dio.options.headers["Authorization"] ?? "",
            "Content-Type": "multipart/form-data",
          },
        ),
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      print("Ошибка при загрузке фотографии: $e");
      rethrow;
    }
  }

  Future<Photo> getPhoto(int id) async {
    try {
      final res = await _dio.get(
        "/photos/$id",
        options: Options(headers: _defaultHeaders()),
      );
      return Photo.fromJson(res.data);
    } on DioException catch (e) {
      print("Ошибка при получении фотографии: $e");
      rethrow;
    }
  }

  Future<void> deletePhoto(int photoId) async {
    try {
      final response = await _dio.delete(
        '/photos/$photoId', // Путь для удаления фотографии
        options: Options(headers: _defaultHeaders()),
      );
      print('Фото успешно удалено: ${response.data}');
    } catch (e) {
      print('Ошибка при удалении фото: $e');
    }
  }

  /// ================= COMMENTS =================
  Future<List<Comment>> getPhotoComments(int photoId) async {
    try {
      final response = await _dio.get(
        '/photos/$photoId/comments',
        options: Options(headers: _defaultHeaders()),
      );
      final data = response.data;
      if (data is List) {
        return data.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      print("Ошибка при получении комментариев: $e");
      return [];
    }
  }

  Future<void> createComment(int photoId, String text) async {
    try {
      await _dio.post(
        "/comments/",
        data: {"photo_id": photoId, "text": text, "user_id": _currentUser!.id},
        options: Options(headers: _defaultHeaders()),
      );
    } on DioException catch (e) {
      print("Ошибка при добавлении комментария: $e");
      rethrow;
    }
  }

  /// ================= LIKES =================
  Future<void> unlikePhoto(int photoId) async {
    try {
      await _dio.delete(
        '/photos/$photoId/like',
        options: Options(headers: _defaultHeaders()),
      );
    } on DioException catch (e) {
      print("Ошибка при удалении лайка: $e");
      rethrow;
    }
  }

  Future<void> toggleLike(int photoId) async {
    try {
      await _dio.post(
        "/likes/",
        data: {"photo_id": photoId, "user_id": _currentUser!.id},
        options: Options(headers: _defaultHeaders()),
      );
    } on DioException catch (e) {
      print("Ошибка при переключении лайка: $e");
      rethrow;
    }
  }

  /// ================= TAGS =================
  Future<List<Tag>> getTags() async {
    try {
      final response = await _dio.get(
        '/tags',
        options: Options(headers: _defaultHeaders()),
      );
      final data = response.data;
      if (data is List) return data.map((json) => Tag.fromJson(json)).toList();
      return [];
    } on DioException catch (e) {
      print("Ошибка при получении тегов: $e");
      return [];
    }
  }

  Future<void> addTagToPhoto(int photoId, int tagId) async {
    try {
      await _dio.post(
        '/photos/$photoId/tags/$tagId',
        options: Options(headers: _defaultHeaders()),
      );
    } on DioException catch (e) {
      print("Ошибка при добавлении тега к фотографии: $e");
      rethrow;
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    await AuthService.clearToken();
    _dio.options.headers.remove('Authorization');
    notifyListeners();
  }
}
