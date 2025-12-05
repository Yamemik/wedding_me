import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/services/auth_service.dart';
import '../albums/models/album.dart';
import '../models/photo.dart';
import '../models/comment.dart';
import '../models/like.dart';
import '../models/tag.dart';
import '../users/models/user.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  User? _currentUser;
  User? get currentUser => _currentUser;

  /// Асинхронное получение заголовков с токеном
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ================= ALBUMS =================
  Future<List<Album>> getAlbums({int? userId, bool? isPublic}) async {
    final Map<String, String> queryParams = {};
    if (userId != null) queryParams['user_id'] = userId.toString();
    if (isPublic != null) queryParams['visible'] = isPublic.toString();

    final url = Uri.parse('$baseUrl/albums').replace(queryParameters: queryParams);
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Album.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  Future<Album> createAlbum(Album album) async {
    final url = Uri.parse('$baseUrl/albums');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode(album.toJson()),
    );
    if (response.statusCode == 201) {
      return Album.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create album');
    }
  }

  // ================= PHOTOS =================
  Future<List<Photo>> getAlbumPhotos(int albumId) async {
    final url = Uri.parse('$baseUrl/albums/$albumId/photos');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Photo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos');
    }
  }

  Future<Photo> uploadPhoto(int albumId, String filePath) async {
    final url = Uri.parse('$baseUrl/albums/$albumId/photos');
    final request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.headers.addAll(await _getHeaders());

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return Photo.fromJson(json.decode(responseData));
    } else {
      throw Exception('Failed to upload photo');
    }
  }

  // ================= COMMENTS =================
  Future<List<Comment>> getPhotoComments(int photoId) async {
    final url = Uri.parse('$baseUrl/photos/$photoId/comments');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  Future<Comment> addComment(int photoId, String text) async {
    final url = Uri.parse('$baseUrl/photos/$photoId/comments');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: json.encode({'text': text}),
    );
    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }

  // ================= LIKES =================
  Future<Like> likePhoto(int photoId) async {
    final url = Uri.parse('$baseUrl/photos/$photoId/like');
    final response = await http.post(url, headers: await _getHeaders());

    if (response.statusCode == 201) {
      return Like.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to like photo');
    }
  }

  Future<void> unlikePhoto(int photoId) async {
    final url = Uri.parse('$baseUrl/photos/$photoId/like');
    final response = await http.delete(url, headers: await _getHeaders());
    if (response.statusCode != 204) {
      throw Exception('Failed to unlike photo');
    }
  }

  // ================= TAGS =================
  Future<List<Tag>> getTags() async {
    final url = Uri.parse('$baseUrl/tags');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((json) => Tag.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tags');
    }
  }

  Future<void> addTagToPhoto(int photoId, int tagId) async {
    final url = Uri.parse('$baseUrl/photos/$photoId/tags/$tagId');
    final response = await http.post(url, headers: await _getHeaders());
    if (response.statusCode != 201) {
      throw Exception('Failed to add tag');
    }
  }
}
