import 'package:beeceptor_app/models/upload_result.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UploadService {
  final Dio _dio;
  final String _baseUrl = 'https://api.escuelajs.co/api/v1/files/upload';

  UploadService(this._dio);

  Future<UploadResult> uploadFile(
    String filePath,
    String fileName, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await _dio.post(
      _baseUrl,
      data: formData,
      onSendProgress: onSendProgress,
    );

    debugPrint('UPLOAD RESPONSE: ${response.data}');
    return UploadResult.fromJson(response.data);
  }
}
