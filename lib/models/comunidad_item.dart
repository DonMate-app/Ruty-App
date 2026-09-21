import 'package:flutter/foundation.dart';

enum CategoriaComunidad {
  nutricion,
  ejercicio,
  bienestar,
  hidratacion,
  sueno,
  organizacion,
  salud,
}

extension CategoriaComunidadExt on CategoriaComunidad {
  String get nombre {
    switch (this) {
      case CategoriaComunidad.nutricion:
        return 'Nutrición';
      case CategoriaComunidad.ejercicio:
        return 'Ejercicio';
      case CategoriaComunidad.bienestar:
        return 'Bienestar';
      case CategoriaComunidad.hidratacion:
        return 'Hidratación';
      case CategoriaComunidad.sueno:
        return 'Sueño';
      case CategoriaComunidad.organizacion:
        return 'Organización';
      case CategoriaComunidad.salud:
        return 'Salud';
    }
  }

  String get emoji {
    switch (this) {
      case CategoriaComunidad.nutricion:
        return '🥗';
      case CategoriaComunidad.ejercicio:
        return '🏋️';
      case CategoriaComunidad.bienestar:
        return '🧘';
      case CategoriaComunidad.hidratacion:
        return '💧';
      case CategoriaComunidad.sueno:
        return '😴';
      case CategoriaComunidad.organizacion:
        return '📅';
      case CategoriaComunidad.salud:
        return '💊';
    }
  }
}

class ComunidadItem {
  final String id;
  String titulo;
  String descripcion;
  String autor;
  bool esSistema;
  CategoriaComunidad categoria;
  List<String> tags;
  int likes;
  bool meGusta;
  DateTime fechaCreacion;

  // Contenido estructurado opcional (para rutinas importables)
  List<String> pasos;
  int duracionMinutos;
  String dificultad; // facil, media, dificil
  bool esImportable;

  ComunidadItem({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    this.esSistema = false,
    required this.categoria,
    List<String>? tags,
    this.likes = 0,
    this.meGusta = false,
    required this.fechaCreacion,
    List<String>? pasos,
    this.duracionMinutos = 0,
    this.dificultad = 'media',
    this.esImportable = false,
  })  : tags = tags ?? [],
        pasos = pasos ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'autor': autor,
        'esSistema': esSistema,
        'categoria': categoria.name,
        'tags': tags,
        'likes': likes,
        'meGusta': meGusta,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'pasos': pasos,
        'duracionMinutos': duracionMinutos,
        'dificultad': dificultad,
        'esImportable': esImportable,
      };

  factory ComunidadItem.fromJson(Map<String, dynamic> json) {
    return ComunidadItem(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      autor: json['autor'],
      esSistema: json['esSistema'] ?? false,
      categoria: CategoriaComunidad.values.firstWhere(
        (c) => c.name == json['categoria'],
        orElse: () => CategoriaComunidad.bienestar,
      ),
      tags: List<String>.from(json['tags'] ?? []),
      likes: json['likes'] ?? 0,
      meGusta: json['meGusta'] ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      pasos: List<String>.from(json['pasos'] ?? []),
      duracionMinutos: json['duracionMinutos'] ?? 0,
      dificultad: json['dificultad'] ?? 'media',
      esImportable: json['esImportable'] ?? false,
    );
  }
}
