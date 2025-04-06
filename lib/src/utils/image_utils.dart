// ignore_for_file: unrelated_type_equality_checks

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import '../providers/custom_cache_manager.dart';
import 'dart:io';

/// Utility functions for image handling
class ImageUtils {
  static final CustomCacheManager _cacheManager = CustomCacheManager();

  /// Check if device is connected to the internet
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.ethernet;
  }

  /// Calculate optimal image dimensions based on screen size
  static Size calculateOptimalDimensions(
    BuildContext context,
    double? maxWidth,
    double? maxHeight,
  ) {
    final screenSize = MediaQuery.of(context).size;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    final optimalWidth = maxWidth ?? screenSize.width;
    final optimalHeight = maxHeight ?? screenSize.height;

    return Size(
      optimalWidth * devicePixelRatio,
      optimalHeight * devicePixelRatio,
    );
  }

  /// Generate low quality image URL (if supported by image provider)
  static String getLowQualityUrl(String originalUrl) {
    // Implementation depends on image provider's URL structure
    // This is a placeholder implementation
    if (originalUrl.contains('?')) {
      return '$originalUrl&quality=low';
    }
    return '$originalUrl?quality=low';
  }

  /// Check if URL points to an SVG image
  static bool isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg');
  }

  /// Check if URL points to a GIF image
  static bool isGifUrl(String url) {
    return url.toLowerCase().endsWith('.gif');
  }

  /// Prefetch a list of images
  static Future<void> prefetchImages(List<String> urls) async {
    for (final url in urls) {
      try {
        await _cacheManager.getSingleFile(url);
      } catch (e) {
        // Silently continue if prefetch fails
        continue;
      }
    }
  }

  /// Check if image is available in cache
  static Future<bool> isImageCached(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(
      _cacheManager.getCacheKey(url),
    );
    return fileInfo != null;
  }

  /// Get cached file if available
  static Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(
        _cacheManager.getCacheKey(url),
      );
      if (fileInfo != null) {
        return fileInfo.file;
      }
    } catch (e) {
      // Return null if any error occurs
    }
    return null;
  }
}
