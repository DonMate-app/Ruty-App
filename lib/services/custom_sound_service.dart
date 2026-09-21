import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class CustomSoundService {
  static final CustomSoundService _instance = CustomSoundService._internal();
  factory CustomSoundService() => _instance;
  CustomSoundService._internal();

  /// Formatos soportados por Android para sonidos de notificación.
  static const List<String> formatosSoportados = ['mp3', 'wav', 'ogg'];

  Future<Directory> _soundsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/custom_sounds');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Resultado de la selección de un sonido.
  Future<PickSoundResult> pickAndSaveSound() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (resultado == null || resultado.files.isEmpty) {
      return const PickSoundResult.cancelled();
    }

    final archivo = resultado.files.first;
    if (archivo.path == null) {
      return const PickSoundResult.error('No se pudo acceder al archivo');
    }

    final extension = (archivo.extension ?? '').toLowerCase();
    if (!formatosSoportados.contains(extension)) {
      return PickSoundResult.error(
        'Formato "$extension" no soportado. Usa: ${formatosSoportados.join(", ")}',
      );
    }

    try {
      final dir = await _soundsDir();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destino = File('${dir.path}/sound_$timestamp.$extension');
      await File(archivo.path!).copy(destino.path);
      return PickSoundResult.success(destino.path);
    } catch (e) {
      return PickSoundResult.error('Error al guardar: $e');
    }
  }

  Future<List<FileSystemEntity>> listarSonidos() async {
    final dir = await _soundsDir();
    if (!await dir.exists()) return [];
    final archivos = await dir.list().toList();
    archivos.sort((a, b) => b.path.compareTo(a.path));
    return archivos;
  }

  Future<void> eliminarSonido(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String nombreArchivo(String path) {
    return path.split(Platform.pathSeparator).last;
  }
}

/// Resultado de la selección de un sonido.
class PickSoundResult {
  final bool exitoso;
  final bool cancelado;
  final String? path;
  final String? error;

  const PickSoundResult._({
    this.exitoso = false,
    this.cancelado = false,
    this.path,
    this.error,
  });

  const PickSoundResult.success(String path)
      : this._(exitoso: true, path: path);

  const PickSoundResult.cancelled() : this._(cancelado: true);

  const PickSoundResult.error(String mensaje) : this._(error: mensaje);
}
