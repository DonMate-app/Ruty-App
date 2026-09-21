import 'package:flutter/material.dart';

class Medicamento {
  final String id;
  String nombre;
  String dosis;
  String frecuencia; // e.g., "cada 8 horas", "diario"
  TimeOfDay hora;
  Color color;

  Medicamento({
    required this.id,
    required this.nombre,
    required this.dosis,
    required this.frecuencia,
    required this.hora,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'dosis': dosis,
        'frecuencia': frecuencia,
        'hora': hora.hour * 60 + hora.minute,
        'color': color.toARGB32(),
      };

  factory Medicamento.fromJson(Map<String, dynamic> json) {
    final mins = json['hora'] as int;
    return Medicamento(
      id: json['id'],
      nombre: json['nombre'],
      dosis: json['dosis'],
      frecuencia: json['frecuencia'],
      hora: TimeOfDay(hour: mins ~/ 60, minute: mins % 60),
      color: Color(json['color'] & 0xFFFFFFFF),
    );
  }
}
