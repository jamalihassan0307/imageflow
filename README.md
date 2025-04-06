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
    <img src="https://github.com/jamalihassan0307/imageflow/blob/main/image/image.jpg?raw=true" width="250" alt="ImageFlow"/>
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
  imageflow: ^1.0.7
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

### Adaptive Quality Loading
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/high-quality.jpg',
  lowResUrl: 'https://example.com/low-quality.jpg',
  enableAdaptiveLoading: true,
  fit: BoxFit.cover,
)
```

### Offline Mode Support
```dart
LazyCacheImage(
  imageUrl: 'https://example.com/image.jpg',
  enableOfflineMode: true,
  placeholder: const Text('Loading from cache...'),
)
```

### With Prefetching
```dart
// Prefetch multiple images
await ImageUtils.prefetchImages([
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
]);

// Use in widget
LazyCacheImage(
  imageUrl: 'https://example.com/image1.jpg',
  enableOfflineMode: true,
)
```

### Interactive Image Viewer
```dart
InteractiveViewer(
  minScale: 0.5,
  maxScale: 4.0,
  child: LazyCacheImage(
    imageUrl: 'https://example.com/image.jpg',
    fit: BoxFit.contain,
  ),
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

## Support

If you find this package helpful, please give it a star on [GitHub](https://github.com/jamalihassan0307/imageflow)!

## Contact

- 👨‍💻 Developed by [Jam Ali Hassan](https://github.com/jamalihassan0307)
- 🌐 [Portfolio](https://jamalihassan0307.github.io/portfolio.github.io)
- 📧 Email: jamalihassan0307@gmail.com
- 🔗 [LinkedIn](https://www.linkedin.com/in/jamalihassan0307)
