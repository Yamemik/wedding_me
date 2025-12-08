import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import '../albums/models/album.dart';
import '../photos/models/photo.dart';
import '../comments/models/comment.dart';
import '../likes/models/like.dart';
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
  Future<List<Album>> getAlbums({int? userId, bool? isPublic}) async {
    final queryParams = <String, dynamic>{};
    if (userId != null) queryParams["user_id"] = userId;
    if (isPublic != null) queryParams["visible"] = isPublic;

    final response = await _dio.get(
      "/albums",
      queryParameters: queryParams,
      options: Options(headers: _defaultHeaders()),
    );

    if (response.data is List) {
      return (response.data as List)
          .map((json) => Album.fromJson(json))
          .toList();
    }

    return [];
  }

  Future<Album> createAlbum(Album album) async {
    final response = await _dio.post(
      '/albums/',
      data: album.toJson(),
      options: Options(headers: _defaultHeaders()),
    );
    return Album.fromJson(response.data);
  }

  Future<Album> getAlbum(int albumId) async {
    final response = await _dio.get('/albums/$albumId');
    return Album.fromJson(response.data);
  }

  Future<void> uploadAlbumFiles(
    int albumId,
    FormData formData, {
    Function(int, int)? onSendProgress,
  }) async {
    await _dio.post(
      '/albums/$albumId/files/',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      onSendProgress: onSendProgress,
    );
  }

  /// ================= PHOTOS =================
  Future<List<Photo>> getAlbumPhotos(int albumId) async {
    final response = await _dio.get(
      '/albums/$albumId/photos',
      options: Options(headers: _defaultHeaders()),
    );
    final data = response.data;
    if (data is List) return data.map((json) => Photo.fromJson(json)).toList();
    return [];
  }

  Future<void> uploadPhoto(
    int albumId,
    File file, {
    Function(int sent, int total)? onSendProgress,
  }) async {
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
  }

  /// ================= COMMENTS =================
  Future<List<Comment>> getPhotoComments(int photoId) async {
    final response = await _dio.get(
      '/photos/$photoId/comments',
      options: Options(headers: _defaultHeaders()),
    );
    final data = response.data;
    if (data is List) {
      return data.map((json) => Comment.fromJson(json)).toList();
    }
    return [];
  }

  Future<Comment> addComment(int photoId, String text) async {
    final response = await _dio.post(
      '/photos/$photoId/comments',
      data: {'text': text},
      options: Options(headers: _defaultHeaders()),
    );
    return Comment.fromJson(response.data);
  }

  /// ================= LIKES =================
  Future<Like> likePhoto(int photoId) async {
    final response = await _dio.post(
      '/photos/$photoId/like',
      options: Options(headers: _defaultHeaders()),
    );
    return Like.fromJson(response.data);
  }

  Future<void> unlikePhoto(int photoId) async {
    await _dio.delete(
      '/photos/$photoId/like',
      options: Options(headers: _defaultHeaders()),
    );
  }

  /// ================= TAGS =================
  Future<List<Tag>> getTags() async {
    final response = await _dio.get(
      '/tags',
      options: Options(headers: _defaultHeaders()),
    );
    final data = response.data;
    if (data is List) return data.map((json) => Tag.fromJson(json)).toList();
    return [];
  }

  Future<void> addTagToPhoto(int photoId, int tagId) async {
    await _dio.post(
      '/photos/$photoId/tags/$tagId',
      options: Options(headers: _defaultHeaders()),
    );
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
