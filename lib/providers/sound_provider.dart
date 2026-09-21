import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class SoundProvider extends ChangeNotifier {
  bool _sonidosActivados = true;
  bool get sonidosActivados => _sonidosActivados;

  final AudioPlayer _player = AudioPlayer();

  void toggleSonidos(bool value) {
    _sonidosActivados = value;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────
  // CLICK
  // ──────────────────────────────────────────────────────────

  Future<void> reproducirClick() async {
    if (!_sonidosActivados) return;
    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silencioso si no se puede reproducir
    }
  }

  // ──────────────────────────────────────────────────────────
  // CELEBRACIONES (Fase 16.4)
  // ──────────────────────────────────────────────────────────

  /// Sonido al completar una meta.
  Future<void> reproducirMetaCompletada() async {
    await _reproducirAsset('assets/sounds/chime.mp3');
  }

  /// Sonido al desbloquear una insignia.
  Future<void> reproducirInsignia() async {
    await _reproducirAsset('assets/sounds/pop.mp3');
  }

  /// Sonido al subir de nivel.
  Future<void> reproducirSubioNivel() async {
    await _reproducirAsset('assets/sounds/chime.mp3');
  }

  // ──────────────────────────────────────────────────────────
  // INTERNO
  // ──────────────────────────────────────────────────────────

  Future<bool> _reproducirAsset(String assetPath) async {
    if (!_sonidosActivados) return false;

    try {
      // Verificar que el asset existe
      try {
        await rootBundle.load(assetPath);
      } catch (_) {
        return false;
      }

      // Detener cualquier sonido previo (ignorable si el player está vacío)
      try {
        await _player.stop();
      } catch (_) {
        // Ignorar
      }

      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.off);
      await _player.setVolume(1.0);
      await _player.play();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
