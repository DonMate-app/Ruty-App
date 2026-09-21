import 'package:flutter/material.dart';

class GrupoRutinas {
  final String id;
  String nombre;
  Color color;

  GrupoRutinas({required this.id, required this.nombre, required this.color});

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'color': color.toARGB32(),
      };

  factory GrupoRutinas.fromJson(Map<String, dynamic> json) => GrupoRutinas(
        id: json['id'],
        nombre: json['nombre'],
        color: Color(json['color'] & 0xFFFFFFFF),
      );
}
