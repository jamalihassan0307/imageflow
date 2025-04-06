import 'package:flutter/widgets.dart';

/// Configuration options for the LazyCacheImage widget
class ImageConfig {
  /// The URL of the image to load
  final String imageUrl;
  
  /// How to inscribe the image into the space allocated during layout
  final BoxFit fit;
  
  /// Widget to show while the image is loading
  final Widget? placeholder;
  
  /// Widget to show if there is an error loading the image
  final Widget? errorWidget;
  
  /// Whether to enable adaptive quality loading
  final bool enableAdaptiveLoading;
  
  /// Duration to keep the image in cache
  final Duration cacheDuration;
  
  /// Maximum width to load the image at
  final double? maxWidth;
  
  /// Maximum height to load the image at
  final double? maxHeight;

  const ImageConfig({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableAdaptiveLoading = true,
    this.cacheDuration = const Duration(days: 30),
    this.maxWidth,
    this.maxHeight,
  });

  /// Creates a copy of this configuration with the given fields replaced
  ImageConfig copyWith({
    String? imageUrl,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
    bool? enableAdaptiveLoading,
    Duration? cacheDuration,
    double? maxWidth,
    double? maxHeight,
  }) {
    return ImageConfig(
      imageUrl: imageUrl ?? this.imageUrl,
      fit: fit ?? this.fit,
      placeholder: placeholder ?? this.placeholder,
      errorWidget: errorWidget ?? this.errorWidget,
      enableAdaptiveLoading: enableAdaptiveLoading ?? this.enableAdaptiveLoading,
      cacheDuration: cacheDuration ?? this.cacheDuration,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
    );
  }
} 