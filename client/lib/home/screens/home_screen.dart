import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/popular_stories_section.dart';
import '../widgets/search_section.dart';
import '../widgets/bottom_nav_bar.dart';

import '../../services/api_service.dart';
import '../../albums/models/album.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  List<Album> myAlbums = [];
  String? error;

  @override
  void initState() {
    super.initState();
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    try {
      final api = context.read<ApiService>();
      final albums = await api.getMyAlbums();

      setState(() {
        myAlbums = albums;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = "Ошибка загрузки альбомов: $e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),

            Expanded(
              child: RefreshIndicator(
                onRefresh: loadAlbums,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SearchSection(),
                      const PopularStoriesSection(),

                      // Мои альбомы
                      _buildMyAlbumsSection(),

                      // общие альбомы
                      _buildSharedAlbumsSection(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create-album');
        },
        child: const Icon(Icons.add, size: 30),
        backgroundColor: Colors.pink,
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  // ---------------- APP BAR ----------------
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
          const Text(
            'WeddingMe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28),
                onPressed: () {},
                color: Colors.grey[700],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------ МОИ АЛЬБОМЫ ------------------
  Widget _buildMyAlbumsSection() {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (myAlbums.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "У вас пока нет альбомов",
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Мои альбомы",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myAlbums.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (_, i) {
              final album = myAlbums[i];
              final preview = album.photos.isNotEmpty
                  ? "http://10.0.2.2:8000${album.photos.first.path}"
                  : null;

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, "/album/${album.id}");
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: preview != null
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  preview,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: const Icon(Icons.photo_album,
                                    size: 40, color: Colors.grey),
                              ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                        child: Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  // ------------------ ОБЩИЕ АЛЬБОМЫ ------------------
  Widget _buildSharedAlbumsSection(BuildContext context) {
    final sharedAlbums = [
      {'title': 'Свадьба Анны и Игоря', 'photos': 24, 'videos': 3},
      {'title': 'Юбилей родителей', 'photos': 18, 'videos': 2},
      {'title': 'Выпускной вечер', 'photos': 32, 'videos': 4},
    ];

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
          ...sharedAlbums.map((album) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(album['title'] as String),
                subtitle: Text(
                    '${album['photos']} фото • ${album['videos']} видео'),
                onTap: () {},
              ),
            );
          })
        ],
      ),
    );
  }
}
