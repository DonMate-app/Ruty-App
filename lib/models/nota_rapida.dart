import 'package:flutter/material.dart';

class NotaRapida {
  final String id;
  String contenido;
  Color color;
  bool fijada;
  DateTime fechaCreacion;
  DateTime fechaModificacion;

  NotaRapida({
    required this.id,
    required this.contenido,
    this.color = const Color(0xFFFFF59D),
    this.fijada = false,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
  })  : fechaCreacion = fechaCreacion ?? DateTime.now(),
        fechaModificacion = fechaModificacion ?? DateTime.now();

  String get titulo {
    final lineas = contenido.trim().split('\n');
    if (lineas.isEmpty) return 'Sin título';
    final primera = lineas.first.trim();
    if (primera.isEmpty) return 'Sin título';
    return primera.length > 40 ? '${primera.substring(0, 40)}...' : primera;
  }

  String get cuerpo {
    final lineas = contenido.trim().split('\n');
    if (lineas.length <= 1) return '';
    return lineas.sublist(1).join('\n').trim();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contenido': contenido,
        'color': color.toARGB32(),
        'fijada': fijada,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'fechaModificacion': fechaModificacion.toIso8601String(),
      };

  factory NotaRapida.fromJson(Map<String, dynamic> json) {
    return NotaRapida(
      id: json['id'],
      contenido: json['contenido'],
      color: Color(json['color'] & 0xFFFFFFFF),
      fijada: json['fijada'] ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
      fechaModificacion: DateTime.parse(json['fechaModificacion']),
    );
  }
}
