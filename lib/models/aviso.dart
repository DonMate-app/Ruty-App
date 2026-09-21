import 'package:flutter/material.dart';

enum TipoAviso {
  exito,
  info,
  advertencia,
  error,
}

class Aviso {
  final String id;
  final String mensaje;
  final TipoAviso tipo;
  final DateTime timestamp;
  final Duration duracion;

  Aviso({
    required this.id,
    required this.mensaje,
    this.tipo = TipoAviso.info,
    DateTime? timestamp,
    this.duracion = const Duration(seconds: 3),
  }) : timestamp = timestamp ?? DateTime.now();

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (tipo) {
      case TipoAviso.exito:
        return Colors.green.shade600;
      case TipoAviso.info:
        return scheme.primary;
      case TipoAviso.advertencia:
        return Colors.orange.shade700;
      case TipoAviso.error:
        return scheme.error;
    }
  }

  IconData get icono {
    switch (tipo) {
      case TipoAviso.exito:
        return Icons.check_circle;
      case TipoAviso.info:
        return Icons.info;
      case TipoAviso.advertencia:
        return Icons.warning_amber;
      case TipoAviso.error:
        return Icons.error;
    }
  }
}
