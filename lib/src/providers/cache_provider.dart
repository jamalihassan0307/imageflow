import 'dart:io';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:path_provider/path_provider.dart';
import 'custom_cache_manager.dart';

/// Provider class for managing image caching
class CacheProvider {
  static final CacheProvider _instance = CacheProvider._internal();

  factory CacheProvider() {
    return _instance;
  }

  CacheProvider._internal();

  final CustomCacheManager _cacheManager = CustomCacheManager();

  /// Get file from cache or download
  Future<File> getFile(String url, {Duration? maxAge}) async {
    try {
      return await _cacheManager.getSingleFile(
        url,
        key: _cacheManager.getCacheKey(url),
      );
    } catch (e) {
      // If first attempt fails, try clearing the cache for this URL and retry
      await _cacheManager.removeFile(_cacheManager.getCacheKey(url));
      return await _cacheManager.getSingleFile(
        url,
        key: _cacheManager.getCacheKey(url),
      );
    }
  }

  /// Clear cache for specific URL
  Future<void> clearCache(String url) async {
    try {
      await _cacheManager.removeFile(_cacheManager.getCacheKey(url));
    } catch (e) {
      // Handle error silently
      rethrow;
    }
  }

  /// Clear all cached images
  Future<void> clearAllCache() async {
    try {
      await _cacheManager.clearCache();
    } catch (e) {
      // Handle error silently
      rethrow;
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      return await _cacheManager.getCacheSize();
    } catch (e) {
      return 0;
    }
  }

  /// Get cache path
  Future<String> getCachePath() async {
    try {
      return await _cacheManager.getCachePath();
    } catch (e) {
      final tempDir = await Directory.systemTemp.createTemp('imageflow_cache');
      return tempDir.path;
    }
  }

  /// Check if a file exists in cache
  Future<bool> hasValidCache(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(
        _cacheManager.getCacheKey(url),
      );
      return fileInfo != null && await fileInfo.file.exists();
    } catch (e) {
      return false;
    }
  }
}
