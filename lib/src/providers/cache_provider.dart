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
    return await _cacheManager.getSingleFile(
      url,
      key: _cacheManager.getCacheKey(url),
    );
  }

  /// Clear cache for specific URL
  Future<void> clearCache(String url) async {
    await _cacheManager.removeFile(_cacheManager.getCacheKey(url));
  }

  /// Clear all cached images
  Future<void> clearAllCache() async {
    await _cacheManager.clearCache();
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    return await _cacheManager.getCacheSize();
  }

  /// Get cache path
  Future<String> getCachePath() async {
    return await _cacheManager.getCachePath();
  }
}
