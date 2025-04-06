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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageFlow Demo'),
        actions: [
          IconButton(
            icon: Icon(_showPlaceholder ? Icons.refresh : Icons.downloading),
            onPressed: () {
              setState(() {
                _showPlaceholder = !_showPlaceholder;
              });
            },
            tooltip: 'Toggle placeholder/progress',
          ),
        ],
      ),
      body: Column(
        children: [
          // Visibility threshold slider
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Visibility threshold: '),
                Expanded(
                  child: Slider(
                    value: _visibilityFraction,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_visibilityFraction * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        _visibilityFraction = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Image grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _demoImages.length,
              itemBuilder: (context, index) {
                final image = _demoImages[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: LazyCacheImage(
                          imageUrl: image.url,
                          fit: BoxFit.cover,
                          placeholder: _showPlaceholder
                              ? _buildCustomPlaceholder()
                              : null,
                          errorWidget: _buildCustomErrorWidget(),
                          maxWidth: 300,
                          maxHeight: 300,
                          visibilityFraction: _visibilityFraction,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              image.title,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              image.description,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cacheProvider = CacheProvider();
          await cacheProvider.clearAllCache();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared!')),
            );
          }
        },
        icon: const Icon(Icons.delete_outline),
        label: const Text('Clear Cache'),
      ),
    );
  }

  Widget _buildCustomPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Loading...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomErrorWidget() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 8),
            Text('Error loading image', style: TextStyle(color: Colors.red)),
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
    url: 'https://picsum.photos/seed/1/400/600',
    title: 'Random Image',
    description: 'High-quality random image from Picsum Photos',
  ),
  const DemoImage(
    url: 'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg',
    title: 'Android Logo',
    description: 'SVG vector image example',
  ),
  const DemoImage(
    url: 'https://media.giphy.com/media/l0HlMZrXA2H7aqpwI/giphy.gif',
    title: 'Animated GIF',
    description: 'Animated GIF example from Giphy',
  ),
  const DemoImage(
    url: 'https://picsum.photos/seed/2/400/600',
    title: 'Another Random',
    description: 'Another random image example',
  ),
  const DemoImage(
    url: 'https://invalid.url/image.jpg',
    title: 'Error Example',
    description: 'This image will show the error state',
  ),
  const DemoImage(
    url: 'https://picsum.photos/seed/3/400/600',
    title: 'Lazy Loading',
    description: 'This image demonstrates lazy loading',
  ),
];
