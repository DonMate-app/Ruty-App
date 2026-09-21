import 'package:flutter/material.dart';

class Rutina {
  final String id;
  String titulo;
  TimeOfDay hora;
  Color color;
  String grupoId;

  Rutina({
    required this.id,
    required this.titulo,
    required this.hora,
    required this.color,
    required this.grupoId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'hora': hora.hour * 60 + hora.minute,
        'color': color.toARGB32(),
        'grupoId': grupoId,
      };

  factory Rutina.fromJson(Map<String, dynamic> json) {
    final mins = json['hora'] as int;
    return Rutina(
      id: json['id'],
      titulo: json['titulo'],
      hora: TimeOfDay(hour: mins ~/ 60, minute: mins % 60),
      color: Color(json['color'] & 0xFFFFFFFF),
      grupoId: json['grupoId'],
    );
  }
}
