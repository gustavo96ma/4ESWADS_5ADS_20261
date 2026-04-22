class UploadResult {
  final String originalName;
  final String fileName;
  final String location;

  UploadResult({
    required this.originalName,
    required this.fileName,
    required this.location,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      originalName: json['originalname'] ?? '',
      fileName: json['filename'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalname': originalName,
      'filename': fileName,
      'location': location,
    };
  }
}
