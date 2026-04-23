import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:helpi_admin/app/app.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.instance.init();

  // Pre-warm SVG asset bytes (fire-and-forget — must NOT await before runApp
  // or Flutter Web hot-reload triggers "disposed EngineFlutterView" errors)
  Future.wait([
    rootBundle.load('assets/images/logo.svg'),
    rootBundle.load('assets/images/h_logo.svg'),
  ]).ignore();

  runApp(const ProviderScope(child: HelpiAdminApp()));
}
