// screens/create_album_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
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
  
  List<File> _selectedFiles = []; // Убрали final
  List<XFile>? _imageFiles;
  bool _isPublic = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание альбома'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () {
            if (_selectedFiles.isNotEmpty) {
              _showExitConfirmationDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Сообщения об ошибке/успехе
                if (_errorMessage != null) _buildMessageCard(
                  _errorMessage!,
                  Colors.red,
                  Icons.error,
                ),
                
                if (_successMessage != null) _buildMessageCard(
                  _successMessage!,
                  Colors.green,
                  Icons.check_circle,
                ),

                // Название альбома
                _buildSectionTitle('Основная информация'),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Название альбома*',
                    hintText: 'Введите название вашего альбома',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Пожалуйста, введите название альбома';
                    }
                    if (value.length < 3) {
                      return 'Название должно быть не менее 3 символов';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),

                const SizedBox(height: 16),

                // Описание альбома
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Описание (необязательно)',
                    hintText: 'Добавьте описание к вашему альбому',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),

                const SizedBox(height: 24),
                
                // Настройки приватности
                _buildSectionTitle('Настройки приватности'),
                const SizedBox(height: 12),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isPublic ? Icons.public : Icons.lock,
                              color: _isPublic ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPublic ? 'Публичный альбом' : 'Приватный альбом',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _isPublic 
                                        ? 'Доступен всем пользователям WeddingMe'
                                        : 'Доступен только вам и приглашенным гостям',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Сделать альбом публичным'),
                          value: _isPublic,
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              _isPublic = value;
                            });
                          },
                          activeColor: Colors.pink,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                
                // Загрузка файлов
                _buildSectionTitle('Загрузка файлов'),
                const SizedBox(height: 12),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Кнопка выбора файлов
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _pickFiles,
                          icon: const Icon(Icons.cloud_upload_outlined),
                          label: const Text('Выбрать файлы'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: _colorWithOpacity(Colors.pink, 0.1),
                            foregroundColor: Colors.pink,
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Информация о файлах
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade600,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Поддерживаемые форматы: JPG, PNG, GIF, MP4, MOV',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Список выбранных файлов
                        if (_selectedFiles.isNotEmpty) ...[
                          Divider(color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Выбрано файлов: ${_selectedFiles.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _selectedFiles.clear();
                                  });
                                },
                                child: const Text(
                                  'Очистить все',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Грид с превью файлов
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _selectedFiles.length,
                            itemBuilder: (context, index) {
                              return _buildFilePreview(index);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
                
                // Кнопка создания
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAlbum,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: _colorWithOpacity(Colors.pink, 0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'СОЗДАТЬ АЛЬБОМ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Дополнительная информация
                Card(
                  color: _colorWithOpacity(Colors.blue, 0.1),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade100),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Совет: Вы можете добавить больше фотографий в альбом после его создания в разделе редактирования.',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Виджет заголовка секции
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  // Виджет сообщения
  Widget _buildMessageCard(String message, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _colorWithOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _colorWithOpacity(color, 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () {
              setState(() {
                if (color == Colors.red) {
                  _errorMessage = null;
                } else {
                  _successMessage = null;
                }
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Превью файла
  Widget _buildFilePreview(int index) {
    final file = _selectedFiles[index];
    final fileName = file.path.split('/').last;
    final isImage = fileName.toLowerCase().endsWith('.jpg') ||
        fileName.toLowerCase().endsWith('.jpeg') ||
        fileName.toLowerCase().endsWith('.png') ||
        fileName.toLowerCase().endsWith('.gif');
    final isVideo = fileName.toLowerCase().endsWith('.mp4') ||
        fileName.toLowerCase().endsWith('.mov') ||
        fileName.toLowerCase().endsWith('.avi');

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isImage) Icon(Icons.image, color: Colors.grey.shade600, size: 32),
              if (isVideo) Icon(Icons.videocam, color: Colors.grey.shade600, size: 32),
              if (!isImage && !isVideo) 
                Icon(Icons.insert_drive_file, color: Colors.grey.shade600, size: 32),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  fileName.length > 15 
                      ? '${fileName.substring(0, 12)}...${fileName.substring(fileName.length - 3)}'
                      : fileName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: _isLoading ? null : () {
              setState(() {
                _selectedFiles.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Вспомогательный метод для создания цвета с прозрачностью
  Color _colorWithOpacity(Color color, double opacity) {
    return Color.fromRGBO(
      color.red,
      color.green,
      color.blue,
      opacity, // Правильное использование: opacity от 0.0 до 1.0
    );
  }

  // Альтернативный метод с использованием Color.fromARGB
  Color _colorWithAlpha(Color color, int alpha) {
    return Color.fromARGB(
      alpha, // alpha от 0 до 255
      color.red,
      color.green,
      color.blue,
    );
  }

  // Выбор файлов
  Future<void> _pickFiles() async {
    try {
      _imageFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (_imageFiles != null && _imageFiles!.isNotEmpty) {
        final files = _imageFiles!.map((xfile) => File(xfile.path)).toList();
        setState(() {
          _selectedFiles.addAll(files);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при выборе файлов: $e';
      });
    }
  }

  // Создание альбома
  Future<void> _createAlbum() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFiles.isEmpty) {
      setState(() {
        _errorMessage = 'Пожалуйста, добавьте хотя бы одну фотографию';
      });
      return;
    }

    final apiService = Provider.of<ApiService>(context, listen: false);
    
    if (apiService.currentUser == null) {
      setState(() {
        _errorMessage = 'Вы не авторизованы';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // 1. Создаем альбом
      final album = Album(
        id: 0,
        title: _titleController.text,
        visible: _isPublic,
        userId: apiService.currentUser!.id,
        createdAt: DateTime.now(),
        photoCount: _selectedFiles.length,
        videoCount: _selectedFiles.where((file) {
          final name = file.path.toLowerCase();
          return name.endsWith('.mp4') || name.endsWith('.mov') || name.endsWith('.avi');
        }).length,
      );

      final createdAlbum = await apiService.createAlbum(album);

      // 2. Загружаем файлы (в реальном приложении здесь была бы загрузка)
      // Для демо просто имитируем загрузку
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _successMessage = 'Альбом "${createdAlbum.title}" успешно создан!';
        _isLoading = false;
      });

      // 3. Переходим на экран альбома через 2 секунды
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/album/:id',
          arguments: createdAlbum.id.toString(),
        );
      }

    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка при создании альбома: $e';
        _isLoading = false;
      });
    }
  }

  // Диалог подтверждения выхода
  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Выйти без сохранения?'),
          content: const Text('Вы добавили фотографии. Все несохраненные изменения будут потеряны.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Выйти',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}