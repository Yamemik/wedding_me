import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../models/photo.dart';


class PhotoScreen extends StatefulWidget {
  final int photoId;

  const PhotoScreen({required this.photoId, super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  Photo? photo;
  bool loading = true;

  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPhoto();
  }

  Future<void> loadPhoto() async {
    final api = context.read<ApiService>();
    final data = await api.getPhoto(widget.photoId);

    setState(() {
      photo = data;
      loading = false;
    });
  }

  Future<void> sendComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final api = context.read<ApiService>();
    await api.createComment(photo!.id, text);

    commentController.clear();
    await loadPhoto();
  }

  Future<void> toggleLike() async {
    final api = context.read<ApiService>();
    await api.toggleLike(photo!.id);
    await loadPhoto();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final imageUrl = "http://10.0.2.2:8000${photo!.path}";
    final likes = photo!.likes?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(photo!.title ?? "Фото")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            /// Фото
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl),
            ),
            const SizedBox(height: 16),

            /// Лайки
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.favorite,
                      color: photo!.likes!.isNotEmpty ? Colors.red : Colors.grey),
                  onPressed: toggleLike,
                ),
                Text("$likes лайков"),
              ],
            ),

            const SizedBox(height: 12),

            /// Теги
            Wrap(
              spacing: 8,
              children: [
                for (final t in photo!.tags ?? [])
                  Chip(
                    label: Text(t.name),
                    backgroundColor: Color(int.parse(t.color)),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /// Комментарии
            const Text(
              "Комментарии:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(
              photo!.comments?.length ?? 0,
              (i) {
                final c = photo!.comments![i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.person, size: 30),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.user?.email ?? "Пользователь",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(c.text),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// Поле для ввода комментария
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                labelText: "Написать комментарий...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: sendComment,
              child: const Text("Отправить"),
            ),

          ],
        ),
      ),
    );
  }
}
