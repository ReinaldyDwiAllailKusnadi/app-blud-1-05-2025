import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'services/auth_service.dart';
import 'services/content_service.dart';
import 'services/event_service.dart';
import 'services/submission_service.dart';
import 'providers/auth_provider.dart';
import 'providers/content_provider.dart';
import 'providers/event_provider.dart';
import 'providers/submission_provider.dart';
import 'core/services/cache_service.dart';
import 'screens/auth/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.init();
  
  // Dependency Injection Sederhana
  final dioClient = DioClient();
  final authService = AuthService(dioClient);
  final contentService = ContentService(dioClient);
  final eventService = EventService(dioClient);
  final submissionService = SubmissionService(dioClient);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, dioClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ContentProvider(contentService),
        ),
        ChangeNotifierProvider(
          create: (_) => EventProvider(eventService),
        ),
        ChangeNotifierProvider(
          create: (_) => SubmissionProvider(submissionService, dioClient),
        ),
      ],
      child: const BludApp(),
    ),
  );
}

class BludApp extends StatelessWidget {
  const BludApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLUD Pariwisata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
