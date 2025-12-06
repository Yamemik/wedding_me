import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/services/auth_service.dart';
import 'home/screens/home_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';
import 'albums/screens/create_album_screen.dart';

import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация токена и загрузка текущего пользователя
  await AuthService.init();

  final sharedPrefs = await SharedPreferences.getInstance();

  // Показывать онбординг только при первом запуске
  final bool showOnboarding = sharedPrefs.getBool('first_run') ?? true;

  // Проверка авторизации
  final bool isLoggedIn = await AuthService.isLoggedIn();

  // Создаем Dio
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8000/api/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // Если токен есть – прикрепляем
  final token = await AuthService.getToken();
  if (token != null) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  runApp(
    MultiProvider(
      providers: [
        // Используем ChangeNotifierProvider вместо обычного Provider
        ChangeNotifierProvider<ApiService>(
          create: (_) => ApiService(dio),
        ),
      ],
      child: MyApp(
        showOnboarding: showOnboarding,
        isLoggedIn: isLoggedIn,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.showOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeddingMe',
      debugShowCheckedModeBanner: false,

      // Логика выбора стартового экрана
      initialRoute: showOnboarding
          ? '/onboarding'
          : isLoggedIn
              ? '/home'
              : '/login',

      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
        '/home': (_) => const HomeScreen(),
        '/create-album': (_) => const CreateAlbumScreen(),
      },
    );
  }
}
