import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  final remindersEnabled = await StorageService.getRemindersEnabled();
  await NotificationService.initialize(enabled: remindersEnabled);
  if (remindersEnabled && !NotificationService.remindersEnabled) {
    await StorageService.setRemindersEnabled(false);
  }
  await AudioService.initialize(
    musicEnabled: await StorageService.getMusicEnabled(),
    sfxEnabled: await StorageService.getSfxEnabled(),
  );
  runApp(const ProviderScope(child: Ag7App()));
}