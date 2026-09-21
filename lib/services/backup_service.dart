import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/alimento_registro.dart';
import '../models/comunidad_item.dart';
import '../models/ejercicio.dart';
import '../models/evento.dart';
import '../models/grupo_rutinas.dart';
import '../models/medicamento.dart';
import '../models/nota_rapida.dart';
import '../models/perfil_usuario.dart';
import '../models/registro_ejercicio.dart';
import '../models/registro_medicacion.dart';
import '../models/rutina.dart';
import '../models/tarea.dart';

/// Servicio encargado de exportar e importar todos los datos de la app
/// en formato JSON.
class BackupService {
  static const int versionBackup = 1;

  /// Genera el JSON completo con todos los datos.
  Map<String, dynamic> generarBackup({
    required List<Evento> eventos,
    required List<Rutina> rutinas,
    required List<GrupoRutinas> grupos,
    required List<Tarea> tareas,
    required List<AlimentoRegistro> alimentacion,
    required List<Ejercicio> ejercicios,
    required List<RegistroEjercicio> registrosEjercicio,
    required List<Medicamento> medicamentos,
    required List<RegistroMedicacion> registrosMedicacion,
    required PerfilUsuario perfil,
    required List<ComunidadItem> itemsUsuario,
    required Set<String> likesComunidad,
    required List<NotaRapida> notas,
  }) {
    return {
      'app': 'Horario App',
      'version': versionBackup,
      'fechaExportacion': DateTime.now().toIso8601String(),
      'datos': {
        'eventos': eventos.map((e) => e.toJson()).toList(),
        'rutinas': rutinas.map((r) => r.toJson()).toList(),
        'grupos': grupos.map((g) => g.toJson()).toList(),
        'tareas': tareas.map((t) => t.toJson()).toList(),
        'alimentacion': alimentacion.map((a) => a.toJson()).toList(),
        'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
        'registrosEjercicio':
        registrosEjercicio.map((r) => r.toJson()).toList(),
        'medicamentos': medicamentos.map((m) => m.toJson()).toList(),
        'registrosMedicacion':
        registrosMedicacion.map((r) => r.toJson()).toList(),
        'perfil': perfil.toJson(),
        'comunidadUsuario':
        itemsUsuario.map((i) => i.toJson()).toList(),
        'comunidadLikes': likesComunidad.toList(),
        'notas': notas.map((n) => n.toJson()).toList(),
      },
    };
  }

  /// Guarda el backup en un archivo temporal y devuelve su ruta.
  Future<File> guardarBackupEnArchivo(Map<String, dynamic> backup) async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final archivo = File('${dir.path}/horario_backup_$timestamp.json');
    const encoder = JsonEncoder.withIndent('  ');
    await archivo.writeAsString(encoder.convert(backup));
    return archivo;
  }

  /// Abre el selector de archivos y devuelve el JSON cargado.
  /// Devuelve null si el usuario canceló.
  Future<Map<String, dynamic>?> seleccionarYLeerBackup() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );
    if (resultado == null || resultado.files.isEmpty) return null;

    final archivo = resultado.files.first;
    if (archivo.path == null) return null;

    final contenido = await File(archivo.path!).readAsString();
    try {
      final json = jsonDecode(contenido);
      if (json is! Map<String, dynamic>) {
        throw const FormatException('El archivo no tiene el formato esperado');
      }
      return json;
    } catch (e) {
      throw FormatException('Error al leer el archivo: $e');
    }
  }

  /// Valida la estructura de un backup.
  /// Devuelve null si es válido, o un mensaje de error si no lo es.
  String? validarBackup(Map<String, dynamic> backup) {
    if (!backup.containsKey('app') ||
        backup['app'] != 'Horario App') {
      return 'El archivo no es un backup válido de Horario App.';
    }
    if (!backup.containsKey('version')) {
      return 'El archivo no tiene versión definida.';
    }
    final version = backup['version'];
    if (version is! int || version > versionBackup) {
      return 'La versión del backup ($version) es más reciente '
          'que la soportada por esta app ($versionBackup).';
    }
    if (!backup.containsKey('datos')) {
      return 'El archivo no contiene datos.';
    }
    return null;
  }

  /// Devuelve el mapa de datos o un mapa vacío si no existe.
  Map<String, dynamic> extraerDatos(Map<String, dynamic> backup) {
    final datos = backup['datos'];
    if (datos is Map<String, dynamic>) return datos;
    return {};
  }

  /// Resumen legible de un backup (para mostrar antes de importar).
  String describirBackup(Map<String, dynamic> backup) {
    final datos = extraerDatos(backup);
    final fecha = backup['fechaExportacion'] as String?;
    final fechaLegible = fecha != null
        ? DateTime.parse(fecha).toLocal().toString().split('.first').first
        : 'Fecha desconocida';

    return 'Fecha: $fechaLegible\n'
        'Eventos: ${(datos['eventos'] as List?)?.length ?? 0}\n'
        'Rutinas: ${(datos['rutinas'] as List?)?.length ?? 0}\n'
        'Tareas: ${(datos['tareas'] as List?)?.length ?? 0}\n'
        'Registros alimentación: '
        '${(datos['alimentacion'] as List?)?.length ?? 0}\n'
        'Ejercicios: ${(datos['ejercicios'] as List?)?.length ?? 0}\n'
        'Medicamentos: ${(datos['medicamentos'] as List?)?.length ?? 0}\n'
        'Notas: ${(datos['notas'] as List?)?.length ?? 0}';
  }
}