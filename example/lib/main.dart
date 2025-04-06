import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImageFlow Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _showPlaceholder = true;
  double _visibilityFraction = 0.1;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ImageFlow Demo'),
        actions: [
          // Toggle between grid and list view
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: 'Toggle view mode',
          ),
          // Toggle between placeholder and progress indicator
          IconButton(
            icon: Icon(_showPlaceholder ? Icons.refresh : Icons.downloading),
            onPressed: () => setState(() => _showPlaceholder = !_showPlaceholder),
            tooltip: 'Toggle placeholder/progress',
          ),
        ],
      ),
      body: Column(
        children: [
          // Settings Card
          Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings', 
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
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
                          onChanged: (value) => setState(() => _visibilityFraction = value),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Images List/Grid
          Expanded(
            child: _isGridView ? _buildGrid() : _buildList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          try {
            final cacheProvider = CacheProvider();
            await cacheProvider.clearAllCache();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error clearing cache: $e'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.delete_outline),
        label: const Text('Clear Cache'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Hero(
              tag: image.url,
              child: LazyCacheImage(
                imageUrl: image.url,
                fit: BoxFit.cover,
                placeholder: _showPlaceholder ? _buildCustomPlaceholder() : null,
                errorWidget: _buildCustomErrorWidget(),
                maxWidth: 600,
                maxHeight: 800,
                visibilityFraction: _visibilityFraction,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  image.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  image.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: progress,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomErrorWidget() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading image',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'An error occurred while loading the image',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
    url: 'https://picsum.photos/seed/1/800/1200',
    title: 'Nature Image',
    description: 'High-quality random nature image from Picsum Photos',
  ),
  const DemoImage(
    url: 'https://raw.githubusercontent.com/flutter/website/main/src/assets/images/flutter-logo-sharing.png',
    title: 'Flutter Logo',
    description: 'Official Flutter logo from GitHub',
  ),
  const DemoImage(
    url: 'https://media.giphy.com/media/xT0xezQGU5xCDJuCPe/giphy.gif',
    title: 'Loading Animation',
    description: 'Smooth loading animation from Giphy',
  ),
  const DemoImage(
    url: 'https://picsum.photos/seed/2/800/1200',
    title: 'Urban Scene',
    description: 'Urban photography showcasing city life',
  ),
  const DemoImage(
    url: 'https://this-url-does-not-exist.jpg',
    title: 'Error Example',
    description: 'This image will demonstrate the error state handling',
  ),
  const DemoImage(
    url: 'https://picsum.photos/seed/3/800/1200',
    title: 'Abstract Art',
    description: 'Abstract artistic photography with vibrant colors',
  ),
]; 