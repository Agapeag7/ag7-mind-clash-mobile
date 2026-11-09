import 'package:flutter/services.dart';

/// Service audio minimal : utilise les sons système pour rester compilable
/// sans fichier audio externe. Peut être remplacé par `flame_audio`
/// une fois les assets fournis.
class AudioService {
  static bool musicEnabled = true;
  static bool sfxEnabled = true;

  static void tap() {
    if (!sfxEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  static void correct() {
    if (!sfxEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.mediumImpact();
  }

  static void wrong() {
    if (!sfxEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void victory() {
    if (!sfxEnabled) return;
    HapticFeedback.heavyImpact();
  }

  static void defeat() {
    if (!sfxEnabled) return;
    HapticFeedback.vibrate();
  }

  static void powerUp() {
    if (!sfxEnabled) return;
    HapticFeedback.lightImpact();
  }
}