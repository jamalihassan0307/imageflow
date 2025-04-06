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
  imageflow: ^1.0.0
```

## 💻 Usage

```dart
import 'package:imageflow/imageflow.dart';

// Basic usage
ImageFlow(
  url: 'https://example.com/image.jpg',
)

// Advanced usage with all features
ImageFlow(
  url: 'https://example.com/image.jpg',
  placeholder: 'assets/placeholder.png',
  errorWidget: (context, error) => Icon(Icons.error),
  progressIndicatorBuilder: (context, progress) => CircularProgressIndicator(),
  cacheManager: CustomCacheManager(),
  preload: true,
)
```

## 📚 Documentation

For detailed documentation and examples, visit our [Wiki](https://github.com/yourusername/imageflow/wiki).

## 🤝 Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
