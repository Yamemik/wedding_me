import 'package:flutter/material.dart';
import '../models/photo.dart';

class PhotoGridItem extends StatelessWidget {
  final Photo photo;

  const PhotoGridItem({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/photo/${photo.id}");
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          "http://10.0.2.2:8000${photo.path}",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
