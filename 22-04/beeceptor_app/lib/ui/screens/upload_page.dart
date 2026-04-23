import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _picker = ImagePicker();

  File? _selectedFile;
  String? _selectedFileName;
  bool _isImage = false;

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 1080,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
        _isImage = true;
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1080,
      maxWidth: 1920,
      imageQuality: 85,
    );

    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
        _isImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload de Arquivos')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  label: Text('Escolher da Galeria'),
                ),
                OutlinedButton.icon(
                  onPressed: _pickFromCamera,
                  label: Text('Escolher da Câmera'),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (_selectedFile != null && _isImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 12),
              Text(_selectedFileName!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
