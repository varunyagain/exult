import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exult_flutter/core/theme/app_theme.dart';
import 'package:exult_flutter/core/constants/app_constants.dart';
import 'package:exult_flutter/presentation/navigation/app_router.dart';

/// Root application widget
class ExultApp extends ConsumerWidget {
  const ExultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(),
      routerConfig: router,
    );
  }
}
