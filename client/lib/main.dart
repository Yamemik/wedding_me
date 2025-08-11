import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/screens/login_screen.dart';
import 'auth/screens/register_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/services/auth_service.dart';
import 'home/screens/home_screen.dart';
import 'onboarding/screens/onboarding_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init secure storage and auth
  await AuthService.init();

  final sharedPrefs = await SharedPreferences.getInstance();
  //final bool showOnboarding = sharedPrefs.getBool('first_run') ?? true;
  final bool showOnboarding = true;

  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(
    showOnboarding: showOnboarding,
    isLoggedIn: isLoggedIn,
  ));
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
      initialRoute: showOnboarding
          ? '/onboarding'
          : isLoggedIn
              ? '/home'
              : '/login',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/reset-password': (context) => ResetPasswordScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
