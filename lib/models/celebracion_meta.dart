import 'package:flutter/material.dart';

/// Tipo de evento que merece una celebración visual.
enum TipoCelebracion {
  metaCompletada,
  insigniaDesbloqueada,
  subioNivel,
}

/// Evento de celebración pendiente de mostrar.
class CelebracionMeta {
  final TipoCelebracion tipo;
  final String titulo;
  final String descripcion;
  final String emoji;
  final int? valor;
  final Color? color;

  const CelebracionMeta({
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.emoji,
    this.valor,
    this.color,
  });
}
