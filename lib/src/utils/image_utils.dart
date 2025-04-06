import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';

/// Utility functions for image handling
class ImageUtils {
  /// Check if device is connected to the internet
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
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
}
