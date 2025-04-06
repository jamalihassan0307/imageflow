// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;

class CustomCacheManager extends CacheManager {
  static const key = 'imageFlowCache';
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

  Future<String> getCachePath() async {
    final directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }

  Future<void> clearCache() async {
    try {
      await emptyCache();
      final directory = Directory(await getCachePath());
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    } catch (e) {
      // Handle error silently but ensure the cache is cleared
      try {
        final directory = Directory(await getCachePath());
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } catch (_) {
        // Ignore secondary error
      }
    }
  }

  Future<int> getCacheSize() async {
    try {
      final directory = Directory(await getCachePath());
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

  String getCacheKey(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '${key}_$url';
    return '${key}_${uri.host}${uri.path}';
  }

  @override
  Future<FileInfo> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
  }) async {
    try {
      return await super.downloadFile(
        url,
        key: key,
        authHeaders: authHeaders,
        force: force,
      );
    } catch (e) {
      // If download fails, try to clear cache for this URL and retry once
      await removeFile(getCacheKey(url));
      return await super.downloadFile(
        url,
        key: key,
        authHeaders: authHeaders,
        force: true,
      );
    }
  }
}
