import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'main_page.dart';
import 'dart:developer' as developer;

class ImagePage extends StatefulWidget {
  final DemoImage image;
  final bool enableAdaptiveLoading;
  final bool enableOfflineMode;

  const ImagePage({
    super.key,
    required this.image,
    this.enableAdaptiveLoading = true,
    this.enableOfflineMode = true,
  });

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  bool _isLoading = false;
  bool _isHighQuality = false;
  final CacheProvider _cacheProvider = CacheProvider();

  @override
  void initState() {
    super.initState();
    _checkImageCache();
  }

  Future<void> _checkImageCache() async {
    final isCached = await ImageUtils.isImageCached(widget.image.url);
    developer.log('Image cached status: $isCached');
  }

  Future<void> _toggleImageQuality() async {
    setState(() {
      _isLoading = true;
      _isHighQuality = !_isHighQuality;
    });

    try {
      if (_isHighQuality) {
        await _cacheProvider.getFile(widget.image.url);
      }
    } catch (e) {
      developer.log('Error loading high quality image: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
          if (widget.enableAdaptiveLoading)
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusChip(
            label: 'Adaptive Loading',
            value: widget.enableAdaptiveLoading,
            icon: Icons.auto_awesome,
          ),
          _buildStatusChip(
            label: 'Offline Mode',
            value: widget.enableOfflineMode,
            icon: Icons.offline_bolt,
          ),
          _buildStatusChip(
            label: 'High Quality',
            value: _isHighQuality,
            icon: Icons.high_quality,
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
          errorWidget: _buildErrorWidget(),
        ),
      ),
    );
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _toggleImageQuality,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
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
          Text(
            widget.image.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            widget.image.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () async {
                  await _cacheProvider.clearCache(widget.image.url);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image cache cleared'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear Cache'),
              ),
              if (widget.enableAdaptiveLoading)
                TextButton.icon(
                  onPressed: _toggleImageQuality,
                  icon: Icon(_isHighQuality ? Icons.hd : Icons.sd),
                  label:
                      Text(_isHighQuality ? 'Switch to Low' : 'Switch to High'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
