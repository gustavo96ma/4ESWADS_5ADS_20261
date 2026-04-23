import 'package:beeceptor_app/models/upload_result.dart';
import 'package:beeceptor_app/services/upload_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadProvider extends ChangeNotifier {
  final UploadService _uploadService;
  UploadProvider(this._uploadService);

  UploadResult? _result;
  UploadResult? get result => _result;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  double _progress = 0.0;
  double get progress => _progress;

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
    } on DioException catch (e) {
      switch (e.type) {
        case DioException.connectionTimeout:
        case DioExceptionType.sendTimeout:
          _error = 'Tempo limite excedido. Verifique sua conexão';
          break;
        case DioException.connectionError:
          _error = 'Sem conexão com a internet';
          break;
        case DioException.badResponse:
          _error = 'Erro do servidor: ${e.response?.statusCode}';
        default:
          _error = 'Erro de rede: ${e.message}';
      }
    } catch (e) {
      _error = 'Erro inesperado $e}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
