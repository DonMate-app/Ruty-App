import 'package:flutter/material.dart';

class Insignia {
  final String id;
  final String nombre;
  final String descripcion;
  final String emoji;
  final Color color;
  bool obtenida;
  DateTime? fechaObtenida;

  Insignia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    required this.color,
    this.obtenida = false,
    this.fechaObtenida,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'obtenida': obtenida,
        'fechaObtenida': fechaObtenida?.toIso8601String(),
      };

  Map<String, dynamic> toJsonCompleto() => {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'emoji': emoji,
        'color': color.toARGB32(),
        'obtenida': obtenida,
        'fechaObtenida': fechaObtenida?.toIso8601String(),
      };

  factory Insignia.fromJson(Map<String, dynamic> json) {
    return Insignia(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      emoji: json['emoji'] ?? '🏅',
      color: Color(json['color'] ?? 0xFFFBC02D),
      obtenida: json['obtenida'] ?? false,
      fechaObtenida: json['fechaObtenida'] != null
          ? DateTime.tryParse(json['fechaObtenida'])
          : null,
    );
  }
}

/// Definiciones de las insignias del sistema.
class InsigniasCatalogo {
  static final List<Insignia> todas = [
    Insignia(
      id: 'primer_paso',
      nombre: 'Primer Paso',
      descripcion: 'Completa tu primera meta',
      emoji: '👣',
      color: Colors.green,
    ),
    Insignia(
      id: 'hidratado',
      nombre: 'Hidratado',
      descripcion: 'Completa 3 metas relacionadas con agua',
      emoji: '💧',
      color: Colors.blue,
    ),
    Insignia(
      id: 'deportista',
      nombre: 'Deportista',
      descripcion: 'Completa 3 metas de ejercicio',
      emoji: '🏃',
      color: Colors.orange,
    ),
    Insignia(
      id: 'constante',
      nombre: 'Constante',
      descripcion: 'Completa 10 metas',
      emoji: '🔥',
      color: Colors.deepOrange,
    ),
    Insignia(
      id: 'organizado',
      nombre: 'Organizado',
      descripcion: 'Completa 3 metas de tiempo o tareas',
      emoji: '📅',
      color: Colors.indigo,
    ),
    Insignia(
      id: 'nutricionista',
      nombre: 'Nutricionista',
      descripcion: 'Completa 3 metas de alimentación',
      emoji: '🥗',
      color: Colors.green,
    ),
    Insignia(
      id: 'medico_puntual',
      nombre: 'Puntual',
      descripcion: 'Completa 3 metas de medicación',
      emoji: '💊',
      color: Colors.red,
    ),
    Insignia(
      id: 'maratonista',
      nombre: 'Maratonista',
      descripcion: '30 días seguidos con actividad física',
      emoji: '🏅',
      color: Colors.amber,
    ),
    Insignia(
      id: 'sabio',
      nombre: 'Sabio',
      descripcion: 'Alcanza el nivel 6',
      emoji: '🧠',
      color: Colors.purple,
    ),
    Insignia(
      id: 'templo',
      nombre: 'Templo',
      descripcion: 'Alcanza el nivel máximo',
      emoji: '🏛️',
      color: Colors.amber,
    ),
  ];

  static Insignia? porId(String id) {
    try {
      return todas.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
