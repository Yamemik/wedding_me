import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/services/auth_service.dart';
import 'home/screens/home_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';
import './albums/screens/create_album_screen.dart';

import './services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация токенов (secure storage)
  await AuthService.init();

  final sharedPrefs = await SharedPreferences.getInstance();

  // Показывать онбординг (пока true, чтобы тестировать)
  final bool showOnboarding = sharedPrefs.getBool('first_run') ?? true;

  // Проверка авторизации
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        // 💡 Используем обычный Provider, если ApiService не наследует ChangeNotifier
        Provider(create: (_) => ApiService()),
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

      /// 💡 Логика выбора стартового экрана
      initialRoute: showOnboarding
          ? '/onboarding'
          : isLoggedIn
              ? '/home'
              : '/login',

      routes: {
        '/onboarding': (_) => OnboardingScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/reset-password': (_) => ResetPasswordScreen(),
        '/home': (_) => HomeScreen(),

        // Экран создания альбома
        '/create-album': (_) => CreateAlbumScreen(),

        // TODO:
        // '/profile': (_) => ProfileScreen(),
        // '/album': (_) => AlbumDetailScreen(), // сделаю, если скажешь формат
        // '/media': (_) => MediaViewerScreen(),
      },
    );
  }
}
