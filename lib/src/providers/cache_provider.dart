import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

/// Provider class for managing image caching
class CacheProvider {
  static final CacheProvider _instance = CacheProvider._internal();
  
  factory CacheProvider() {
    return _instance;
  }

  CacheProvider._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Get file from cache or download
  Future<File> getFile(String url, {Duration? maxAge}) async {
    return await _cacheManager.getSingleFile(
      url,
      key: url,
    );
  }

  /// Clear cache for specific URL
  Future<void> clearCache(String url) async {
    await _cacheManager.removeFile(url);
  }

  /// Clear all cached images
  Future<void> clearAllCache() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    final appDir = await getTemporaryDirectory();
    final cacheDir = '${appDir.path}/libCachedImageData';
    final dir = Directory(cacheDir);
    if (!await dir.exists()) return 0;
    
    int size = 0;
    await for (final file in dir.list(recursive: true)) {
      if (file is File) {
        size += await file.length();
      }
    }
    return size;
  }
} 