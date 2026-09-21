import 'package:flutter/material.dart';

enum DificultadMeta {
  facil,
  moderado,
  avanzado,
  templo,
}

extension DificultadMetaExt on DificultadMeta {
  String get nombre {
    switch (this) {
      case DificultadMeta.facil:
        return 'Fácil';
      case DificultadMeta.moderado:
        return 'Moderado';
      case DificultadMeta.avanzado:
        return 'Avanzado';
      case DificultadMeta.templo:
        return 'Templo';
    }
  }

  int get recompensaXP {
    switch (this) {
      case DificultadMeta.facil:
        return 10;
      case DificultadMeta.moderado:
        return 25;
      case DificultadMeta.avanzado:
        return 50;
      case DificultadMeta.templo:
        return 200;
    }
  }

  Color get color {
    switch (this) {
      case DificultadMeta.facil:
        return Colors.green;
      case DificultadMeta.moderado:
        return Colors.blue;
      case DificultadMeta.avanzado:
        return Colors.orange;
      case DificultadMeta.templo:
        return Colors.purple;
    }
  }

  IconData get icono {
    switch (this) {
      case DificultadMeta.facil:
        return Icons.sentiment_satisfied_alt;
      case DificultadMeta.moderado:
        return Icons.local_fire_department;
      case DificultadMeta.avanzado:
        return Icons.whatshot;
      case DificultadMeta.templo:
        return Icons.temple_buddhist;
    }
  }
}

enum CategoriaMeta {
  salud,
  tiempo,
  bienestar,
  constancia,
  mixto,
}

extension CategoriaMetaExt on CategoriaMeta {
  String get nombre {
    switch (this) {
      case CategoriaMeta.salud:
        return 'Salud';
      case CategoriaMeta.tiempo:
        return 'Tiempo';
      case CategoriaMeta.bienestar:
        return 'Bienestar';
      case CategoriaMeta.constancia:
        return 'Constancia';
      case CategoriaMeta.mixto:
        return 'Mixto';
    }
  }

  IconData get icono {
    switch (this) {
      case CategoriaMeta.salud:
        return Icons.health_and_safety;
      case CategoriaMeta.tiempo:
        return Icons.schedule;
      case CategoriaMeta.bienestar:
        return Icons.spa;
      case CategoriaMeta.constancia:
        return Icons.trending_up;
      case CategoriaMeta.mixto:
        return Icons.auto_awesome;
    }
  }

  Color get color {
    switch (this) {
      case CategoriaMeta.salud:
        return Colors.red;
      case CategoriaMeta.tiempo:
        return Colors.indigo;
      case CategoriaMeta.bienestar:
        return Colors.teal;
      case CategoriaMeta.constancia:
        return Colors.orange;
      case CategoriaMeta.mixto:
        return Colors.purple;
    }
  }
}

/// Tipos de progreso automático.
enum TipoProgresoMeta {
  /// Días seguidos registrando algo (agua, ejercicio, etc.)
  diasConsecutivos,

  /// Total de registros acumulados (agua, comida, notas, etc.)
  totalRegistros,

  /// Total de minutos acumulados (ejercicio).
  totalMinutos,

  /// Adherencia porcentual (medicación).
  adherenciaPorcentaje,

  /// Total de tareas completadas.
  totalTareasCompletadas,

  /// Total de eventos creados.
  totalEventos,

  /// Total de rutinas aplicadas.
  totalRutinasAplicadas,

  /// El usuario marca manualmente como completada.
  manual,
}

extension TipoProgresoMetaExt on TipoProgresoMeta {
  String get nombre {
    switch (this) {
      case TipoProgresoMeta.diasConsecutivos:
        return 'Días consecutivos';
      case TipoProgresoMeta.totalRegistros:
        return 'Total de registros';
      case TipoProgresoMeta.totalMinutos:
        return 'Minutos acumulados';
      case TipoProgresoMeta.adherenciaPorcentaje:
        return 'Adherencia (%)';
      case TipoProgresoMeta.totalTareasCompletadas:
        return 'Tareas completadas';
      case TipoProgresoMeta.totalEventos:
        return 'Eventos creados';
      case TipoProgresoMeta.totalRutinasAplicadas:
        return 'Rutinas aplicadas';
      case TipoProgresoMeta.manual:
        return 'Marcar manualmente';
    }
  }

  bool get esCalculable => this != TipoProgresoMeta.manual;
}

/// Filtro específico para días consecutivos y total de registros.
enum FiltroMeta {
  ninguno,
  agua,
  ejercicio,
  alimentacion,
  notas,
  medicacion,
}

extension FiltroMetaExt on FiltroMeta {
  String get nombre {
    switch (this) {
      case FiltroMeta.ninguno:
        return 'General';
      case FiltroMeta.agua:
        return 'Agua';
      case FiltroMeta.ejercicio:
        return 'Ejercicio';
      case FiltroMeta.alimentacion:
        return 'Alimentación';
      case FiltroMeta.notas:
        return 'Notas';
      case FiltroMeta.medicacion:
        return 'Medicación';
    }
  }

  String get emoji {
    switch (this) {
      case FiltroMeta.ninguno:
        return '⭐';
      case FiltroMeta.agua:
        return '💧';
      case FiltroMeta.ejercicio:
        return '🏃';
      case FiltroMeta.alimentacion:
        return '🥗';
      case FiltroMeta.notas:
        return '📝';
      case FiltroMeta.medicacion:
        return '💊';
    }
  }
}

class Meta {
  final String id;
  String titulo;
  String descripcion;
  DificultadMeta dificultad;
  CategoriaMeta categoria;
  TipoProgresoMeta tipoProgreso;
  FiltroMeta filtro;
  int objetivo;
  int progresoActual;
  bool completada;
  bool archivada;
  bool esPersonalizada;
  DateTime fechaCreacion;
  DateTime? fechaCompletada;
  String emoji;

  Meta({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.dificultad,
    required this.categoria,
    required this.tipoProgreso,
    this.filtro = FiltroMeta.ninguno,
    required this.objetivo,
    this.progresoActual = 0,
    this.completada = false,
    this.archivada = false,
    this.esPersonalizada = false,
    DateTime? fechaCreacion,
    this.fechaCompletada,
    this.emoji = '🎯',
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  int get recompensaXP => dificultad.recompensaXP;

  double get porcentajeProgreso {
    if (objetivo <= 0) return 0;
    return (progresoActual / objetivo).clamp(0.0, 1.0);
  }

  /// Devuelve true si el progreso alcanzó el objetivo.
  bool get alcanzoObjetivo => progresoActual >= objetivo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'dificultad': dificultad.name,
        'categoria': categoria.name,
        'tipoProgreso': tipoProgreso.name,
        'filtro': filtro.name,
        'objetivo': objetivo,
        'progresoActual': progresoActual,
        'completada': completada,
        'archivada': archivada,
        'esPersonalizada': esPersonalizada,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaCompletada': fechaCompletada?.toIso8601String(),
        'emoji': emoji,
      };

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'] ?? '',
      dificultad: DificultadMeta.values.firstWhere(
        (d) => d.name == json['dificultad'],
        orElse: () => DificultadMeta.facil,
      ),
      categoria: CategoriaMeta.values.firstWhere(
        (c) => c.name == json['categoria'],
        orElse: () => CategoriaMeta.mixto,
      ),
      tipoProgreso: TipoProgresoMeta.values.firstWhere(
        (t) => t.name == json['tipoProgreso'],
        orElse: () => TipoProgresoMeta.manual,
      ),
      filtro: FiltroMeta.values.firstWhere(
        (f) => f.name == json['filtro'],
        orElse: () => FiltroMeta.ninguno,
      ),
      objetivo: json['objetivo'] ?? 1,
      progresoActual: json['progresoActual'] ?? 0,
      completada: json['completada'] ?? false,
      archivada: json['archivada'] ?? false,
      esPersonalizada: json['esPersonalizada'] ?? false,
      fechaCreacion:
          DateTime.tryParse(json['fechaCreacion'] ?? '') ?? DateTime.now(),
      fechaCompletada: json['fechaCompletada'] != null
          ? DateTime.tryParse(json['fechaCompletada'])
          : null,
      emoji: json['emoji'] ?? '🎯',
    );
  }
}
