import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/album.dart';
import '../../services/api_service.dart';


class AlbumDetailScreen extends StatefulWidget {
  final int albumId;

  const AlbumDetailScreen({required this.albumId, super.key});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  Album? album;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAlbum();
  }

  Future<void> loadAlbum() async {
    final api = context.read<ApiService>();
    final data = await api.getAlbum(widget.albumId);

    setState(() {
      album = data;
      loading = false;
    });
  }

  Future<FormData> buildFormData(List<XFile> files) async {
    final formData = FormData();
    for (final file in files) {
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
          ),
        ),
      );
    }
    return formData;
  }

  Future<void> uploadPhotos() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();

    if (files.isEmpty) return;

    final api = context.read<ApiService>();

    final formData = await buildFormData(files);

    await api.uploadAlbumFiles(
      widget.albumId,
      formData,
      onSendProgress: (sent, total) {
        print("Отправлено: $sent / $total");
      },
    );

    // обновляем альбом
    final updated = await api.getAlbum(widget.albumId);
    setState(() => album = updated);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(album!.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadPhotos,
        child: const Icon(Icons.add_a_photo),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: album!.photos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, i) {
          final photo = album!.photos[i];
          final imageUrl = "http://10.0.2.2:8000${photo.path}";

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
