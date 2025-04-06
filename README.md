<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# ImageFlow 📷

An advanced image loader for Flutter with caching, placeholders, and progressive loading. ImageFlow provides optimized lazy loading capabilities, ensuring your app's images load efficiently and smoothly.

## ✨ Features

🏎️ **Optimized Lazy Loading**
- Loads images only when they become visible in the viewport
- Reduces memory usage and initial load time

🛠️ **Advanced Caching Support**
- Efficient local storage caching
- Customizable cache duration
- Automatic cache management

🔄 **Placeholder & Error Handling**
- Customizable loading placeholders
- Elegant error states
- Smooth transitions between states

📱 **Adaptive Image Quality**
- Progressive image loading
- Low-res to high-res transitions
- Bandwidth-aware loading

🚀 **Prefetching & Preloading**
- Smart preloading of off-screen images
- Configurable prefetch policies
- Background loading support

🌍 **Network & Offline Support**
- Offline-first approach
- Automatic network state detection
- Fallback mechanisms for offline usage

🎨 **Extended Format Support**
- GIF support
- SVG rendering
- Extensible format handlers

## 🚀 Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  imageflow: ^1.0.1
```

## 💻 Usage Examples

### Basic Usage
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
)
```

### With Custom Placeholder
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: const Center(
    child: CircularProgressIndicator(),
  ),
)
```

### With Error Handling
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  errorWidget: const Icon(
    Icons.error_outline,
    color: Colors.red,
  ),
)
```

### Advanced Usage
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
  maxWidth: 300,
  maxHeight: 300,
  visibilityFraction: 0.1,
  cacheDuration: const Duration(days: 7),
)
```

## 🎯 Use Cases

### 1. Image Lists & Grids
Perfect for optimizing performance in scrolling lists:
```dart
ListView.builder(
  itemBuilder: (context, index) => LazyCacheImage(
    imageUrl: images[index],
    visibilityFraction: 0.1,
  ),
)
```

### 2. SVG Support
Automatically handles SVG images:
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/vector.svg',
  fit: BoxFit.contain,
)
```

### 3. Offline Support
Images remain available offline after first load:
```dart
LazyCacheImage(
  imageUrl: url,
  placeholder: const Text('Loading from cache...'),
)
```

### 4. Cache Management
Easy cache control:
```dart
final cacheProvider = CacheProvider();

// Clear specific image
await cacheProvider.clearCache(imageUrl);

// Clear all cached images
await cacheProvider.clearAllCache();

// Get cache size
final size = await cacheProvider.getCacheSize();
```

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
