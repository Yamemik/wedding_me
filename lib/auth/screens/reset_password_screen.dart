import 'package:flutter/material.dart';

import '../widgets/auth_header.dart';
import '../widgets/auth_form_field.dart';
import '../widgets/auth_alternative_action.dart';
import '../models/auth_model.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const AuthHeader(title: 'Восстановление пароля'),

              const SizedBox(height: 16),

              AuthFormField(
                label: 'Электронная почта',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Введите корректный email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('СБРОСИТЬ ПАРОЛЬ'),
                ),
              ),

              const SizedBox(height: 20),

              AuthAlternativeAction(
                text: 'Вспомнили пароль?',
                actionText: 'Войдите в аккаунт',
                onAction: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final resetData = ResetPasswordData(
        email: _emailController.text.trim(),
      );

      // TODO: Добавь вызов API или Firebase reset password
      print('Запрос на восстановление пароля: ${resetData.email}');
      Navigator.pop(context); // Вернуться назад
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
