import 'package:flutter/material.dart';

class OnboardingHeader extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingHeader({super.key, 
    required this.currentPage,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Счетчик страниц
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 40),
          child: Text(
            '${currentPage + 1}/$pageCount',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
        // Время
        Padding(
          padding: const EdgeInsets.only(right: 20, top: 40),
          child: Text(
            '9:41',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}