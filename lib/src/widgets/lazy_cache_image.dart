import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// import '../models/image_config.dart';
import '../utils/image_utils.dart';
// import '../providers/cache_provider.dart';
import '../providers/custom_cache_manager.dart';

/// A widget that displays a network image with lazy loading and caching capabilities
class LazyCacheImage extends StatefulWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// How to inscribe the image into the space allocated during layout
  final BoxFit fit;

  /// Widget to show while the image is loading
  final Widget? placeholder;

  /// Widget to show if there is an error loading the image
  final Widget? errorWidget;

  /// Whether to enable adaptive quality loading
  final bool enableAdaptiveLoading;

  /// Maximum width to load the image at
  final double? maxWidth;

  /// Maximum height to load the image at
  final double? maxHeight;

  /// Duration to keep the image in cache
  final Duration cacheDuration;

  /// Visibility fraction needed to start loading the image (0.0 to 1.0)
  final double visibilityFraction;

  const LazyCacheImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableAdaptiveLoading = true,
    this.maxWidth,
    this.maxHeight,
    this.cacheDuration = const Duration(days: 30),
    this.visibilityFraction = 0.1,
  });

  @override
  State<LazyCacheImage> createState() => _LazyCacheImageState();
}

class _LazyCacheImageState extends State<LazyCacheImage> {
  bool _isVisible = false;
  bool _hasLoaded = false;
  final CustomCacheManager _cacheManager = CustomCacheManager();

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('image-${widget.imageUrl}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: _isVisible ? _buildImage() : _buildPlaceholder(context),
    );
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _hasLoaded) return;

    final visibleFraction = info.visibleFraction;
    final isVisible = visibleFraction > widget.visibilityFraction;

    if (isVisible != _isVisible) {
      setState(() {
        _isVisible = isVisible;
        if (_isVisible) {
          _hasLoaded = true;
        }
      });
    }
  }

  Widget _buildImage() {
    if (ImageUtils.isSvgUrl(widget.imageUrl)) {
      return _buildSvgImage(context);
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      cacheManager: _cacheManager,
      maxWidthDiskCache: widget.maxWidth?.toInt(),
      maxHeightDiskCache: widget.maxHeight?.toInt(),
      key: ValueKey(widget.imageUrl),
      progressIndicatorBuilder: widget.placeholder == null 
          ? (context, url, progress) => _buildProgressIndicator(context, progress)
          : null,
      placeholder: widget.placeholder != null 
          ? (context, url) => widget.placeholder!
          : null,
      errorWidget: (context, url, error) => _buildErrorWidget(context, error),
    );
  }

  Widget _buildSvgImage(BuildContext context) {
    return SvgPicture.network(
      widget.imageUrl,
      fit: widget.fit,
      placeholderBuilder: (context) => _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (widget.placeholder != null) return widget.placeholder!;
    
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    if (widget.errorWidget != null) return widget.errorWidget!;

    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, DownloadProgress progress) {
    return Center(
      child: CircularProgressIndicator(
        value: progress.progress,
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
      ),
    );
  }
} 