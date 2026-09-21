import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class AlarmaService extends ChangeNotifier {
  static final AlarmaService _instance = AlarmaService._internal();
  factory AlarmaService() => _instance;
  AlarmaService._internal();

  final AudioPlayer _player = AudioPlayer();

  bool _reproduciendo = false;
  bool get reproduciendo => _reproduciendo;

  String? _payloadActual;
  String? get payloadActual => _payloadActual;

  String? _tituloActual;
  String? get tituloActual => _tituloActual;

  String? _cuerpoActual;
  String? get cuerpoActual => _cuerpoActual;

  static const List<String> _assetsSonidos = [
    'alarm',
    'chime',
    'ding',
    'pop',
    'beep',
  ];

  Future<void> iniciar({
    required String sonido,
    required String payload,
    required String titulo,
    required String cuerpo,
    required bool vibrar,
  }) async {
    _payloadActual = payload;
    _tituloActual = titulo;
    _cuerpoActual = cuerpo;
    _reproduciendo = true;
    notifyListeners();

    debugPrint('🎵 [Alarma] Iniciando con sonido: "$sonido"');

    bool exito = false;

    if (sonido.startsWith('custom:')) {
      final path = sonido.substring('custom:'.length);
      exito = await _intentarArchivoCustom(path);
    } else {
      exito = await _intentarAssetPredefinido(sonido);
    }

    if (!exito && sonido != 'alarm') {
      debugPrint('🎵 [Alarma] Fallback a "alarm"');
      exito = await _intentarAssetPredefinido('alarm');
    }

    if (!exito) {
      debugPrint('🎵 [Alarma] Fallback a SystemSound');
      try {
        await SystemSound.play(SystemSoundType.alert);
        exito = true;
      } catch (e) {
        debugPrint('🎵 [Alarma] SystemSound también falló: $e');
      }
    }

    if (exito) {
      debugPrint('🎵 [Alarma] Reproduciendo correctamente');
    } else {
      debugPrint('🎵 [Alarma] ❌ No se pudo reproducir ningún sonido');
    }
  }

  Future<bool> _intentarAssetPredefinido(String nombre) async {
    final nombreLimpio = nombre.replaceAll('.mp3', '');

    if (!_assetsSonidos.contains(nombreLimpio)) {
      debugPrint('🎵 [Alarma] "$nombreLimpio" no está en la lista de assets');
      return false;
    }

    final assetPath = 'assets/sounds/$nombreLimpio.mp3';
    return await _reproducirAsset(assetPath);
  }

  Future<bool> _intentarArchivoCustom(String path) async {
    try {
      debugPrint('🎵 [Alarma] Intentando custom: $path');
      await _player.stop();
      await _player.setFilePath(path);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0);
      await _player.play();
      return true;
    } catch (e) {
      debugPrint('🎵 [Alarma] Error custom: $e');
      return false;
    }
  }

  Future<bool> _reproducirAsset(String assetPath) async {
    try {
      debugPrint('🎵 [Alarma] Intentando asset: $assetPath');

      try {
        await rootBundle.load(assetPath);
      } catch (e) {
        debugPrint('🎵 [Alarma] Asset NO existe: $assetPath');
        return false;
      }

      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(1.0);
      await _player.play();
      return true;
    } catch (e) {
      debugPrint('🎵 [Alarma] Error asset: $e');
      return false;
    }
  }

  Future<void> detener() async {
    _reproduciendo = false;
    _payloadActual = null;
    _tituloActual = null;
    _cuerpoActual = null;
    try {
      await _player.stop();
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
