import 'package:flutter/material.dart';

enum PrioridadRecomendacion {
  alta,
  media,
  baja,
}

enum CategoriaRecomendacion {
  salud,
  tiempo,
  perfil,
  bienestar,
}

class Recomendacion {
  final String id;
  final String titulo;
  final String mensaje;
  final IconData icono;
  final PrioridadRecomendacion prioridad;
  final CategoriaRecomendacion categoria;

  const Recomendacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.icono,
    required this.prioridad,
    required this.categoria,
  });

  Color color(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (prioridad) {
      case PrioridadRecomendacion.alta:
        return scheme.error;
      case PrioridadRecomendacion.media:
        return Colors.orange;
      case PrioridadRecomendacion.baja:
        return Colors.teal;
    }
  }

  String get etiquetaPrioridad {
    switch (prioridad) {
      case PrioridadRecomendacion.alta:
        return 'IMPORTANTE';
      case PrioridadRecomendacion.media:
        return 'SUGERENCIA';
      case PrioridadRecomendacion.baja:
        return 'CONSEJO';
    }
  }

  String get etiquetaCategoria {
    switch (categoria) {
      case CategoriaRecomendacion.salud:
        return 'Salud';
      case CategoriaRecomendacion.tiempo:
        return 'Tiempo';
      case CategoriaRecomendacion.perfil:
        return 'Perfil';
      case CategoriaRecomendacion.bienestar:
        return 'Bienestar';
    }
  }
}
