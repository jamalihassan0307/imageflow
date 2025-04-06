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
  Future<FileInfo> getFile(String url, {Duration? maxAge}) async {
    return await _cacheManager.getFileFromCache(url) ??
        await _cacheManager.downloadFile(
          url,
          key: url,
          maxAge: maxAge ?? const Duration(days: 30),
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
    final cacheDir = await _cacheManager.getFilePath();
    // Implementation to calculate cache size
    return 0; // Placeholder
  }
} 