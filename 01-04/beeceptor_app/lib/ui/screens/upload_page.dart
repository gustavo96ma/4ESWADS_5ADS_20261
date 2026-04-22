import 'dart:io';

import 'package:beeceptor_app/providers/upload_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedFile;
  String? _selectedFileName;
  bool _isImage = false;

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        _selectedFileName = image.name;
        _isImage = true;
      });
      context.read<UploadProvider>().clearResult();
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null && mounted) {
      setState(() {
        _selectedFile = File(photo.path);
        _selectedFileName = photo.name;
        _isImage = true;
      });
      context.read<UploadProvider>().clearResult();
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null && mounted) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _selectedFileName = result.files.single.name;
        _isImage = false;
      });
      context.read<UploadProvider>().clearResult();
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
      appBar: AppBar(
        title: const Text('Upload de Arquivos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Botoes de selecao
            const Icon(Icons.cloud_upload, size: 64, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              'Selecione um arquivo para enviar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            _ActionButton(
              icon: Icons.photo_library,
              label: 'Escolher da Galeria',
              onPressed: _pickFromGallery,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.camera_alt,
              label: 'Tirar Foto',
              onPressed: _pickFromCamera,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.attach_file,
              label: 'Escolher Arquivo',
              onPressed: _pickFile,
            ),

            const SizedBox(height: 24),

            // Preview do arquivo selecionado
            if (_selectedFile != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
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
                      const Icon(
                        Icons.insert_drive_file,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? 'Arquivo selecionado',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botao de enviar
              Consumer<UploadProvider>(
                builder: (context, provider, _) {
                  return SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: provider.isLoading ? null : _uploadFile,
                      icon: const Icon(Icons.send),
                      label: Text(
                        provider.isLoading ? 'Enviando...' : 'Enviar Arquivo',
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Estado do upload (progresso, sucesso, erro)
            Consumer<UploadProvider>(
              builder: (context, provider, _) {
                // Estado de progresso
                if (provider.isLoading) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: provider.progress,
                          backgroundColor: Colors.blue.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.redAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${(provider.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Estado de erro
                if (provider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Estado de sucesso
                if (provider.result != null) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade600,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Arquivo enviado com sucesso!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.result!.originalName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: SelectableText(
                            provider.result!.location,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            provider.clearResult();
                            setState(() {
                              _selectedFile = null;
                              _selectedFileName = null;
                              _isImage = false;
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Enviar outro arquivo'),
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
