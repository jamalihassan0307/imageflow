import 'package:flutter/material.dart';
import 'package:imageflow/imageflow.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'pages/main_page.dart';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        cardTheme: const CardTheme(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
        ),
      ),
      home: const MainPage(),
    );
  }
}
