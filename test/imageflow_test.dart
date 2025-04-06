import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imageflow/imageflow.dart';
import 'package:imageflow/src/providers/custom_cache_manager.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  const testImageUrl = 'https://avatars.githubusercontent.com/u/136632321?v=4';
  const testSvgUrl = 'https://camo.githubusercontent.com/e12029f1d6292800c6a63b7c134a199d76f99552944e2000beef21abca451162/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f632532332d2532333233393132302e7376673f7374796c653d666f722d7468652d6261646765266c6f676f3d637368617270266c6f676f436f6c6f723d7768697465';

  setUpAll(() {
    // Initialize VisibilityDetector for testing
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('LazyCacheImage Widget Tests', () {
    testWidgets('shows placeholder when not visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 1000), // Push image below viewport
                LazyCacheImage(
                  imageUrl: testImageUrl,
                  placeholder: const Text('Loading...'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('loads image when becomes visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LazyCacheImage(
            imageUrl: testImageUrl,
            placeholder: const Text('Loading...'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('shows error widget on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LazyCacheImage(
            imageUrl: 'invalid_url',
            errorWidget: const Text('Error!'),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Error!'), findsOneWidget);
    });

    testWidgets('handles SVG images correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LazyCacheImage(
            imageUrl: testSvgUrl,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });

  group('CustomCacheManager Tests', () {
    test('generates correct cache key', () {
      final cacheManager = CustomCacheManager();
      final key = cacheManager.getCacheKey(testImageUrl);
      expect(key, equals('imageFlowCache_$testImageUrl'));
    });

    test('singleton instance works correctly', () {
      final instance1 = CustomCacheManager();
      final instance2 = CustomCacheManager();
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('ImageUtils Tests', () {
    test('correctly identifies SVG urls', () {
      expect(ImageUtils.isSvgUrl('image.svg'), isTrue);
      expect(ImageUtils.isSvgUrl('image.SVG'), isTrue);
      expect(ImageUtils.isSvgUrl('image.jpg'), isFalse);
    });

    test('correctly identifies GIF urls', () {
      expect(ImageUtils.isGifUrl('image.gif'), isTrue);
      expect(ImageUtils.isGifUrl('image.GIF'), isTrue);
      expect(ImageUtils.isGifUrl('image.png'), isFalse);
    });

    test('generates low quality url correctly', () {
      expect(
        ImageUtils.getLowQualityUrl('https://example.com/image.jpg'),
        equals('https://example.com/image.jpg?quality=low'),
      );
      expect(
        ImageUtils.getLowQualityUrl('https://example.com/image.jpg?width=100'),
        equals('https://example.com/image.jpg?width=100&quality=low'),
      );
    });
  });
}
