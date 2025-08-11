import 'package:flutter/material.dart';


class OnboardingNavigation extends StatelessWidget {
  final PageController pageController;
  final int currentPage;
  final int pageCount;
  final VoidCallback onSkip;
  final VoidCallback onFinish;

  const OnboardingNavigation({super.key, 
    required this.pageController,
    required this.currentPage,
    required this.pageCount,
    required this.onSkip,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Индикатор прогресса
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pageCount,
            (index) => Container(
              width: 8,
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentPage == index 
                    ? Colors.pink
                    : Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        // Кнопки навигации
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Кнопка "Пропустить" или "Назад"
              if (currentPage == 0)
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Пропустить',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    pageController.previousPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: Text('Назад'),
                ),
              
              // Кнопка "Далее" или "Завершить"
              ElevatedButton(
                onPressed: currentPage == pageCount - 1 
                    ? onFinish
                    : () {
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                child: Text(
                  currentPage == pageCount - 1 
                      ? 'Начать' 
                      : 'Далее',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}