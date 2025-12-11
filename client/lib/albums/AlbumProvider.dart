import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'models/album.dart';


class AlbumProvider extends ChangeNotifier {
  final ApiService api;

  AlbumProvider(this.api);

  List<Album> myAlbums = [];
  bool loaded = false;

  Future<void> loadMyAlbums() async {
    myAlbums = await api.getMyAlbums();
    loaded = true;
    notifyListeners();
  }

  Future<void> addAlbum(Album album) async {
    myAlbums.add(album);
    notifyListeners();
  }
}
