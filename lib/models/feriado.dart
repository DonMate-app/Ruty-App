import 'package:flutter/material.dart';

enum TipoFeriado {
  nacional,
  religioso,
  cultural,
  regional,
}

class Feriado {
  final String id;
  final String nombre;
  final DateTime fecha;
  final TipoFeriado tipo;
  final String paisCodigo;

  const Feriado({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.tipo,
    required this.paisCodigo,
  });

  /// Indica si este feriado ocurre en el día indicado.
  bool ocurreEn(DateTime dia) {
    return fecha.year == dia.year &&
        fecha.month == dia.month &&
        fecha.day == dia.day;
  }

  Color color(BuildContext context) {
    switch (tipo) {
      case TipoFeriado.nacional:
        return Colors.red.shade600;
      case TipoFeriado.religioso:
        return Colors.purple.shade500;
      case TipoFeriado.cultural:
        return Colors.orange.shade700;
      case TipoFeriado.regional:
        return Colors.teal.shade600;
    }
  }

  String get etiquetaTipo {
    switch (tipo) {
      case TipoFeriado.nacional:
        return 'Nacional';
      case TipoFeriado.religioso:
        return 'Religioso';
      case TipoFeriado.cultural:
        return 'Cultural';
      case TipoFeriado.regional:
        return 'Regional';
    }
  }

  IconData get icono {
    switch (tipo) {
      case TipoFeriado.nacional:
        return Icons.flag;
      case TipoFeriado.religioso:
        return Icons.church;
      case TipoFeriado.cultural:
        return Icons.celebration;
      case TipoFeriado.regional:
        return Icons.location_city;
    }
  }
}

class PaisDisponible {
  final String codigo;
  final String nombre;
  final String emoji;

  const PaisDisponible({
    required this.codigo,
    required this.nombre,
    required this.emoji,
  });
}
