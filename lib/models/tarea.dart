import 'package:flutter/material.dart';

enum UnidadDuracion {
  minutos,
  horas,
  dias,
  meses,
  anios,
}

enum PrioridadTarea {
  baja,
  media,
  alta,
}

class Tarea {
  final String id;
  String titulo;
  String descripcion;
  int duracion;
  UnidadDuracion unidad;
  Color color;
  bool completada;
  PrioridadTarea prioridad;
  DateTime? fechaLimite;
  DateTime fechaCreacion;

  Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    required this.duracion,
    required this.unidad,
    required this.color,
    this.completada = false,
    this.prioridad = PrioridadTarea.media,
    this.fechaLimite,
    required this.fechaCreacion,
  });

  String get duracionFormateada {
    switch (unidad) {
      case UnidadDuracion.minutos:
        return '$duracion min';
      case UnidadDuracion.horas:
        return '$duracion h';
      case UnidadDuracion.dias:
        return '$duracion d';
      case UnidadDuracion.meses:
        return '$duracion m';
      case UnidadDuracion.anios:
        return '$duracion a';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'duracion': duracion,
        'unidad': unidad.name,
        'color': color.toARGB32(),
        'completada': completada,
        'prioridad': prioridad.name,
        'fechaLimite': fechaLimite?.toIso8601String(),
        'fechaCreacion': fechaCreacion.toIso8601String(),
      };

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'] ?? '',
      duracion: json['duracion'],
      unidad: UnidadDuracion.values.firstWhere(
        (u) => u.name == json['unidad'],
        orElse: () => UnidadDuracion.minutos,
      ),
      color: Color(json['color'] & 0xFFFFFFFF),
      completada: json['completada'] ?? false,
      prioridad: PrioridadTarea.values.firstWhere(
        (p) => p.name == json['prioridad'],
        orElse: () => PrioridadTarea.media,
      ),
      fechaLimite: json['fechaLimite'] != null
          ? DateTime.parse(json['fechaLimite'])
          : null,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
