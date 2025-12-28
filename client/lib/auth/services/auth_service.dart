import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../users/models/user.dart';
import '../models/auth_model.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1/users',
      connectTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static User? currentUser;

  // Инициализация токена при старте приложения
  static Future<void> init() async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      try {
        await getCurrentUser();
        if (currentUser == null) {
          // Токен недействителен, удаляем его
          await clearToken();
        }
      } catch (_) {
        await clearToken();
      }
    }
  }

  // Получить токен для ApiService
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Логин
  static Future<User> login(LoginData data) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'username': data.email, // email пользователя
          'password': data.password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final map = response.data as Map<String, dynamic>;
      final token = map['access_token'];
      if (token == null) throw Exception("Сервер не вернул токен!");

      await _storage.write(key: 'access_token', value: token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      await getCurrentUser();

      if (currentUser == null) {
        throw Exception("Не удалось получить данные пользователя");
      }

      return currentUser!;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Ошибка входа');
    }
  }

  // Регистрация
  static Future<User> register(RegisterData data) async {
    try {
      final response = await _dio.post('/register', data: data.toJson());

      final map = Map<String, dynamic>.from(response.data);

      final token = map['access_token'];
      if (token == null) throw Exception("Сервер не вернул токен!");

      debugPrint("TOKEN FROM REGISTER => $token");

      await _storage.write(key: 'access_token', value: token);
      _dio.options.headers['Authorization'] = 'Bearer $token';

      await getCurrentUser();

      if (currentUser == null) {
        debugPrint("ERROR: currentUser всё ещё null!");
        throw Exception("Не удалось получить данные пользователя");
      }

      return currentUser!;
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Ошибка регистрации');
    }
  }

  // Сброс пароля
  static Future<void> resetPassword(ResetPasswordData data) async {
    try {
      await _dio.post('/reset-password', data: data.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data ?? 'Ошибка сброса пароля');
    }
  }

  /// Выход
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    _dio.options.headers.remove('Authorization');
    currentUser = null;
  }

  /// Проверка авторизации
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  /// Получение текущего пользователя
  static Future<void> getCurrentUser() async {
    try {
      debugPrint("REQUESTING /me with headers => ${_dio.options.headers}");

      final response = await _dio.get('/me');

      debugPrint("RAW /me => ${response.data}");

      if (response.data == null) {
        debugPrint("ME RETURNED NULL");
        currentUser = null;
        return;
      }

      final map = Map<String, dynamic>.from(response.data);

      currentUser = User.fromJson(map);
      debugPrint("PARSED USER => $currentUser");
    } catch (e) {
      debugPrint("PARSE ERROR => $e");
      currentUser = null;
    }
  }

  static Future<void> updateProfile({
    required String name,
    required String surname,
    required String patr,
  }) async {
    final res = await _dio.put(
      '/me',
      data: {'name': name, 'surname': surname, 'patr': patr},
    );

    currentUser = User.fromJson(res.data);
  }

  /// Очистить токен
  static Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
    _dio.options.headers.remove('Authorization');
    currentUser = null;
  }
}
