import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_page.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/onboarding_navigation.dart';
import '../widgets/onboarding_header.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Страницы onboarding
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return OnboardingPageWidget(page: onboardingPages[index]);
            },
          ),
          
          // Верхняя часть с временем и счетчиком
          OnboardingHeader(
            currentPage: _currentPage,
            pageCount: onboardingPages.length,
          ),
          
          // Навигация внизу
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: OnboardingNavigation(
              pageController: _pageController,
              currentPage: _currentPage,
              pageCount: onboardingPages.length,
              onSkip: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
              onFinish: () async {
                final sharedPrefs = await SharedPreferences.getInstance();
                await sharedPrefs.setBool('first_run', false);
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
