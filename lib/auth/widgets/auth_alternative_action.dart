import 'package:flutter/material.dart';

class AuthAlternativeAction extends StatelessWidget {
  final String text;
  final String actionText;
  final VoidCallback onAction;

  const AuthAlternativeAction({
    required this.text,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text('ИЛИ', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionText,
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
