import 'package:flutter/material.dart';

import 'package:helpi_admin/app/app.dart';
import 'package:helpi_admin/core/services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PreferencesService.instance.init();
  runApp(const HelpiAdminApp());
}
