import 'dart:async';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/power_up.dart';

final RouteObserver<PageRoute<dynamic>> audioRouteObserver =
    RouteObserver<PageRoute<dynamic>>();

class AudioService {
  static bool musicEnabled = true;
  static bool sfxEnabled = true;
  static bool _initialized = false;
  static String? _currentMusic;
  static final Random _random = Random();

  static Future<void> initialize({
    required bool musicEnabled,
    required bool sfxEnabled,
  }) async {
    AudioService.musicEnabled = musicEnabled;
    AudioService.sfxEnabled = sfxEnabled;
    FlameAudio.bgm.initialize();
    _initialized = true;
  }

  static void setMusicEnabled(bool enabled) {
    musicEnabled = enabled;
    if (!enabled) {
      FlameAudio.bgm.stop();
    } else if (_currentMusic != null) {
      _playMusic(_currentMusic!);
    }
  }

  static void setSfxEnabled(bool enabled) {
    sfxEnabled = enabled;
  }

  static void playMusic(String? asset) {
    _currentMusic = asset;
    if (!_initialized) return;
    if (!musicEnabled || asset == null) {
      FlameAudio.bgm.stop();
      return;
    }
    _playMusic(asset);
  }

  static void stopMusic() {
    if (!_initialized) return;
    FlameAudio.bgm.stop();
  }

  static void _playMusic(String asset) {
    unawaited(FlameAudio.bgm.play(asset, volume: 0.45));
  }

  static void menuSelection() {
    _playSfx('sfx/selection-menu-option.mp3');
  }

  static void tap() {
    if (!sfxEnabled) return;
    SystemSound.play(SystemSoundType.click);
    HapticFeedback.selectionClick();
  }

  static void submitEmpty() {
    _playSfx('sfx/clic-sur-valider-sans-taper-une-reponse.mp3');
  }

  static void roundStarted() {
    _playSfx('sfx/debut-manche.mp3');
  }

  static void correct({required bool isVsAI}) {
    _playSfx('sfx/sfx-reussite-bonne-reponse.mp3');
    if (sfxEnabled) HapticFeedback.mediumImpact();
  }

  static void wrong({required int attemptsLeft}) {
    _playSfx(
      attemptsLeft > 0
          ? 'sfx/mauvaise-reponse-une-fois.mp3'
          : 'sfx/mauvaise-reponse-deux-fois.mp3',
    );
    if (sfxEnabled) HapticFeedback.heavyImpact();
  }

  static void timeAlmostUp() {
    _playSfx('sfx/chrono-10seconde-moins.mp3');
  }

  static void timeout() {
    _playSfx('sfx/un-pas-vers-echec.mp3');
  }

  static void roundOver({required bool humanWon, required bool isVsAI}) {
    _playSfx('sfx/fin-de-manche.mp3');
    if (isVsAI) {
      if (humanWon) {
        _playRandomSfx([
          'sfx/réussite-mache-vs-ia-1.mp3',
          'sfx/réussite-mache-vs-ia-2.mp3',
        ]);
      } else {
        _playRandomSfx([
          'sfx/echec-mache-vs-ia-1.mp3',
          'sfx/echec-manche-vs-ia-2.mp3',
          'sfx/echec-manche-vs-ia-3.mp3',
          'sfx/echec-manche-vs-ia-4.mp3',
          'sfx/echec-manche-vs-ia-5.mp3',
        ]);
      }
    } else {
      _playSfx('sfx/reussite-manche-humain-vs-humain-1.mp3');
    }
    if (sfxEnabled) HapticFeedback.heavyImpact();
  }

  static void powerUp(PowerUpType type) {
    switch (type) {
      case PowerUpType.doublePoints:
        _playSfx('sfx/effet-activation-bonus-double-point.mp3');
        break;
      case PowerUpType.extraAttempt:
        _playSfx('sfx/effet-activation-bonus-tentative-en-plus.mp3');
        break;
      case PowerUpType.illusion:
        _playRandomSfx([
          'sfx/effet-bonus-illusion.mp3',
          'sfx/effet-bonus-illusion-1.mp3',
          'sfx/effet-bonus-illusion-2.mp3',
        ]);
        break;
      case PowerUpType.timeTheft:
      case PowerUpType.ropeFreeze:
        _playSfx(
          'sfx/danger-bonus-activer-illusion-et-vol-de-temps-et-gel-de-corde.mp3',
        );
        break;
      case PowerUpType.autoAnswer:
        _playSfx('sfx/sfx-activation-bonus-reponse-auto.mp3');
        break;
    }
    if (sfxEnabled) HapticFeedback.lightImpact();
  }

  static void _playRandomSfx(List<String> assets) {
    if (!sfxEnabled || !_initialized) return;
    _playSfx(assets[_random.nextInt(assets.length)]);
  }

  static void _playSfx(String asset) {
    if (!sfxEnabled || !_initialized) return;
    unawaited(_playSfxOnce(asset));
  }

  static Future<void> _playSfxOnce(String asset) async {
    if (!sfxEnabled || !_initialized) return;
    try {
      final player = await FlameAudio.play(asset);
      unawaited(
        player.onPlayerComplete.first.then((_) => player.dispose()).catchError((
          Object error,
        ) async {
          await player.dispose();
        }),
      );
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'audio',
          context: ErrorDescription('while playing sound effect "$asset"'),
        ),
      );
    }
  }
}

class AudioPageMusic extends StatefulWidget {
  final List<String> tracks;
  final Widget child;

  const AudioPageMusic({super.key, required this.tracks, required this.child});

  @override
  State<AudioPageMusic> createState() => _AudioPageMusicState();
}

class _AudioPageMusicState extends State<AudioPageMusic> with RouteAware {
  PageRoute<dynamic>? _route;
  late final String? _track = widget.tracks.isEmpty
      ? null
      : widget.tracks[Random().nextInt(widget.tracks.length)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      if (_route != null) audioRouteObserver.unsubscribe(this);
      _route = route;
      audioRouteObserver.subscribe(this, route);
      AudioService.playMusic(_track);
    }
  }

  @override
  void didPushNext() {
    AudioService.stopMusic();
  }

  @override
  void didPopNext() {
    AudioService.playMusic(_track);
  }

  @override
  void dispose() {
    audioRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
