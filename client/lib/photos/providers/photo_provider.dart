import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  final PhotoService service;

  PhotoProvider(this.service);

  bool loading = false;
  List<Photo> photos = [];
  String? error;

  Future<void> loadPhotos(int albumId) async {
    loading = true;
    notifyListeners();

    try {
      photos = await service.getPhotosByAlbum(albumId);
      error = null;
    } catch (e) {
      error = "Ошибка загрузки фотографий: $e";
    }

    loading = false;
    notifyListeners();
  }

  Future<void> refresh(int albumId) async {
    await loadPhotos(albumId);
  }
}
