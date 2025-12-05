import 'package:flutter/material.dart';
import '../widgets/popular_stories_section.dart';
import '../widgets/album_grid_section.dart';
import '../widgets/search_section.dart';
import '../widgets/bottom_nav_bar.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Аппбар с заголовком
            _buildAppBar(context),
            
            // Основной контент
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Поиск
                    const SearchSection(),
                    
                    // Популярные истории
                    const PopularStoriesSection(),
                    
                    // Мои альбомы
                    AlbumGridSection(
                      title: 'Мои альбомы',
                      albums: const [
                        'Альбом №1',
                        'Альбом №2',
                        'Альбом №3',
                        'Альбом №4',
                      ],
                    ),
                    
                    // Общие альбомы
                    _buildSharedAlbumsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Плавающая кнопка создания альбома
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-album');
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Colors.pink,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Нижняя навигационная панель
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  // Аппбар
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Логотип или заголовок
          const Text(
            'WeddingMe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          
          // Иконки в правой части
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: () {},
                color: Colors.grey[700],
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, size: 28),
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                color: Colors.grey[700],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Секция общих альбомов
  Widget _buildSharedAlbumsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Общие альбомы',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildSharedAlbumList(context),
        ],
      ),
    );
  }

  List<Widget> _buildSharedAlbumList(BuildContext context) {
    final sharedAlbums = [
      {'title': 'Свадьба Анны и Игоря', 'photos': 24, 'videos': 3},
      {'title': 'Юбилей родителей', 'photos': 18, 'videos': 2},
      {'title': 'Выпускной вечер', 'photos': 32, 'videos': 4},
    ];

    return sharedAlbums.map((album) {
      return Card(
        elevation: 1,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.pink[50],
            ),
            child: const Icon(Icons.photo_library, color: Colors.pink),
          ),
          title: Text(
            album['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${album['photos']} фото • ${album['videos']} видео',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.pink[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.pink,
            ),
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/album/:id',
              arguments: album['title'].toString().toLowerCase().replaceAll(' ', '_'),
            );
          },
        ),
      );
    }).toList();
  }
}