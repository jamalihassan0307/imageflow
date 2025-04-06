import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'image_page.dart';
import 'dart:developer' as developer;

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isGridView = true;
  bool _enableAdaptiveLoading = true;
  bool _enableOfflineMode = true;
  double _visibilityFraction = 0.1;
  final CacheProvider _cacheProvider = CacheProvider();

  @override
  void initState() {
    super.initState();
    _prefetchImages();
  }

  Future<void> _prefetchImages() async {
    developer.log('Prefetching images...');
    await ImageUtils.prefetchImages(
      _demoImages.map((img) => img.url).toList(),
    );
    developer.log('Prefetching complete');
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
          _buildControlPanel(),
          Expanded(
            child: _isGridView ? _buildGrid() : _buildList(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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
                const Text('Visibility threshold: '),
                Expanded(
                  child: Slider(
                    value: _visibilityFraction,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_visibilityFraction * 100).round()}%',
                    onChanged: (value) =>
                        setState(() => _visibilityFraction = value),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Adaptive Loading'),
                    subtitle: const Text('Low to High Quality'),
                    value: _enableAdaptiveLoading,
                    onChanged: (value) =>
                        setState(() => _enableAdaptiveLoading = value),
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Offline Mode'),
                    subtitle: const Text('Cache Support'),
                    value: _enableOfflineMode,
                    onChanged: (value) =>
                        setState(() => _enableOfflineMode = value),
                  ),
                ),
              ],
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
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePage(
              image: image,
              enableAdaptiveLoading: _enableAdaptiveLoading,
              enableOfflineMode: _enableOfflineMode,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    image.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomButton(
              icon: Icons.refresh,
              label: 'Prefetch',
              onPressed: _prefetchImages,
            ),
            _buildBottomButton(
              icon: Icons.delete_outline,
              label: 'Clear Cache',
              onPressed: () async {
                await _cacheProvider.clearAllCache();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            _buildBottomButton(
              icon: Icons.info_outline,
              label: 'Cache Info',
              onPressed: () async {
                final size = await _cacheProvider.getCacheSize();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Cache size: ${(size / 1024 / 1024).toStringAsFixed(2)} MB'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
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
