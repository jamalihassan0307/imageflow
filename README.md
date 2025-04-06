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

<div align="center">
  <kbd>
    <img src="https://github.com/jamalihassan0307/Projects-Assets/blob/main/globel%20assets/profile/image.jpg?raw=true" width="250" alt="ImageFlow"/>
  </kbd>
  
  <h1>🌟 ImageFlow 🌟</h1>
  <p><i>An advanced Flutter package for optimized image loading with caching and lazy loading capabilities</i></p>
  
  <p align="center">
    <a href="https://github.com/jamalihassan0307">
      <img src="https://img.shields.io/badge/Created_by-Jam_Ali_Hassan-blue?style=for-the-badge&logo=github&logoColor=white" alt="Created by"/>
    </a>
  </p>

  <p align="center">
    <a href="https://github.com/jamalihassan0307">
      <img src="https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"/>
    </a>
    <a href="https://www.linkedin.com/in/jamalihassan0307">
      <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"/>
    </a>
    <a href="https://jamalihassan0307.github.io/portfolio.github.io">
      <img src="https://img.shields.io/badge/Portfolio-255E63?style=for-the-badge&logo=About.me&logoColor=white" alt="Portfolio"/>
    </a>
  </p>

  <p align="center">
    <a href="https://pub.dev/packages/imageflow">
      <img src="https://img.shields.io/pub/v/imageflow?style=for-the-badge&logo=dart&logoColor=white" alt="Pub Version"/>
    </a>
    <a href="https://flutter.dev">
      <img src="https://img.shields.io/badge/Platform-Flutter-02569B?style=for-the-badge&logo=flutter" alt="Platform"/>
    </a>
    <a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge" alt="License: MIT"/>
    </a>
  </p>

  <p align="center">
    <a href="https://pub.dev/packages/imageflow">
      <img src="https://img.shields.io/pub/likes/imageflow?style=for-the-badge&logo=flutter&logoColor=white&label=Pub%20Likes" alt="Pub Likes"/>
    </a>
    <a href="https://pub.dev/packages/imageflow">
      <img src="https://img.shields.io/pub/points/imageflow?style=for-the-badge&logo=flutter&logoColor=white&label=Pub%20Points" alt="Pub Points"/>
    </a>
    <a href="https://pub.dev/packages/imageflow">
      <img src="https://img.shields.io/pub/popularity/imageflow?style=for-the-badge&logo=flutter&logoColor=white&label=Popularity" alt="Popularity"/>
    </a>
  </p>
</div>

An advanced image loader for Flutter with caching, placeholders, and progressive loading. ImageFlow provides optimized lazy loading capabilities, ensuring your app's images load efficiently and smoothly.

## ✨ Features

🏎️ **Optimized Lazy Loading**
- Loads images only when they become visible in the viewport
- Reduces memory usage and initial load time
- Configurable visibility threshold for loading

🛠️ **Advanced Caching Support**
- Efficient local storage caching
- Permanent and temporary cache options
- Automatic cache size management
- Offline-first approach with cache fallback

🔄 **Placeholder & Error Handling**
- Customizable loading placeholders
- Elegant error states with retry options
- Smooth transitions between states
- Clear feedback for offline mode

📱 **Adaptive Image Quality**
- Progressive image loading with quality transitions
- Low-res to high-res automatic switching
- Bandwidth-aware loading strategies
- Configurable quality thresholds

🚀 **Prefetching & Preloading**
- Smart preloading of off-screen images
- Batch prefetching capabilities
- Background loading with progress tracking
- Optimized memory usage

🌍 **Network & Offline Support**
- Robust offline mode with permanent cache
- Automatic network state detection
- Clear UI feedback for connectivity status
- Seamless offline-online transitions

🎨 **Extended Format Support**
- GIF and animated image support
- SVG rendering capabilities
- Interactive image viewing with zoom
- Responsive layout handling

### Android Setup

Add the following permission to your Android Manifest (`android/app/src/main/AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

This permission is required for loading images from the internet.

## 🚀 Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  imageflow: ^1.0.8
```

## 💻 Usage Examples

### Basic Usage
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.cover,
)
```

### With Advanced Caching
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  enableOfflineMode: true,
  storeInCache: true, // For permanent storage
  cacheDuration: const Duration(days: 30),
)
```

### Adaptive Quality Loading
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/high-quality.jpg',
  lowResUrl: 'https://example.com/low-quality.jpg',
  enableAdaptiveLoading: true,
  visibilityFraction: 0.1,
  placeholder: const Center(
    child: CircularProgressIndicator(),
  ),
)
```

### Interactive Viewer with Error Handling
```dart
InteractiveViewer(
  minScale: 0.5,
  maxScale: 4.0,
  child: LazyCacheImage(
    imageUrl: 'https://example.com/image.jpg',
    fit: BoxFit.contain,
    errorWidget: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          Text('Failed to load image'),
          ElevatedButton(
            onPressed: () => {/* Retry logic */},
            child: Text('Retry'),
          ),
        ],
      ),
    ),
  ),
)
```

### Grid View with Lazy Loading
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 0.75,
  ),
  itemBuilder: (context, index) => LazyCacheImage(
    imageUrl: images[index],
    visibilityFraction: 0.1,
    enableAdaptiveLoading: true,
    enableOfflineMode: true,
    fit: BoxFit.cover,
  ),
)
```

### Batch Image Prefetching
```dart
// Prefetch and store images permanently
await ImageUtils.prefetchImages(
  [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
  ],
  storeInCache: true,
);

// Use in widgets
LazyCacheImage(
  imageUrl: 'https://example.com/image1.jpg',
  enableOfflineMode: true,
  placeholder: const Text('Loading from cache...'),
)
```

### Advanced Cache Management
```dart
final cacheProvider = CacheProvider();

// Get cache information
final size = await cacheProvider.getCacheSize();
final path = await cacheProvider.getCachePath();

// Check cache status
final isCached = await ImageUtils.isImageCached(
  url,
  checkPermanent: true,
);

// Clear specific image
await cacheProvider.clearCache(url);

// Clear all cache
await cacheProvider.clearAllCache();
```

### Offline-First Implementation
```dart
LazyCacheImage(
  imageUrl: url,
  enableOfflineMode: true,
  storeInCache: true,
  placeholder: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        Text('Loading from cache...'),
      ],
    ),
  ),
  errorWidget: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off),
        Text('Image not available offline'),
      ],
    ),
  ),
)
```

## 🎯 Use Cases

### 1. Social Media Feed
Perfect for image-heavy social feeds:
```dart
ListView.builder(
  itemBuilder: (context, index) => Card(
    child: LazyCacheImage(
      imageUrl: posts[index].imageUrl,
      enableAdaptiveLoading: true,
      visibilityFraction: 0.1,
      storeInCache: true,
    ),
  ),
)
```

### 2. Photo Gallery
Ideal for photo galleries with zoom:
```dart
InteractiveViewer(
  minScale: 0.5,
  maxScale: 4.0,
  child: LazyCacheImage(
    imageUrl: photo.url,
    fit: BoxFit.contain,
    enableOfflineMode: true,
    storeInCache: true,
  ),
)
```

### 3. E-commerce Product Images
Great for product listings:
```dart
GridView.builder(
  itemBuilder: (context, index) => LazyCacheImage(
    imageUrl: products[index].imageUrl,
    lowResUrl: products[index].thumbnailUrl,
    enableAdaptiveLoading: true,
    storeInCache: true,
  ),
)
```

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines first.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find this package helpful, please give it a star on [GitHub](https://github.com/jamalihassan0307/imageflow)!

## Contact

- 👨‍💻 Developed by [Jam Ali Hassan](https://github.com/jamalihassan0307)
- 🌐 [Portfolio](https://jamalihassan0307.github.io/portfolio.github.io)
- 📧 Email: jamalihassan0307@gmail.com
- 🔗 [LinkedIn](https://www.linkedin.com/in/jamalihassan0307)
