import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await AudioService.initialize(
    musicEnabled: await StorageService.getMusicEnabled(),
    sfxEnabled: await StorageService.getSfxEnabled(),
  );
  runApp(const ProviderScope(child: Ag7App()));
}