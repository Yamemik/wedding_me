class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

final List<OnboardingPage> onboardingPages = [
  OnboardingPage(
    title: "Надежное свадебное хранилище",
    description: "Сохраняйте самые трогательные моменты вашей свадьбы в одном месте.",
    imagePath: "assets/images/onboarding3.png",
  ),
  OnboardingPage(
    title: "Делитесь счастьем с близкими!",
    description: "Легко отправляйте свадебные материалы гостям и друзьям. Пусть каждый сохранит частичку вашего праздника.",
    imagePath: "assets/images/onboarding3.png",
  ),
  OnboardingPage(
    title: "Навсегда в воспоминаниях",
    description: "Ваши свадебные моменты останутся с вами навсегда. Просто, удобно и безопасно.",
    imagePath: "assets/images/onboarding3.png",
  ),
];