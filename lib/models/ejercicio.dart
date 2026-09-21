import 'package:flutter/material.dart';

class Ejercicio {
  final String id;
  String nombre;
  String tipo; // e.g., cardio, fuerza, flexibilidad
  int objetivoMinutos; // duración en minutos
  int objetivoRepeticiones; // 0 si no aplica
  Color color;

  Ejercicio({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.objetivoMinutos,
    required this.objetivoRepeticiones,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'objetivoMinutos': objetivoMinutos,
        'objetivoRepeticiones': objetivoRepeticiones,
        'color': color.toARGB32(),
      };

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      objetivoMinutos: json['objetivoMinutos'],
      objetivoRepeticiones: json['objetivoRepeticiones'],
      color: Color(json['color'] & 0xFFFFFFFF),
    );
  }
}
