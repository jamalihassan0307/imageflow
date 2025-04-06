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
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageFlow Demo'),
      ),
      body: ListView.builder(
        itemCount: _demoImages.length,
        itemBuilder: (context, index) {
          final image = _demoImages[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: LazyCacheImage(
                    imageUrl: image.url,
                    placeholder: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    maxWidth: 400,
                    maxHeight: 400,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(image.description),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Clear cache example
          final cacheProvider = CacheProvider();
          await cacheProvider.clearAllCache();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cache cleared!')),
            );
          }
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}

class DemoImage {
  final String url;
  final String description;

  const DemoImage({
    required this.url,
    required this.description,
  });
}

final _demoImages = [
  const DemoImage(
    url: 'https://avatars.githubusercontent.com/u/136632321?v=4',
    description: 'Random Image 1 - Regular JPEG',
  ),
  const DemoImage(
    url: 'https://avatars.githubusercontent.com/u/136632322?v=4',
    description: 'Random Image 2 - Regular JPEG',
  ),
  const DemoImage(
    url: 'https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg',
    description: 'Android Logo - SVG Example',
  ),
  const DemoImage(
    url: 'https://github.com/jamalihassan0307/jamalihassan0307/raw/main/thoughtworks-gif_dribbble.gif',
    description: 'Animated GIF Example',
  ),
]; 