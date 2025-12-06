import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../services/api_service.dart';
import '../../auth/services/auth_service.dart';
import '../models/album.dart';


class CreateAlbumScreen extends StatefulWidget {
  const CreateAlbumScreen({super.key});

  @override
  _CreateAlbumScreenState createState() => _CreateAlbumScreenState();
}

class _CreateAlbumScreenState extends State<CreateAlbumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<File> _selectedFiles = [];
  bool _isPublic = true;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _successMessage;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создание альбома')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_errorMessage != null)
                  _buildMessageCard(_errorMessage!, Colors.red, Icons.error),
                if (_successMessage != null)
                  _buildMessageCard(
                      _successMessage!, Colors.green, Icons.check_circle),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Название альбома*'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Описание (необязательно)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Сделать альбом публичным'),
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickFiles,
                  child: const Text('Выбрать файлы'),
                ),
                const SizedBox(height: 8),
                _selectedFiles.isNotEmpty
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedFiles.length,
                          itemBuilder: (_, i) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(4),
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade300,
                                child: Center(
                                  child: Text(
                                    _selectedFiles[i].path.split('/').last,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedFiles.removeAt(i)),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                if (_uploadProgress > 0 && _uploadProgress < 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(value: _uploadProgress),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createAlbum,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Создать альбом'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageCard(String message, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(color: color))),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _successMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles() async {
    try {
      final images = await _picker.pickMultiImage(imageQuality: 85);
      setState(() {
        _selectedFiles.addAll(images.map((x) => File(x.path)));
      });
    } catch (e) {
      setState(() => _errorMessage = 'Ошибка выбора файлов: $e');
    }
  }

  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate() || _selectedFiles.isEmpty) {
      setState(() => _errorMessage =
          'Заполните все обязательные поля и добавьте хотя бы один файл');
      return;
    }

    final user = AuthService.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Не авторизованы');
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final album = Album(
        id: 0,
        title: _titleController.text,
        visible: _isPublic,
        userId: user.id,
      );

      final apiService = Provider.of<ApiService>(context, listen: false);

      final createdAlbum = await apiService.createAlbum(album);

      FormData formData = FormData();
      for (var file in _selectedFiles) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      await apiService.uploadAlbumFiles(createdAlbum.id, formData);

      setState(() {
        _successMessage = 'Альбом "${createdAlbum.title}" успешно создан!';
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/album/${createdAlbum.id}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при создании альбома: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
