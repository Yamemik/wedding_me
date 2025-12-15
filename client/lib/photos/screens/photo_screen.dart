import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../models/photo.dart';


class PhotoScreen extends StatefulWidget {
  final int photoId;
  final bool isOwner;

  const PhotoScreen({
    required this.photoId,
    required this.isOwner,
    super.key,
  });

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

    if (!mounted) return;

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

  /// ✅ Подтверждение + удаление фото
  Future<void> _deletePhoto() async {
    final api = context.read<ApiService>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить фото?'),
        content: const Text('Фото будет удалено без возможности восстановления'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await api.deletePhoto(photo!.id);

      if (!mounted) return;

      // ✅ Возвращаем ID удалённого фото
      Navigator.pop(context, photo!.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото удалено')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при удалении фото')),
      );
    }
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
      appBar: AppBar(
        title: Text(photo!.title ?? "Фото"),

        /// ✅ КНОПКА УДАЛЕНИЯ ТОЛЬКО ДЛЯ ВЛАДЕЛЬЦА
        actions: [
          if (widget.isOwner)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deletePhoto,
            ),
        ],
      ),
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
                  icon: Icon(
                    Icons.favorite,
                    color: photo!.likes!.isNotEmpty ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleLike,
                ),
                Text("$likes"),
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

            ...photo!.comments!.map((c) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.user?.name ?? "Пользователь",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(c.text),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            /// Ввод комментария
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
