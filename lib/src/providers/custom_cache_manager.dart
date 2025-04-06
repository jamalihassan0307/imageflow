// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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
    await emptyCache();
  }

  Future<int> getCacheSize() async {
    final directory = Directory(await getCachePath());
    if (!await directory.exists()) return 0;

    int size = 0;
    await for (final file in directory.list(recursive: true)) {
      if (file is File) {
        size += await file.length();
      }
    }
    return size;
  }

  String getCacheKey(String url) {
    return '${key}_$url';
  }
}
