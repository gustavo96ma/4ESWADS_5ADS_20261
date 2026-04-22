import 'dart:io';

import 'package:beeceptor_app/providers/upload_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// Limite maximo de tamanho de arquivo: 10 MB
const _maxFileSizeBytes = 10 * 1024 * 1024;

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _picker = ImagePicker();

  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isImage = false;

  @override
  void initState() {
    super.initState();
    // Recupera imagem perdida caso o Android destrua a Activity
    // enquanto o picker nativo esta aberto (ex: pouca memoria)
    _retrieveLostData();
  }

  /// Android pode destruir a Activity enquanto o picker esta aberto.
  /// retrieveLostData() recupera a imagem que foi selecionada.
  Future<void> _retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty || response.file == null) return;
    if (!mounted) return;

    final file = File(response.file!.path);
    setState(() {
      _selectedFile = file;
      _selectedFileName = response.file!.name;
      _selectedFileSize = file.lengthSync();
      _isImage = true;
    });
  }

  /// Seleciona imagem da galeria com compressao automatica.
  /// maxWidth/maxHeight reduzem dimensoes; imageQuality comprime JPEG.
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (image != null && mounted) {
      final file = File(image.path);
      setState(() {
        _selectedFile = file;
        _selectedFileName = image.name;
        _selectedFileSize = file.lengthSync();
        _isImage = true;
      });
      context.read<UploadProvider>().clearResult();
    }
  }

  /// Tira foto com a camera com compressao automatica.
  Future<void> _pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (photo != null && mounted) {
      final file = File(photo.path);
      setState(() {
        _selectedFile = file;
        _selectedFileName = photo.name;
        _selectedFileSize = file.lengthSync();
        _isImage = true;
      });
      context.read<UploadProvider>().clearResult();
    }
  }

  /// Seleciona qualquer tipo de arquivo (PDF, DOCX, etc.)
  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null && mounted) {
      final platformFile = result.files.single;
      setState(() {
        _selectedFile = File(platformFile.path!);
        _selectedFileName = platformFile.name;
        _selectedFileSize = platformFile.size;
        _isImage = false;
      });
      context.read<UploadProvider>().clearResult();
    }
  }

  /// Valida tamanho e envia o arquivo para a API.
  void _uploadFile() {
    if (_selectedFile == null) return;

    // Validacao de tamanho antes de enviar
    if (_selectedFileSize != null && _selectedFileSize! > _maxFileSizeBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arquivo muito grande! Limite: 10 MB'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<UploadProvider>().upload(
          _selectedFile!.path,
          _selectedFileName ?? 'file',
        );
  }

  /// Formata bytes em texto legivel (KB, MB)
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
            // Icone e descricao
            const Icon(Icons.cloud_upload, size: 64, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              'Selecione um arquivo para enviar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Limite: 10 MB',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),

            // Botoes de selecao de arquivo
            _ActionButton(
              icon: Icons.photo_library,
              label: 'Escolher da Galeria',
              subtitle: 'Imagens com compressao automatica',
              onPressed: _pickFromGallery,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.camera_alt,
              label: 'Tirar Foto',
              subtitle: 'Usa a camera do dispositivo',
              onPressed: _pickFromCamera,
            ),
            const SizedBox(height: 12),
            _ActionButton(
              icon: Icons.attach_file,
              label: 'Escolher Arquivo',
              subtitle: 'PDF, DOCX, ou qualquer arquivo',
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
                    if (_selectedFileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatFileSize(_selectedFileSize!),
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedFileSize! > _maxFileSizeBytes
                              ? Colors.red
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
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
                        const SizedBox(height: 4),
                        Text(
                          'Enviando arquivo...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                provider.error!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _uploadFile,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade700,
                              side: BorderSide(color: Colors.red.shade300),
                            ),
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
                              _selectedFileSize = null;
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
  final String? subtitle;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 60),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}
