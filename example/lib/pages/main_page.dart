import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'image_page.dart';
import 'dart:developer' as developer;
import 'package:imageflow/src/providers/custom_cache_manager.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isGridView = true;
  bool _enableAdaptiveLoading = true;
  bool _enableOfflineMode = true;
  bool _isOffline = false;
  double _visibilityFraction = 0.1;
  final CacheProvider _cacheProvider = CacheProvider();
  Map<String, bool> _cachedImages = {};
  Map<String, bool> _permanentlyCachedImages = {};
  String _cacheSize = '0 MB';
  bool _isBatchCaching = false;

  @override
  void initState() {
    super.initState();
    _prefetchImages();
    _checkConnectivity();
    _updateCacheStatus();
    _updateCacheSize();
  }

  Future<void> _updateCacheSize() async {
    try {
      final size = await _cacheProvider.getCacheSize();
      if (mounted) {
        setState(() {
          _cacheSize = '${(size / 1024 / 1024).toStringAsFixed(2)} MB';
        });
      }
    } catch (e) {
      developer.log('Error getting cache size: $e');
    }
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await ImageUtils.hasInternetConnection();
    if (mounted) {
      setState(() {
        _isOffline = !hasConnection;
        if (_isOffline) {
          _enableOfflineMode = true;
        }
      });
    }
  }

  Future<void> _updateCacheStatus() async {
    try {
      for (final image in _demoImages) {
        final isCached = await ImageUtils.isImageCached(image.url);
        final isPermanent = await ImageUtils.isImageCached(image.url, checkPermanent: true);
        if (mounted) {
          setState(() {
            _cachedImages[image.url] = isCached;
            _permanentlyCachedImages[image.url] = isPermanent;
          });
        }
        developer.log('Cache status for ${image.url}: $isCached (permanent: $isPermanent)');
      }
    } catch (e) {
      developer.log('Error updating cache status: $e');
    }
  }

  Future<void> _prefetchImages() async {
    developer.log('Prefetching images...');
    try {
      await Future.wait(_demoImages.map((img) async {
        try {
          await ImageUtils.prefetchImages([img.url]);
          final isCached = await ImageUtils.isImageCached(img.url);
          final isPermanent = await ImageUtils.isImageCached(img.url, checkPermanent: true);
          if (mounted) {
            setState(() {
              _cachedImages[img.url] = isCached;
              _permanentlyCachedImages[img.url] = isPermanent;
            });
          }
          developer.log('Prefetched and cached: ${img.url} - Success: $isCached (permanent: $isPermanent)');
        } catch (e) {
          developer.log('Error prefetching image ${img.url}: $e');
        }
      }));
    } catch (e) {
      developer.log('Error during prefetch: $e');
    }
    await _updateCacheStatus();
    await _updateCacheSize();
    developer.log('Prefetching complete');
  }

  Future<void> _toggleOfflineMode(bool value) async {
    if (value) {
      // If enabling offline mode, check if we have internet first
      final hasConnection = await ImageUtils.hasInternetConnection();
      if (!hasConnection) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No internet connection available'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
    if (mounted) {
      setState(() {
        _enableOfflineMode = value;
        if (value) {
          _checkConnectivity();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ImageFlow Demo'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: 'Toggle view mode',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildNetworkStatus(),
          _buildControlPanel(),
          Expanded(
            child: _isGridView ? _buildGrid() : _buildList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildNetworkStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: _isOffline ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isOffline ? Icons.cloud_off : Icons.cloud_done,
            color: _isOffline ? Colors.orange : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isOffline ? 'Offline Mode - Using Cached Images' : 'Online Mode',
            style: TextStyle(
              color: _isOffline ? Colors.orange[700] : Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Loading Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Visibility: '),
                Expanded(
                  child: Slider(
                    value: _visibilityFraction,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_visibilityFraction * 100).round()}%',
                    onChanged: (value) => setState(() => _visibilityFraction = value),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ListTile(
                      title: const Text('Adaptive Loading'),
                      subtitle: const Text('Low to High Quality'),
                      trailing: Switch(
                        value: _enableAdaptiveLoading,
                        onChanged: (value) => setState(() => _enableAdaptiveLoading = value),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Offline Mode'),
                          if (_isOffline)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Icon(
                                Icons.cloud_off,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(_isOffline ? 'Using Cached Images' : 'Cache Support'),
                      trailing: Switch(
                        value: _enableOfflineMode,
                        onChanged: _toggleOfflineMode,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _demoImages.length,
      itemBuilder: (context, index) => _buildImageCard(_demoImages[index]),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _demoImages.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _buildImageCard(_demoImages[index]),
      ),
    );
  }

  Widget _buildImageCard(DemoImage image) {
    final isCached = _cachedImages[image.url] ?? false;
    final isPermanent = _permanentlyCachedImages[image.url] ?? false;
    
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePage(
              image: image,
              enableAdaptiveLoading: _enableAdaptiveLoading,
              enableOfflineMode: _enableOfflineMode,
              isOffline: _isOffline,
            ),
          ),
        ).then((_) {
          _updateCacheStatus();
          _updateCacheSize();
        }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4/3,
                  child: Hero(
                    tag: image.url,
                    child: LazyCacheImage(
                      imageUrl: image.url,
                      lowResUrl: _enableAdaptiveLoading
                          ? ImageUtils.getLowQualityUrl(image.url)
                          : null,
                      fit: BoxFit.cover,
                      enableAdaptiveLoading: _enableAdaptiveLoading,
                      enableOfflineMode: _enableOfflineMode,
                      visibilityFraction: _visibilityFraction,
                      placeholder: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      errorWidget: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isOffline ? Icons.cloud_off : Icons.error_outline,
                              color: _isOffline ? Colors.orange : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isOffline ? 'No internet connection\nImage not cached' : 'Error loading image',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isOffline ? Colors.orange[700] : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (isCached)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPermanent ? Icons.save : Icons.cached,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPermanent ? 'Saved Offline' : 'Cached',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          image.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCached)
                        Icon(
                          isPermanent ? Icons.save : Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    image.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveAll() {
    _saveAllImages();
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Cache Size: $_cacheSize',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isBatchCaching)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Saving...',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomButton(
                    icon: Icons.refresh,
                    label: 'Prefetch',
                    onPressed: _prefetchImages,
                  ),
                  const SizedBox(width: 8),
                  _buildBottomButton(
                    icon: Icons.save_alt,
                    label: 'Save All',
                    onPressed: _isBatchCaching ? null : () { _saveAllImages(); },
                  ),
                  const SizedBox(width: 8),
                  _buildBottomButton(
                    icon: Icons.delete_outline,
                    label: 'Clear',
                    onPressed: _clearCache,
                  ),
                  const SizedBox(width: 8),
                  _buildBottomButton(
                    icon: Icons.info_outline,
                    label: 'Info',
                    onPressed: _showCacheInfo,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Future<void> _clearCache() async {
    try {
      await _cacheProvider.clearAllCache();
      await _updateCacheStatus();
      await _updateCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing cache: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveAllImages() async {
    setState(() => _isBatchCaching = true);
    try {
      for (final image in _demoImages) {
        if (!(_permanentlyCachedImages[image.url] ?? false)) {
          final file = await _cacheProvider.getFile(image.url);
          await CustomCacheManager().storeFileInPermanentCache(image.url, file);
        }
      }
      await _updateCacheStatus();
      await _updateCacheSize();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All images saved for offline use'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving images: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBatchCaching = false);
      }
    }
  }

  void _showCacheInfo() async {
    final permanentCount = _permanentlyCachedImages.values.where((v) => v).length;
    final temporaryCount = _cachedImages.values.where((v) => v).length - permanentCount;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cache size: $_cacheSize\n'
            'Permanent images: $permanentCount\n'
            'Temporary images: $temporaryCount'
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class DemoImage {
  final String url;
  final String title;
  final String description;

  const DemoImage({
    required this.url,
    required this.title,
    required this.description,
  });
}

final _demoImages = [
  const DemoImage(
    url: 'https://picsum.photos/800/1200?random=1',
    title: 'Nature Scene',
    description: 'Beautiful landscape from Picsum Photos',
  ),
  const DemoImage(
    url: 'https://picsum.photos/800/1200?random=2',
    title: 'Urban Life',
    description: 'City scenes and architecture',
  ),
  const DemoImage(
    url: 'https://picsum.photos/800/1200?random=3',
    title: 'Abstract Art',
    description: 'Creative and inspiring imagery',
  ),
  const DemoImage(
    url: 'https://picsum.photos/800/1200?random=4',
    title: 'Wildlife',
    description: 'Animals in their natural habitat',
  ),
  const DemoImage(
    url: 'https://picsum.photos/800/1200?random=5',
    title: 'Technology',
    description: 'Modern tech and innovation',
  ),
];
