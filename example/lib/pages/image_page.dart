import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'main_page.dart';
import 'dart:developer' as developer;
import 'package:imageflow/src/providers/custom_cache_manager.dart';

class ImagePage extends StatefulWidget {
  final DemoImage image;
  final bool enableAdaptiveLoading;
  final bool enableOfflineMode;
  final bool isOffline;

  const ImagePage({
    super.key,
    required this.image,
    this.enableAdaptiveLoading = true,
    this.enableOfflineMode = true,
    this.isOffline = false,
  });

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  bool _isLoading = false;
  bool _isHighQuality = false;
  bool _isCached = false;
  bool _isPermanentlyCached = false;
  final CacheProvider _cacheProvider = CacheProvider();

  @override
  void initState() {
    super.initState();
    _checkImageCache();
  }

  Future<void> _checkImageCache() async {
    final isCached = await ImageUtils.isImageCached(widget.image.url);
    final isPermanent =
        await ImageUtils.isImageCached(widget.image.url, checkPermanent: true);
    if (mounted) {
      setState(() {
        _isCached = isCached;
        _isPermanentlyCached = isPermanent;
      });
    }
    developer.log('Image cached status: $isCached (permanent: $isPermanent)');
  }

  Future<void> _toggleImageQuality() async {
    if (widget.isOffline && !_isCached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot load image in offline mode - Image not cached'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (widget.isOffline && !await ImageUtils.hasInternetConnection()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isHighQuality) {
        // Only try to cache when switching to high quality
        await _cacheProvider.getFile(widget.image.url);
        await _checkImageCache();
      }

      if (mounted) {
        setState(() {
          _isHighQuality = !_isHighQuality;
        });
      }
    } catch (e) {
      developer.log('Error loading high quality image: $e');
      if (mounted) {
        setState(() {
          _isHighQuality = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading high quality image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.image.title),
        actions: [
          if (widget.enableAdaptiveLoading && (!widget.isOffline || _isCached))
            IconButton(
              icon: Icon(_isHighQuality ? Icons.hd : Icons.sd),
              onPressed: _isLoading ? null : _toggleImageQuality,
              tooltip: 'Toggle image quality',
            ),
        ],
      ),
      body: Column(
        children: [
          _buildImageStatusBar(),
          Expanded(
            child: _buildImage(),
          ),
          _buildImageInfo(),
        ],
      ),
    );
  }

  Widget _buildImageStatusBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
      child: Column(
        children: [
          if (widget.isOffline)
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.orange[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Offline Mode',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatusChip(
                  label: 'Adaptive',
                  value: widget.enableAdaptiveLoading,
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  label: _isPermanentlyCached ? 'Saved' : 'Cached',
                  value: _isCached,
                  icon: _isPermanentlyCached ? Icons.save : Icons.cached,
                ),
                const SizedBox(width: 8),
                _buildStatusChip(
                  label: 'HD',
                  value: _isHighQuality,
                  icon: Icons.high_quality,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool value,
    required IconData icon,
  }) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: value ? Colors.green : Colors.grey,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: value ? Colors.green : Colors.grey,
          fontSize: 12,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }

  Widget _buildImage() {
    return Hero(
      tag: widget.image.url,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: LazyCacheImage(
          imageUrl: widget.image.url,
          lowResUrl: widget.enableAdaptiveLoading && !_isHighQuality
              ? ImageUtils.getLowQualityUrl(widget.image.url)
              : null,
          fit: BoxFit.contain,
          enableAdaptiveLoading: widget.enableAdaptiveLoading,
          enableOfflineMode: widget.enableOfflineMode,
          placeholder: _buildLoadingIndicator(),
          errorWidget: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isOffline ? Icons.cloud_off : Icons.error_outline,
                  color: widget.isOffline ? Colors.orange : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isOffline && !_isCached
                      ? 'Image not available offline\nNot cached'
                      : 'Failed to load image',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: widget.isOffline ? Colors.orange : Colors.red,
                      ),
                ),
                const SizedBox(height: 8),
                if (!widget.isOffline || _isCached)
                  ElevatedButton.icon(
                    onPressed: _retryLoading,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _retryLoading() async {
    if (widget.isOffline && !_isCached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot load image in offline mode - Image not cached'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _checkImageCache();
      if (!_isCached && !widget.isOffline) {
        await _cacheProvider.getFile(widget.image.url);
        await _checkImageCache();
      }
    } catch (e) {
      developer.log('Error retrying image load: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            _isHighQuality ? 'Loading High Quality' : 'Loading Preview',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildImageInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.image.title,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isCached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPermanentlyCached ? Icons.save : Icons.cached,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isPermanentlyCached ? 'Saved' : 'Cached',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            widget.image.description,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await _cacheProvider.clearCache(widget.image.url);
                    await _checkImageCache();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Image cache cleared'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label:
                      const Text('Clear Cache', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isPermanentlyCached)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final file =
                            await _cacheProvider.getFile(widget.image.url);
                        await CustomCacheManager()
                            .storeFileInPermanentCache(widget.image.url, file);
                        await _checkImageCache();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Image saved for offline use'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving image: $e'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.save_alt, size: 18),
                    label: const Text('Save Offline',
                        style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                if (widget.enableAdaptiveLoading &&
                    (!widget.isOffline || _isCached)) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _toggleImageQuality,
                    icon: Icon(_isHighQuality ? Icons.hd : Icons.sd, size: 18),
                    label: Text(
                      _isHighQuality ? 'Switch to Low' : 'Switch to High',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
