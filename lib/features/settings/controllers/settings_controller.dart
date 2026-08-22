import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/chapter_themes.dart';

class SettingsController extends GetxController {
  static const _kSound = 'settings_sound_enabled';
  static const _kMusic = 'settings_music_enabled';
  static const _kHaptics = 'settings_haptics_enabled';
  static const _kTheme = 'settings_dark_theme';
  static const _kVolume = 'settings_music_volume';
  static const _kSfxVolume = 'settings_sfx_volume';

  var soundEnabled = true.obs;
  var musicEnabled = true.obs;
  var hapticsEnabled = true.obs;
  var darkTheme = true.obs;
  var musicVolume = 0.6.obs;
  var sfxVolume = 0.9.obs;

  SharedPreferences? _prefs;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxChimePlayer = AudioPlayer();
  final AudioPlayer _sfxVictoryPlayer = AudioPlayer();
  final AudioPlayer _sfxGameOverPlayer = AudioPlayer();
  String? _currentTrack;
  int _currentChapter = 1;

  static SettingsController get to => Get.find<SettingsController>();

  @override
  void onInit() {
    super.onInit();
    unawaited(ensureInitialized());
  }

  Future<void> ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
    soundEnabled.value = _prefs?.getBool(_kSound) ?? true;
    musicEnabled.value = _prefs?.getBool(_kMusic) ?? true;
    hapticsEnabled.value = _prefs?.getBool(_kHaptics) ?? true;
    darkTheme.value = _prefs?.getBool(_kTheme) ?? true;
    musicVolume.value = _prefs?.getDouble(_kVolume) ?? 0.6;
    sfxVolume.value = _prefs?.getDouble(_kSfxVolume) ?? 0.9;

    await _musicPlayer.setVolume(musicVolume.value);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await Future.wait([
      _sfxChimePlayer.setVolume(sfxVolume.value),
      _sfxVictoryPlayer.setVolume(sfxVolume.value),
      _sfxGameOverPlayer.setVolume(sfxVolume.value),
      _sfxChimePlayer.setReleaseMode(ReleaseMode.stop),
      _sfxVictoryPlayer.setReleaseMode(ReleaseMode.stop),
      _sfxGameOverPlayer.setReleaseMode(ReleaseMode.stop),
    ]);

    if (musicEnabled.value) {
      unawaited(playChapterMusic(1));
    }

    ever(musicEnabled, _onMusicToggled);
    ever(musicVolume, _onMusicVolumeChanged);
  }

  @override
  void onClose() {
    unawaited(_musicPlayer.stop());
    unawaited(_musicPlayer.dispose());
    unawaited(_sfxChimePlayer.stop());
    unawaited(_sfxChimePlayer.dispose());
    unawaited(_sfxVictoryPlayer.stop());
    unawaited(_sfxVictoryPlayer.dispose());
    unawaited(_sfxGameOverPlayer.stop());
    unawaited(_sfxGameOverPlayer.dispose());
    super.onClose();
  }

  Future<void> _onMusicToggled(bool enabled) async {
    if (enabled) {
      await playChapterMusic(_currentChapter);
    } else {
      await _musicPlayer.pause();
    }
  }

  Future<void> _onMusicVolumeChanged(double vol) async {
    await _musicPlayer.setVolume(vol);
  }

  Future<void> toggleSound(bool value) async {
    soundEnabled.value = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_kSound, value);
  }

  Future<void> toggleMusic(bool value) async {
    musicEnabled.value = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_kMusic, value);
  }

  Future<void> toggleHaptics(bool value) async {
    hapticsEnabled.value = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_kHaptics, value);
  }

  Future<void> toggleTheme(bool value) async {
    darkTheme.value = value;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setBool(_kTheme, value);
  }

  Future<void> setMusicVolume(double v) async {
    musicVolume.value = v;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setDouble(_kVolume, v);
    await _musicPlayer.setVolume(v);
  }

  Future<void> setSfxVolume(double v) async {
    sfxVolume.value = v;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setDouble(_kSfxVolume, v);
    await Future.wait([
      _sfxChimePlayer.setVolume(v),
      _sfxVictoryPlayer.setVolume(v),
      _sfxGameOverPlayer.setVolume(v),
    ]);
  }

  // ==== CUSTOM SFX (generated WAV assets) ====

  Future<void> playStarChime() async {
    if (!soundEnabled.value) return;
    try {
      await _sfxChimePlayer.stop();
      await _sfxChimePlayer.play(
        AssetSource('audio/sfx_star_chime.wav'),
        volume: sfxVolume.value,
      );
    } catch (_) {
      unawaited(playClick());
    }
  }

  Future<void> playVictory() async {
    if (!soundEnabled.value) return;
    try {
      await _sfxVictoryPlayer.stop();
      await _sfxVictoryPlayer.play(
        AssetSource('audio/sfx_victory.wav'),
        volume: sfxVolume.value,
      );
    } catch (_) {
      await Future.wait([
        playClick(),
        Future.delayed(const Duration(milliseconds: 120), () => playClick()),
        Future.delayed(const Duration(milliseconds: 260), () => playClick()),
      ]);
    }
  }

  Future<void> playGameOver() async {
    if (!soundEnabled.value) return;
    try {
      await _sfxGameOverPlayer.stop();
      await _sfxGameOverPlayer.play(
        AssetSource('audio/sfx_game_over.wav'),
        volume: sfxVolume.value,
      );
    } catch (_) {
      unawaited(playAlert());
    }
  }

  // ==== HAPTIC FEEDBACK (fully functional via flutter/services HapticFeedback) ====

  Future<void> lightHaptic() async {
    if (!hapticsEnabled.value) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> mediumHaptic() async {
    if (!hapticsEnabled.value) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> heavyHaptic() async {
    if (!hapticsEnabled.value) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> selectionClick() async {
    if (!hapticsEnabled.value) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }

  // ==== SOUND EFFECTS (functional) ====

  Future<void> playClick() async {
    if (!soundEnabled.value) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  Future<void> playAlert() async {
    if (!soundEnabled.value) return;
    try {
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  // ==== MUSIC (functional via audioplayers AssetSource looping) ====

  Future<void> playChapterMusic(int chapter) async {
    _currentChapter = chapter;
    if (!musicEnabled.value) return;
    final theme = ChapterThemes.forChapter(chapter);
    final asset = theme.trackAsset;
    if (asset == _currentTrack) return;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.play(AssetSource(asset), volume: musicVolume.value);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      _currentTrack = asset;
    } catch (_) {
      _currentTrack = null;
    }
  }

  Future<void> pauseMusic() async {
    try {
      await _musicPlayer.pause();
    } catch (_) {}
  }

  Future<void> resumeMusic() async {
    if (!musicEnabled.value) return;
    try {
      await _musicPlayer.resume();
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
      _currentTrack = null;
    } catch (_) {}
  }

  // ==== COMPOSITE FEEDBACK HELPERS ====

  Future<void> feedbackLineComplete() async {
    await Future.wait([mediumHaptic(), playClick()]);
  }

  Future<void> feedbackGameOver() async {
    await Future.wait([heavyHaptic(), playAlert(), playGameOver()]);
  }

  Future<void> feedbackWin() async {
    await Future.wait([
      lightHaptic(),
      Future.delayed(const Duration(milliseconds: 80), () => lightHaptic()),
      Future.delayed(const Duration(milliseconds: 160), () => mediumHaptic()),
      playClick(),
    ]);
  }

  Future<void> feedbackStartAction() async {
    await Future.wait([
      lightHaptic(),
      Future.delayed(const Duration(milliseconds: 60), () => playClick()),
    ]);
  }
}
