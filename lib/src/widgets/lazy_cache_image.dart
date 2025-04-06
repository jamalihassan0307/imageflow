import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../utils/image_utils.dart';
import '../providers/custom_cache_manager.dart';

/// A widget that displays a network image with lazy loading and caching capabilities
class LazyCacheImage extends StatefulWidget {
  /// The URL of the image to display
  final String imageUrl;

  /// Low resolution version of the image URL
  final String? lowResUrl;

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

  /// Whether to enable offline mode support
  final bool enableOfflineMode;

  /// Callback when retry is pressed
  final VoidCallback? onRetry;

  const LazyCacheImage({
    super.key,
    required this.imageUrl,
    this.lowResUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableAdaptiveLoading = true,
    this.maxWidth,
    this.maxHeight,
    this.cacheDuration = const Duration(days: 30),
    this.visibilityFraction = 0.1,
    this.enableOfflineMode = true,
    this.onRetry,
  });

  @override
  State<LazyCacheImage> createState() => _LazyCacheImageState();
}

class _LazyCacheImageState extends State<LazyCacheImage>
    with AutomaticKeepAliveClientMixin {
  bool _isVisible = false;
  bool _hasLoaded = false;
  bool _hasError = false;
  bool _isLoadingHighRes = false;
  bool _isOffline = false;
  final CustomCacheManager _cacheManager = CustomCacheManager();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    _isOffline = !await ImageUtils.hasInternetConnection();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
          if (widget.enableAdaptiveLoading && widget.lowResUrl != null) {
            _loadHighResImage();
          }
        }
      });
    }
  }

  Future<void> _loadHighResImage() async {
    if (_isLoadingHighRes) return;
    _isLoadingHighRes = true;

    try {
      await _cacheManager.getSingleFile(widget.imageUrl);
      if (mounted) {
        setState(() {
          _isLoadingHighRes = false;
        });
      }
    } catch (e) {
      _isLoadingHighRes = false;
    }
  }

  Future<void> _retryLoading() async {
    if (!mounted) return;

    await _checkConnectivity();

    setState(() {
      _hasError = false;
      _hasLoaded = false;
      _isVisible = false;
      _isLoadingHighRes = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));

    if (mounted) {
      setState(() {
        _isVisible = true;
        _hasLoaded = true;
      });
    }

    widget.onRetry?.call();
  }

  Widget _buildImage() {
    if (_isOffline && widget.enableOfflineMode) {
      return _buildOfflineImage();
    }

    if (ImageUtils.isSvgUrl(widget.imageUrl)) {
      return _buildSvgImage(context);
    }

    final url = widget.enableAdaptiveLoading &&
            widget.lowResUrl != null &&
            !_isLoadingHighRes
        ? widget.lowResUrl!
        : widget.imageUrl;

    return CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit,
      cacheManager: _cacheManager,
      maxWidthDiskCache: widget.maxWidth?.toInt(),
      maxHeightDiskCache: widget.maxHeight?.toInt(),
      key: ValueKey('$url-${_hasError ? 'retry' : 'initial'}'),
      progressIndicatorBuilder: widget.placeholder == null
          ? (context, url, progress) =>
              _buildProgressIndicator(context, progress)
          : null,
      placeholder: widget.placeholder != null
          ? (context, url) => widget.placeholder!
          : null,
      errorWidget: (context, url, error) {
        _hasError = true;
        return _buildErrorWidget(context, error);
      },
    );
  }

  Widget _buildOfflineImage() {
    return FutureBuilder<File?>(
      future: ImageUtils.getCachedFile(widget.imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.file(
            snapshot.data!,
            fit: widget.fit,
          );
        }
        return _buildErrorWidget(context, 'No cached version available');
      },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            if (_isOffline && widget.enableOfflineMode) ...[
              const SizedBox(height: 8),
              const Text(
                'Offline Mode',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    if (widget.errorWidget != null) return widget.errorWidget!;

    return GestureDetector(
      onTap: _retryLoading,
      child: Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              _isOffline ? 'No internet connection' : 'Failed to load image',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _retryLoading,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    DownloadProgress progress,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.enableAdaptiveLoading &&
            widget.lowResUrl != null &&
            _isLoadingHighRes)
          const Positioned(
            top: 8,
            right: 8,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Loading HD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        Center(
          child: CircularProgressIndicator(
            value: progress.progress,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
