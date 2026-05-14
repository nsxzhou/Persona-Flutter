import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';

class PersonaApp extends ConsumerWidget {
  const PersonaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Persona',
      debugShowCheckedModeBanner: false,
      theme: buildPersonaTheme(Brightness.light),
      darkTheme: buildPersonaTheme(Brightness.dark),
      routerConfig: router,
    );
  }
}
