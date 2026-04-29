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
      originalName: json['originalName'] ?? '',
      fileName: json['fileName'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originalName': originalName,
      'fileName': fileName,
      'location': location,
    };
  }
}
