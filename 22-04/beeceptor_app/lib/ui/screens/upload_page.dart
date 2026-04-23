import 'dart:io';

import 'package:beeceptor_app/providers/upload_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

//TODO: debuggar pra encontrar o erro que não está dando sucesso ao fazer upload

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

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null && mounted) {
      final plataformFile = result.files.single;
      setState(() {
        _selectedFile = File(plataformFile.path!);
        _selectedFileName = plataformFile.name;
        _isImage = false;
      });
    }
  }

  void _uploadFile() {
    if (_selectedFile == null) return;
    context.read<UploadProvider>().upload(
      _selectedFile!.path,
      _selectedFileName ?? 'file',
    );
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
                  label: Text('Galeria'),
                  icon: Icon(Icons.browse_gallery),
                ),
                OutlinedButton.icon(
                  onPressed: _pickFromCamera,
                  label: Text('Câmera'),
                  icon: Icon(Icons.camera_alt),
                ),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  label: Text('Arquivo'),
                  icon: Icon(Icons.attach_file),
                ),
              ],
            ),
            SizedBox(height: 24),
            if (_selectedFile != null)
              if (_isImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedFile!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const Icon(Icons.insert_drive_file, size: 64),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 12),
              Text(_selectedFileName!, textAlign: TextAlign.center),
            ],
            Consumer<UploadProvider>(
              builder: (context, provider, _) {
                return FilledButton.icon(
                  onPressed: provider.isLoading ? null : _uploadFile,
                  icon: const Icon(Icons.send),
                  label: Text(
                    provider.isLoading ? 'Enviando...' : 'Enviar Arquivo',
                  ),
                );
              },
            ),
            Consumer<UploadProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return Column(
                    children: [
                      LinearProgressIndicator(value: provider.progress),
                      Text('${(provider.progress * 100).toStringAsFixed(0)}%'),
                    ],
                  );
                }
                return SizedBox(width: 20);
              },
            ),
            Consumer<UploadProvider>(
              builder: (context, provider, _) {
                if (provider.result != null) {
                  return Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                      const Text('Arquivo enviado com sucesso!'),
                      SelectableText(provider.result!.location),
                    ],
                  );
                }
                return SizedBox(width: 20);
              },
            ),
          ],
        ),
      ),
    );
  }
}
