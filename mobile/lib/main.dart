import 'dart:async';

import 'package:flutter/material.dart';

import 'app.dart';
import 'state/app_controller.dart';
import 'state/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await AppController.load();
  runApp(
    AppScope(
      controller: controller,
      child: const MyIdealBodyApp(),
    ),
  );
  // Listen early so unfinished Play purchase updates are not missed. The
  // service still blocks checkout until authenticated server verification is
  // available.
  unawaited(controller.subscriptions.initialize());
}
