import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../models/album.dart';

class AllAlbumsScreen extends StatefulWidget {
  const AllAlbumsScreen({super.key});

  @override
  State<AllAlbumsScreen> createState() => _AllAlbumsScreenState();
}

class _AllAlbumsScreenState extends State<AllAlbumsScreen> {
  bool loading = true;
  List<Album> albums = [];

  @override
  void initState() {
    super.initState();
    loadAlbums();
  }

  Future<void> loadAlbums() async {
    setState(() => loading = true);
    final api = context.read<ApiService>();
    final data = await api.getMyAlbums();
    setState(() {
      albums = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои альбомы')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : albums.isEmpty
              ? const Center(child: Text('У вас ещё нет альбомов'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: albums.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, i) {
                    final album = albums[i];
                    final cover = album.photos.isNotEmpty
                        ? "http://10.0.2.2:8000${album.photos.first.path}"
                        : null;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/album/${album.id}');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[200],
                          image: cover != null
                              ? DecorationImage(image: NetworkImage(cover), fit: BoxFit.cover)
                              : null,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.bottomLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          child: Text(
                            album.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        heroTag: "add_album_all_albums",
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, size: 30),
        onPressed: () async {
          // Переходим на экран создания альбома
          final newAlbum = await Navigator.pushNamed(context, '/create-album');
          if (newAlbum != null && newAlbum is Album) {
            setState(() {
              albums.insert(0, newAlbum); // добавляем новый альбом в начало списка
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
