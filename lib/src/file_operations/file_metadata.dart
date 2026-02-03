// lib/src/file_operations/file_metadata.dart

class FileMetadata {
  final String fileName;
  final String absolutePath;
  final int sizeInBytes;
  final String? mimeType;
  final String? sourceUrl;
  final DateTime downloadTimestamp;
  final String? subfolder;

  const FileMetadata({
    required this.fileName,
    required this.absolutePath,
    required this.sizeInBytes,
    this.mimeType,
    this.sourceUrl,
    required this.downloadTimestamp,
    this.subfolder,
  });

  double get sizeInKB => sizeInBytes / 1024;
  double get sizeInMB => sizeInKB / 1024;

  String get formattedSize {
    if (sizeInBytes < 1024) {
      return '$sizeInBytes B';
    } else if (sizeInKB < 1024) {
      return '${sizeInKB.toStringAsFixed(1)} KB';
    } else {
      return '${sizeInMB.toStringAsFixed(1)} MB';
    }
  }

  String? get fileExtension {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot == -1) return null;
    return fileName.substring(lastDot + 1).toLowerCase();
  }

  bool get isDownloaded => sourceUrl != null;

  FileMetadata copyWith({
    String? fileName,
    String? absolutePath,
    int? sizeInBytes,
    String? mimeType,
    String? sourceUrl,
    DateTime? downloadTimestamp,
    String? subfolder,
  }) {
    return FileMetadata(
      fileName: fileName ?? this.fileName,
      absolutePath: absolutePath ?? this.absolutePath,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      mimeType: mimeType ?? this.mimeType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      downloadTimestamp: downloadTimestamp ?? this.downloadTimestamp,
      subfolder: subfolder ?? this.subfolder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'absolutePath': absolutePath,
      'sizeInBytes': sizeInBytes,
      'mimeType': mimeType,
      'sourceUrl': sourceUrl,
      'downloadTimestamp': downloadTimestamp.toIso8601String(),
      'subfolder': subfolder,
    };
  }

  factory FileMetadata.fromMap(Map<String, dynamic> map) {
    return FileMetadata(
      fileName: map['fileName'] as String,
      absolutePath: map['absolutePath'] as String,
      sizeInBytes: map['sizeInBytes'] as int,
      mimeType: map['mimeType'] as String?,
      sourceUrl: map['sourceUrl'] as String?,
      downloadTimestamp: DateTime.parse(map['downloadTimestamp'] as String),
      subfolder: map['subfolder'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileMetadata && other.absolutePath == absolutePath;
  }

  @override
  int get hashCode => absolutePath.hashCode;

  @override
  String toString() {
    return 'FileMetadata(fileName: $fileName, size: $formattedSize, downloaded: $isDownloaded)';
  }
}