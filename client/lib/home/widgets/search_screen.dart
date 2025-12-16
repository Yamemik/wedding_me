import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../albums/models/album.dart';
import '../../photos/models/photo.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  bool loading = false;
  String? error;

  List<String> searchHistory = [];
  List<Album> albums = [];
  List<Photo> photos = [];

  // ---------------- SEARCH ----------------
  void _onSearch(String query) {
    if (query.trim().isEmpty) return;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    final api = context.read<ApiService>();

    setState(() {
      loading = true;
      error = null;
    });

    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
    }

    try {
      final res = await api.searchAlbums(query);

      setState(() {
        albums = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка поиска';
        loading = false;
      });
    }
  }

  void _clear() {
    _controller.clear();
    setState(() {
      albums.clear();
      photos.clear();
      error = null;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 226, 171, 190),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            hintText: 'Поиск альбомов и фото...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
          ),
          onChanged: _onSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: _clear,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }

    if (albums.isEmpty && photos.isEmpty) {
      return _buildHistory();
    }

    return ListView(
      children: [
        if (albums.isNotEmpty) ...[
          _sectionTitle('Альбомы'),
          ...albums.map(_albumTile),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  // ---------------- HISTORY ----------------
  Widget _buildHistory() {
    if (searchHistory.isEmpty) {
      return Center(
        child: Text(
          "Введите запрос для поиска",
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Недавние запросы'),
        ...searchHistory.map(
          (h) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(h),
            trailing: const Icon(Icons.north_west),
            onTap: () {
              _controller.text = h;
              _onSearch(h);
            },
          ),
        ),
      ],
    );
  }

  // ---------------- HELPERS ----------------
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _albumTile(Album album) {
    return ListTile(
      leading: const Icon(Icons.photo_album, color: Colors.pink),
      title: Text(album.title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(context, '/album/${album.id}');
      },
    );
  }
}
