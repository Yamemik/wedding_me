import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ---------------------- Обложка + аватар ----------------------
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 40, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text(
                          'Обложка профиля',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar
                Positioned(
                  left: 16,
                  bottom: -50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.pink[100], // вторичный цвет
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            user.name != null && user.name!.isNotEmpty
                                ? user.name![0].toUpperCase()
                                : "?",
                            style: TextStyle(
                                fontSize: 36,
                                color: Colors.red[800], // основной цвет
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[800], // основной цвет
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60),

            // Контент профиля
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Добавить супруга
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.pink[50], // вторичный цвет
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.pink[100]!, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '+ Добавить супруга',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.red[800], // основной цвет
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Личная информация
                  _buildProfileSection(
                    title: 'Личная информация',
                    icon: Icons.person_outline,
                    items: [
                      'Имя: ${user.name}',
                      'Фамилия: ${user.surname}',
                      'Отчество: ${user.patr ?? ""}',
                      'Дата рождения',
                      'Пол',
                      'Город',
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Контакты
                  _buildProfileSection(
                    title: 'Контакты',
                    icon: Icons.phone_android_outlined,
                    items: [
                      'Телефон',
                      'Email: ${user.email}',
                      'Социальные сети',
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red[800], size: 26), // основной цвет
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[800], // основной цвет
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
