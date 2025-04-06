// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CustomCacheManager extends CacheManager {
  static const key = 'imageFlowCache';
  static const permanentKey = 'imageFlowPermanentCache';
  static const maxAgeCacheObject = Duration(days: 30);
  static const maxNrOfCacheObjects = 1000;

  static CustomCacheManager? _instance;

  factory CustomCacheManager() {
    _instance ??= CustomCacheManager._();
    return _instance!;
  }

  CustomCacheManager._()
      : super(Config(
          key,
          stalePeriod: maxAgeCacheObject,
          maxNrOfCacheObjects: maxNrOfCacheObjects,
          repo: JsonCacheInfoRepository(databaseName: key),
          fileService: HttpFileService(),
        ));

  Future<String> getCachePath({bool permanent = false}) async {
    final directory = permanent
        ? await getApplicationDocumentsDirectory()
        : await getTemporaryDirectory();
    return p.join(directory.path, permanent ? permanentKey : key);
  }

  Future<void> clearCache({bool permanent = false}) async {
    try {
      await emptyCache();
      final directory = Directory(await getCachePath(permanent: permanent));
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      // Handle error silently but ensure the cache is cleared
      try {
        final directory = Directory(await getCachePath(permanent: permanent));
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } catch (_) {
        // Ignore secondary error
      }
    }
  }

  Future<int> getCacheSize({bool permanent = false}) async {
    try {
      final directory = Directory(await getCachePath(permanent: permanent));
      if (!await directory.exists()) return 0;

      int size = 0;
      await for (final file in directory.list(recursive: true)) {
        if (file is File) {
          try {
            size += await file.length();
          } catch (_) {
            // Skip files that can't be read
            continue;
          }
        }
      }
      return size;
    } catch (_) {
      return 0;
    }
  }

  String getCacheKey(String url, {bool permanent = false}) {
    final uri = Uri.tryParse(url);
    final prefix = permanent ? permanentKey : key;
    if (uri == null) return '${prefix}_$url';
    return '${prefix}_${uri.host}${uri.path}';
  }

  Future<File?> getFileFromPermanentCache(String url) async {
    try {
      final cacheKey = getCacheKey(url, permanent: true);
      final cachePath = await getCachePath(permanent: true);
      final file = File(p.join(cachePath, cacheKey));
      if (await file.exists()) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  Future<void> storeFileInPermanentCache(String url, File file) async {
    try {
      final cacheKey = getCacheKey(url, permanent: true);
      final cachePath = await getCachePath(permanent: true);
      final directory = Directory(cachePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      final permanentFile = File(p.join(cachePath, cacheKey));
      await file.copy(permanentFile.path);
    } catch (_) {}
  }
}
