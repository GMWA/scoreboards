import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scoreboards/core/router.dart';
import 'package:scoreboards/core/theme.dart';

class ScoreboardsApp extends ConsumerWidget {
  const ScoreboardsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Scoreboards',
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
