import 'package:beeceptor_app/models/upload_result.dart';
import 'package:beeceptor_app/services/upload_service.dart';
import 'package:flutter/material.dart';

class UploadProvider extends ChangeNotifier {
  final UploadService _uploadService;
  UploadProvider(this._uploadService);

  /// Resultado do upload
  UploadResult? _result;
  UploadResult? get result => _result;

  /// Controle de estado de carregamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Controle de erro
  String? _error;
  String? get error => _error;

  /// Progresso do upload (0.0 a 1.0)
  double _progress = 0.0;
  double get progress => _progress;

  /// Envia o arquivo para a API
  Future<void> upload(String filePath, String fileName) async {
    _isLoading = true;
    _error = null;
    _progress = 0.0;
    _result = null;
    notifyListeners();

    try {
      _result = await _uploadService.uploadFile(
        filePath,
        fileName,
        onSendProgress: (sent, total) {
          _progress = sent / total;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erro ao enviar arquivo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa o resultado para novo upload
  void clearResult() {
    _result = null;
    _error = null;
    _progress = 0.0;
    notifyListeners();
  }
}
