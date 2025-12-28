import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController patrController;

  @override
  void initState() {
    super.initState();
    final user = AuthService.currentUser!;
    nameController = TextEditingController(text: user.name);
    surnameController = TextEditingController(text: user.surname);
    patrController = TextEditingController(text: user.patr ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field('Имя', nameController),
              const SizedBox(height: 12),
              _field('Фамилия', surnameController),
              const SizedBox(height: 12),
              _field('Отчество', patrController),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Обязательное поле' : null,
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    await AuthService.updateProfile(
      name: nameController.text,
      surname: surnameController.text,
      patr: patrController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён')),
      );
    }
  }
}
