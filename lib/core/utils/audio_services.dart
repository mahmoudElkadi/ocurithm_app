import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioServices {
  static final AudioServices _instance = AudioServices._internal();
  factory AudioServices() => _instance;

  late final AudioPlayer _player;

  AudioServices._internal() {
    _player = AudioPlayer();
  }

  Future<void> playAsset(String assetPath) async {
    try {
      if (kDebugMode) {
        print("🔊 [AudioServices] Triggering sound: $assetPath");
      }
      await _player.stop(); // stop any currently playing sound
      await _player.setVolume(1.0);
      await _player.play(AssetSource(assetPath));
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ [AudioServices] Error playing sound: $e");
        print(stack);
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }
}
