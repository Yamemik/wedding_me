import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/photo_grid_item.dart';

class PhotoListScreen extends StatelessWidget {
  final int albumId;

  const PhotoListScreen({super.key, required this.albumId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PhotoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Фотографии")),
      body: RefreshIndicator(
        onRefresh: () => provider.refresh(albumId),
        child: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null
                ? Center(child: Text(provider.error!))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.photos.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (_, i) =>
                        PhotoGridItem(photo: provider.photos[i]),
                  ),
      ),
    );
  }
}
