import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://your-backend.com/api',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Добавляем токен в заголовки
  static Future<void> init() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  static Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final token = response.data['access_token'];
      await _storage.write(key: 'access_token', value: token);
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Ошибка входа');
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    _dio.options.headers.remove('Authorization');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}
