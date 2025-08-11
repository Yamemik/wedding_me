import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;

  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Время в правом верхнем углу
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 40, right: 20),
            child: Text(
              '9:41',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
        ),
        // Заголовок экрана
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 40),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
