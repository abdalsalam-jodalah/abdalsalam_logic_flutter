# File Handling Service Documentation

## Overview

The File Handling Service provides comprehensive file management capabilities for Flutter applications, including secure downloads, storage management, and cross-platform file operations. All files are stored in the system's Downloads directory under an app-specific folder for user accessibility.

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [File Storage Structure](#file-storage-structure)
- [Download Management](#download-management)
- [File Operations](#file-operations)
- [Error Handling](#error-handling)
- [Platform Support](#platform-support)
- [Best Practices](#best-practices)
- [Examples](#examples)

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  abdalsalam_logic_flutter: ^1.0.0
```

Import the necessary classes:

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';
```

## Quick Start

```dart
// Initialize the file service with your app name
final fileService = FileServiceImpl(appName: 'MyApp');
await fileService.initialize();

// Download a file
final metadata = await fileService.downloadFile(
  url: 'https://example.com/document.pdf',
  subfolder: 'documents',
);

// Open the downloaded file
await fileService.openFile(metadata.absolutePath);

// Clean up
await fileService.dispose();
```

## API Reference

### FileService Interface

The main interface for all file operations.

#### Core Methods

##### `downloadFile()`
Downloads a file from a remote URL with progress tracking.

```dart
Future<FileMetadata> downloadFile({
  required String url,
  String? subfolder,
  String? customFileName,
  void Function(FileDownloadProgress)? onProgress,
})
```

**Parameters:**
- `url`: Remote file URL (HTTP/HTTPS only)
- `subfolder`: Optional subfolder within app directory
- `customFileName`: Custom name for the downloaded file
- `onProgress`: Callback for download progress updates

**Returns:** `FileMetadata` object with file information

**Throws:**
- `InvalidFileUrlException`: Invalid or malformed URL
- `FileDownloadException`: Network or download errors
- `FilePermissionException`: Insufficient permissions

##### `openFile()`
Opens a file using the system's default application.

```dart
Future<bool> openFile(String filePath)
```

**Parameters:**
- `filePath`: Absolute path to the file

**Returns:** `true` if file opened successfully

**Throws:**
- `FileNotFoundException`: File doesn't exist
- `FileOpenException`: Failed to open file

##### `deleteFile()`
Deletes a specific file.

```dart
Future<void> deleteFile(String filePath)
```

**Parameters:**
- `filePath`: Absolute path to the file to delete

**Throws:**
- `FileNotFoundException`: File doesn't exist
- `FilePermissionException`: Insufficient permissions

##### `fileExists()`
Checks if a file exists at the specified path.

```dart
Future<bool> fileExists(String filePath)
```

**Parameters:**
- `filePath`: Absolute path to check

**Returns:** `true` if file exists

##### `getFileInfo()`
Retrieves metadata for a specific file.

```dart
Future<FileMetadata?> getFileInfo(String filePath)
```

**Parameters:**
- `filePath`: Absolute path to the file

**Returns:** `FileMetadata` object or `null` if file doesn't exist

##### `listFiles()`
Lists all files in the app directory or a specific subfolder.

```dart
Future<List<FileMetadata>> listFiles({String? subfolder})
```

**Parameters:**
- `subfolder`: Optional subfolder to list (null for all files)

**Returns:** List of `FileMetadata` objects sorted by download date

##### `clearFiles()`
Deletes all files in the app directory or a specific subfolder.

```dart
Future<void> clearFiles({String? subfolder})
```

**Parameters:**
- `subfolder`: Optional subfolder to clear (null clears everything)

#### Utility Methods

##### `getDownloadsPath()`
Gets the absolute path to the app's download directory.

```dart
Future<String> getDownloadsPath()
```

**Returns:** Absolute path to app download directory

##### `getSubfolders()`
Lists all subfolders in the app directory.

```dart
Future<List<String>> getSubfolders()
```

**Returns:** List of subfolder names

##### `getTotalStorageUsage()`
Calculates total storage usage in bytes.

```dart
Future<int> getTotalStorageUsage({String? subfolder})
```

**Parameters:**
- `subfolder`: Optional subfolder to analyze (null for total usage)

**Returns:** Storage usage in bytes

##### `cancelDownload()`
Cancels an active download.

```dart
bool cancelDownload(String url)
```

**Parameters:**
- `url`: URL of the download to cancel

**Returns:** `true` if download was cancelled

##### `getActiveDownloads()`
Gets list of currently active downloads.

```dart
List<String> getActiveDownloads()
```

**Returns:** List of URLs being downloaded

### FileMetadata Class

Represents metadata for a file.

#### Properties

```dart
class FileMetadata {
  final String fileName;           // File name with extension
  final String absolutePath;      // Full path to file
  final int sizeInBytes;          // File size in bytes
  final String? mimeType;         // MIME type (if detected)
  final String? sourceUrl;        // Original download URL
  final DateTime downloadTimestamp; // When file was downloaded
  final String? subfolder;        // Subfolder location
}
```

#### Utility Properties

```dart
double get sizeInKB              // Size in kilobytes
double get sizeInMB              // Size in megabytes
String get formattedSize         // Human-readable size
String? get fileExtension        // File extension
bool get isDownloaded            // Whether file was downloaded
```

### FileDownloadProgress Class

Provides download progress information.

#### Properties

```dart
class FileDownloadProgress {
  final int bytesReceived;         // Bytes downloaded
  final int totalBytes;            // Total file size
  final double speedBytesPerSecond; // Download speed
  final Duration elapsedTime;      // Time since start
}
```

#### Utility Properties

```dart
double get progressPercentage    // Progress as percentage
String get formattedSpeed        // Human-readable speed
Duration get estimatedTimeRemaining // Estimated time left
```

## File Storage Structure

Files are organized in the system's Downloads directory under your app name:

```
Downloads/
  MyAppName/
    ├── document1.pdf           # Root level files
    ├── image.jpg
    └── documents/              # Subfolder
        ├── invoice.pdf
        └── report.docx
    └── images/                 # Another subfolder
        ├── photo1.jpg
        └── screenshot.png
```

### Platform-Specific Locations

- **Android**: `/storage/emulated/0/Download/MyAppName/`
- **iOS**: `~/Documents/Downloads/MyAppName/`
- **Windows**: `%USERPROFILE%\Downloads\MyAppName\`
- **macOS**: `~/Downloads/MyAppName/`
- **Linux**: `~/Downloads/MyAppName/`

## Download Management

### Basic Download

```dart
final metadata = await fileService.downloadFile(
  url: 'https://example.com/file.pdf',
);
print('Downloaded: ${metadata.fileName}');
```

### Download with Progress

```dart
final metadata = await fileService.downloadFile(
  url: 'https://example.com/large-file.zip',
  onProgress: (progress) {
    print('${progress.progressPercentage.toStringAsFixed(1)}% '
          '(${progress.formattedSpeed})');
  },
);
```

### Download to Subfolder

```dart
final metadata = await fileService.downloadFile(
  url: 'https://example.com/invoice.pdf',
  subfolder: 'invoices',
  customFileName: 'invoice_2024_01.pdf',
);
```

### Cancel Download

```dart
// Start download
fileService.downloadFile(url: 'https://example.com/large-file.zip');

// Cancel it
final cancelled = fileService.cancelDownload('https://example.com/large-file.zip');
print('Cancelled: $cancelled');
```

### Monitor Active Downloads

```dart
final activeDownloads = fileService.getActiveDownloads();
print('Active downloads: ${activeDownloads.length}');
```

## File Operations

### Check File Existence

```dart
final exists = await fileService.fileExists('/path/to/file.pdf');
if (exists) {
  print('File exists');
}
```

### Get File Information

```dart
final metadata = await fileService.getFileInfo('/path/to/file.pdf');
if (metadata != null) {
  print('File: ${metadata.fileName}');
  print('Size: ${metadata.formattedSize}');
  print('Downloaded: ${metadata.downloadTimestamp}');
}
```

### Open File

```dart
try {
  final opened = await fileService.openFile(metadata.absolutePath);
  if (opened) {
    print('File opened successfully');
  }
} catch (e) {
  print('Failed to open file: $e');
}
```

### List Files

```dart
// List all files
final allFiles = await fileService.listFiles();
print('Total files: ${allFiles.length}');

// List files in specific subfolder
final documents = await fileService.listFiles(subfolder: 'documents');
print('Documents: ${documents.length}');
```

### Delete Files

```dart
// Delete specific file
await fileService.deleteFile(metadata.absolutePath);

// Clear all files in subfolder
await fileService.clearFiles(subfolder: 'temp');

// Clear all files
await fileService.clearFiles();
```

## Error Handling

The service throws specific exceptions for different error scenarios:

### Exception Types

#### `InvalidFileUrlException`
Thrown when URL is malformed or uses unsupported protocol.

```dart
try {
  await fileService.downloadFile(url: 'invalid-url');
} catch (e) {
  if (e is InvalidFileUrlException) {
    print('Invalid URL: ${e.message}');
    print('Error code: ${e.code}');
  }
}
```

#### `FileDownloadException`  
Thrown when download fails due to network or server errors.

```dart
try {
  await fileService.downloadFile(url: 'https://example.com/nonexistent.pdf');
} catch (e) {
  if (e is FileDownloadException) {
    print('Download failed: ${e.message}');
    // Check if recoverable
    if (e.isRecoverable) {
      // Retry logic
    }
  }
}
```

#### `FileNotFoundException`
Thrown when attempting to operate on non-existent files.

```dart
try {
  await fileService.openFile('/nonexistent/file.pdf');
} catch (e) {
  if (e is FileNotFoundException) {
    print('File not found: ${e.message}');
  }
}
```

#### `FilePermissionException`
Thrown when lacking necessary file system permissions.

```dart
try {
  await fileService.deleteFile('/system/protected/file.dat');
} catch (e) {
  if (e is FilePermissionException) {
    print('Permission denied: ${e.message}');
    // Request permissions or show user guidance
  }
}
```

#### `FileOpenException`
Thrown when file cannot be opened by the system.

```dart
try {
  await fileService.openFile('/path/to/corrupted.file');
} catch (e) {
  if (e is FileOpenException) {
    print('Cannot open file: ${e.message}');
  }
}
```

### Error Information

All file exceptions provide detailed information:

```dart
catch (e) {
  if (e is FileException) {
    print('Error: ${e.message}');
    print('Code: ${e.code}');
    print('Severity: ${e.severity}');
    print('Recoverable: ${e.isRecoverable}');
    print('Details: ${e.toMap()}');
  }
}
```

## Platform Support

### Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ⚠️ Web (limited functionality)

### Platform-Specific Features

#### Mobile (Android/iOS)
- Downloads to accessible system directory
- Automatic MIME type detection
- System file opening integration

#### Desktop (Windows/macOS/Linux)
- Downloads to user's Downloads folder
- Cross-platform file opening commands
- Full file system access

#### Web
- Limited to browser download capabilities
- No direct file system access
- Downloads go to browser's default location

## Best Practices

### 1. Always Initialize and Dispose

```dart
final fileService = FileServiceImpl(appName: 'MyApp');
try {
  await fileService.initialize();
  // Use the service
} finally {
  await fileService.dispose();
}
```

### 2. Handle All Exception Types

```dart
try {
  final metadata = await fileService.downloadFile(url: url);
} on InvalidFileUrlException catch (e) {
  // Handle invalid URL
} on FileDownloadException catch (e) {
  // Handle download failure
} on FilePermissionException catch (e) {
  // Handle permission issues
} catch (e) {
  // Handle unexpected errors
}
```

### 3. Use Subfolders for Organization

```dart
// Organize by file type
await fileService.downloadFile(
  url: pdfUrl, 
  subfolder: 'documents',
);

await fileService.downloadFile(
  url: imageUrl, 
  subfolder: 'images',
);
```

### 4. Monitor Storage Usage

```dart
// Check storage usage periodically
final totalUsage = await fileService.getTotalStorageUsage();
if (totalUsage > maxAllowedBytes) {
  // Clean up old files
  await _cleanupOldFiles();
}
```

### 5. Provide User Feedback

```dart
await fileService.downloadFile(
  url: url,
  onProgress: (progress) {
    // Update UI with progress
    updateProgressBar(progress.progressPercentage);
    updateSpeedLabel(progress.formattedSpeed);
  },
);
```

## Examples

### Complete Download Example

```dart
import 'package:abdalsalam_logic_flutter/abdalsalam_logic_flutter.dart';

class FileDownloadManager {
  late final FileService _fileService;
  
  Future<void> initialize() async {
    _fileService = FileServiceImpl(appName: 'MyApp');
    await _fileService.initialize();
  }
  
  Future<FileMetadata> downloadDocument({
    required String url,
    required String category,
    Function(double)? onProgress,
  }) async {
    try {
      return await _fileService.downloadFile(
        url: url,
        subfolder: category,
        onProgress: onProgress != null 
          ? (progress) => onProgress(progress.progressPercentage)
          : null,
      );
    } catch (e) {
      if (e is InvalidFileUrlException) {
        throw Exception('Invalid download URL provided');
      } else if (e is FileDownloadException) {
        throw Exception('Download failed: ${e.message}');
      }
      rethrow;
    }
  }
  
  Future<List<FileMetadata>> getUserDocuments() async {
    return await _fileService.listFiles(subfolder: 'documents');
  }
  
  Future<void> openDocument(FileMetadata metadata) async {
    final opened = await _fileService.openFile(metadata.absolutePath);
    if (!opened) {
      throw Exception('Unable to open ${metadata.fileName}');
    }
  }
  
  Future<void> cleanup() async {
    // Delete files older than 30 days
    final allFiles = await _fileService.listFiles();
    final cutoffDate = DateTime.now().subtract(Duration(days: 30));
    
    for (final file in allFiles) {
      if (file.downloadTimestamp.isBefore(cutoffDate)) {
        await _fileService.deleteFile(file.absolutePath);
      }
    }
  }
  
  Future<void> dispose() async {
    await _fileService.dispose();
  }
}
```

### Storage Analytics Example

```dart
class StorageAnalytics {
  final FileService _fileService;
  
  StorageAnalytics(this._fileService);
  
  Future<Map<String, dynamic>> getStorageReport() async {
    final totalUsage = await _fileService.getTotalStorageUsage();
    final subfolders = await _fileService.getSubfolders();
    final allFiles = await _fileService.listFiles();
    
    final subfolderUsage = <String, int>{};
    for (final subfolder in subfolders) {
      subfolderUsage[subfolder] = 
        await _fileService.getTotalStorageUsage(subfolder: subfolder);
    }
    
    return {
      'totalFiles': allFiles.length,
      'totalSizeBytes': totalUsage,
      'totalSizeFormatted': _formatBytes(totalUsage),
      'subfolders': subfolders.length,
      'subfolderUsage': subfolderUsage,
      'largestFile': _findLargestFile(allFiles),
      'oldestFile': _findOldestFile(allFiles),
      'mostCommonType': _findMostCommonType(allFiles),
    };
  }
  
  FileMetadata? _findLargestFile(List<FileMetadata> files) {
    if (files.isEmpty) return null;
    return files.reduce((a, b) => 
      a.sizeInBytes > b.sizeInBytes ? a : b);
  }
  
  FileMetadata? _findOldestFile(List<FileMetadata> files) {
    if (files.isEmpty) return null;
    return files.reduce((a, b) => 
      a.downloadTimestamp.isBefore(b.downloadTimestamp) ? a : b);
  }
  
  String? _findMostCommonType(List<FileMetadata> files) {
    final typeCount = <String, int>{};
    for (final file in files) {
      final ext = file.fileExtension ?? 'unknown';
      typeCount[ext] = (typeCount[ext] ?? 0) + 1;
    }
    
    if (typeCount.isEmpty) return null;
    return typeCount.entries
      .reduce((a, b) => a.value > b.value ? a : b)
      .key;
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
```

### Progress Tracking Widget Example

```dart
import 'package:flutter/material.dart';

class DownloadProgressWidget extends StatefulWidget {
  final String url;
  final FileService fileService;
  
  const DownloadProgressWidget({
    Key? key,
    required this.url,
    required this.fileService,
  }) : super(key: key);
  
  @override
  _DownloadProgressWidgetState createState() => _DownloadProgressWidgetState();
}

class _DownloadProgressWidgetState extends State<DownloadProgressWidget> {
  double _progress = 0.0;
  String _status = 'Starting download...';
  String _speed = '';
  bool _isDownloading = false;
  
  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Downloading...';
    });
    
    try {
      final metadata = await widget.fileService.downloadFile(
        url: widget.url,
        onProgress: (progress) {
          setState(() {
            _progress = progress.progressPercentage / 100;
            _speed = progress.formattedSpeed;
            _status = 'Downloading... ${progress.progressPercentage.toStringAsFixed(1)}%';
          });
        },
      );
      
      setState(() {
        _isDownloading = false;
        _progress = 1.0;
        _status = 'Downloaded: ${metadata.fileName}';
        _speed = '';
      });
      
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _progress = 0.0;
        _status = 'Download failed: ${e.toString()}';
        _speed = '';
      });
    }
  }
  
  void _cancelDownload() {
    if (_isDownloading) {
      final cancelled = widget.fileService.cancelDownload(widget.url);
      if (cancelled) {
        setState(() {
          _isDownloading = false;
          _progress = 0.0;
          _status = 'Download cancelled';
          _speed = '';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_status),
            SizedBox(height: 8),
            LinearProgressIndicator(value: _progress),
            if (_speed.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Speed: $_speed'),
            ],
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isDownloading ? null : _startDownload,
                  child: Text('Download'),
                ),
                ElevatedButton(
                  onPressed: _isDownloading ? _cancelDownload : null,
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues

#### Download Fails Immediately
- Check URL validity and network connectivity
- Ensure URL uses HTTP/HTTPS protocol
- Verify server responds with valid content

#### Permission Denied Errors
- Check app has storage permissions on Android
- Verify Downloads directory is accessible
- Try alternative storage locations

#### Files Not Visible in System
- Ensure files are in Downloads/AppName directory
- Check file permissions and ownership
- Refresh system file manager

#### Opening Files Fails
- Verify file is not corrupted
- Check system has appropriate app installed
- Try different file types

### Debugging

Enable detailed error logging:

```dart
final fileService = FileServiceImpl(appName: 'MyApp');

try {
  await fileService.downloadFile(url: problematicUrl);
} catch (e) {
  if (e is FileException) {
    print('Error details: ${e.toMap()}');
    print('Stack trace: ${e.stackTrace}');
  }
}
```

## Migration Guide

### From Basic File Operations

If migrating from basic file operations:

```dart
// Old way
final file = File('/path/to/file');
await file.writeAsBytes(bytes);

// New way  
final metadata = await fileService.downloadFile(url: url);
```

### From Other Download Libraries

Replace existing download code:

```dart
// Old download library
await downloadFile(url, destinationPath);

// New service
final metadata = await fileService.downloadFile(
  url: url,
  subfolder: 'downloads',
  onProgress: (progress) {
    // Handle progress
  },
);
```

---

**Package**: `abdalsalam_logic_flutter`  
**Documentation Version**: 1.0.0  
**Last Updated**: February 2026