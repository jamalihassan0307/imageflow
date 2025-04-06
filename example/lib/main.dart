import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (_, __, ___) => true;
    client.connectionTimeout = const Duration(seconds: 30);
    client.idleTimeout = const Duration(seconds: 30);
    return client;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
    developer.log('Debug mode: Using custom HTTP client configuration');
  }

  // Clear any existing cache on startup
  try {
    final cacheProvider = CacheProvider();
    await cacheProvider.clearAllCache();
    developer.log('Cache cleared on startup');
  } catch (e) {
    developer.log('Error clearing cache on startup: $e');
  }

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
  bool _hasInternetConnection = true;
  final CacheProvider _cacheProvider = CacheProvider();

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _clearCache();
  }

  Future<void> _clearCache() async {
    try {
      await _cacheProvider.clearAllCache();
      developer.log('Cache cleared successfully');
    } on Exception catch (e) {
      developer.log('Error clearing cache: $e');
    }
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      developer.log('Internet connection check: $hasConnection');
      if (mounted) {
        setState(() {
          _hasInternetConnection = hasConnection;
        });
      }
    } on SocketException catch (error) {
      developer.log('Error checking internet connection: $error');
      if (mounted) {
        setState(() {
          _hasInternetConnection = false;
        });
      }
    }
  }

  Future<void> _retryLoadingImages() async {
    developer.log('Retrying image load...');
    await _checkInternetConnection();
    if (_hasInternetConnection) {
      try {
        await _cacheProvider.clearAllCache();
        developer.log('Cache cleared for retry');
        if (mounted) {
          setState(() {});
        }
      } on Exception catch (error) {
        developer.log('Error during retry: $error');
      }
    }
  }

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
            onPressed: () =>
                setState(() => _showPlaceholder = !_showPlaceholder),
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
                  Text(
                    'Settings',
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
                          onChanged: (value) =>
                              setState(() => _visibilityFraction = value),
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
            await _cacheProvider.clearAllCache();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } on Exception catch (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error clearing cache: $error'),
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
    print("image.url${image.url}");
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
                errorWidget: _buildCustomErrorWidget(
                  onRetry: () => _retryLoadingImages(),
                  error: !_hasInternetConnection 
                      ? 'No internet connection'
                      : 'Failed to load image. Please try again.',
                ),
                // maxWidth: 600,
                // maxHeight: 800,
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
    );
  }

  Widget _buildCustomPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildCustomErrorWidget({VoidCallback? onRetry, String? error}) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(8),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading image',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 4),
                Text(
                  error,
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                height: 32,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
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
    url: 'https://picsum.photos/400/600?random=1',
    title: 'Random Image 1',
    description: 'Random image from Picsum Photos',
  ),
  const DemoImage(
    url: 'https://picsum.photos/400/600?random=2',
    title: 'Random Image 2',
    description: 'Random image from Picsum Photos',
  ),
  const DemoImage(
    url: 'https://picsum.photos/400/600?random=3',
    title: 'Random Image 3',
    description: 'Random image from Picsum Photos',
  ),
];
