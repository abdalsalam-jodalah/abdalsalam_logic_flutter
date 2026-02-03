// lib/examples/file_handling_example.dart

import 'dart:io';
import '../abdalsalam_logic_flutter.dart';

void main() async {
  await demonstrateFileHandling();
}

Future<void> demonstrateFileHandling() async {
  final fileService = FileServiceImpl(appName: 'MyAwesomeApp');
  
  try {
    await fileService.initialize();
    print('✅ File service initialized successfully');
    print('📁 Downloads path: ${await fileService.getDownloadsPath()}');

    await _downloadFileExample(fileService);
    await _fileManagementExample(fileService);
    await _storageAnalyticsExample(fileService);
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    if (e is FileException) {
      print('📋 Error details: ${e.toMap()}');
    }
    print('🔍 Stack trace: $stackTrace');
  } finally {
    await fileService.dispose();
    print('🧹 File service disposed');
  }
}

Future<void> _downloadFileExample(FileService fileService) async {
  print('\n🌐 === FILE DOWNLOAD EXAMPLE ===');
  
  const pdfUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
  
  try {
    print('⬇️  Starting download from: $pdfUrl');
    
    final metadata = await fileService.downloadFile(
      url: pdfUrl,
      subfolder: 'documents',
      onProgress: (progress) {
        print('📊 Progress: ${progress.progressPercentage.toStringAsFixed(1)}% '
              '(${progress.formattedSpeed})');
      },
    );
    
    print('✅ Download completed:');
    print('   📄 File: ${metadata.fileName}');
    print('   📍 Path: ${metadata.absolutePath}');
    print('   📏 Size: ${metadata.formattedSize}');
    print('   🕒 Downloaded: ${metadata.downloadTimestamp}');
    
    final canOpen = await FileOpenerImpl().canOpenFile(metadata.absolutePath);
    print('   👀 Can open: $canOpen');
    
    if (canOpen) {
      final opened = await fileService.openFile(metadata.absolutePath);
      print('   🚀 Opened successfully: $opened');
    }
    
  } catch (e) {
    if (e is InvalidFileUrlException) {
      print('❌ Invalid URL provided');
    } else if (e is FileDownloadException) {
      print('❌ Download failed: ${e.message}');
    } else {
      print('❌ Unexpected error: $e');
    }
  }
}

Future<void> _fileManagementExample(FileService fileService) async {
  print('\n📁 === FILE MANAGEMENT EXAMPLE ===');
  
  try {
    final allFiles = await fileService.listFiles();
    print('📋 Total files: ${allFiles.length}');
    
    for (final file in allFiles.take(3)) {
      print('   📄 ${file.fileName} (${file.formattedSize})');
      
      final exists = await fileService.fileExists(file.absolutePath);
      print('   ✅ Exists: $exists');
      
      final info = await fileService.getFileInfo(file.absolutePath);
      if (info != null) {
        print('   📊 Info: ${info.mimeType ?? 'Unknown type'}');
      }
    }
    
    final subfolders = await fileService.getSubfolders();
    print('\n📂 Subfolders: ${subfolders.join(', ')}');
    
    for (final subfolder in subfolders.take(2)) {
      final subfolderFiles = await fileService.listFiles(subfolder: subfolder);
      print('   📂 $subfolder: ${subfolderFiles.length} files');
    }
    
  } catch (e) {
    print('❌ File management error: $e');
  }
}

Future<void> _storageAnalyticsExample(FileService fileService) async {
  print('\n📊 === STORAGE ANALYTICS EXAMPLE ===');
  
  try {
    final totalUsage = await fileService.getTotalStorageUsage();
    print('💾 Total storage usage: ${_formatBytes(totalUsage)}');
    
    final subfolders = await fileService.getSubfolders();
    for (final subfolder in subfolders) {
      final usage = await fileService.getTotalStorageUsage(subfolder: subfolder);
      final files = await fileService.listFiles(subfolder: subfolder);
      print('   📂 $subfolder: ${_formatBytes(usage)} (${files.length} files)');
    }
    
    final activeDownloads = fileService.getActiveDownloads();
    print('\n⬇️  Active downloads: ${activeDownloads.length}');
    for (final url in activeDownloads) {
      print('   🌐 $url');
    }
    
  } catch (e) {
    print('❌ Analytics error: $e');
  }
}

Future<void> _demonstrateErrorHandling() async {
  print('\n🚨 === ERROR HANDLING EXAMPLES ===');
  
  final fileService = FileServiceImpl(appName: 'TestApp');
  await fileService.initialize();
  
  try {
    await fileService.downloadFile(url: 'invalid-url');
  } catch (e) {
    if (e is InvalidFileUrlException) {
      print('✅ Caught invalid URL error: ${e.message}');
    }
  }
  
  try {
    await fileService.openFile('/nonexistent/file.pdf');
  } catch (e) {
    if (e is FileNotFoundException) {
      print('✅ Caught file not found error: ${e.message}');
    }
  }
  
  try {
    await fileService.deleteFile('/protected/system/file.dat');
  } catch (e) {
    if (e is FilePermissionException) {
      print('✅ Caught permission error: ${e.message}');
    }
  }
  
  await fileService.dispose();
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

void _demonstrateProgressTracking() {
  print('\n📈 === PROGRESS TRACKING EXAMPLE ===');
  
  void onProgress(FileDownloadProgress progress) {
    print('📊 Download Progress:');
    print('   📈 ${progress.progressPercentage.toStringAsFixed(1)}%');
    print('   💨 ${progress.formattedSpeed}');
    print('   ⏱️  Elapsed: ${progress.elapsedTime.inSeconds}s');
    print('   ⏳ Remaining: ${progress.estimatedTimeRemaining.inSeconds}s');
    print('   📦 ${progress.bytesReceived}/${progress.totalBytes} bytes');
  }
}