import 'package:flutter/foundation.dart';

class ResumenSemanal {
  final DateTime inicioSemana;
  final DateTime finSemana;

  final int eventosCreados;
  final int eventosCompletados;
  final int tareasCompletadas;
  final int tareasPendientes;
  final int diasConEjercicio;
  final int minutosEjercicio;
  final int registrosAlimentacion;
  final int dosisTomadas;
  final int dosisEsperadas;

  const ResumenSemanal({
    required this.inicioSemana,
    required this.finSemana,
    required this.eventosCreados,
    required this.eventosCompletados,
    required this.tareasCompletadas,
    required this.tareasPendientes,
    required this.diasConEjercicio,
    required this.minutosEjercicio,
    required this.registrosAlimentacion,
    required this.dosisTomadas,
    required this.dosisEsperadas,
  });

  /// Porcentaje de adherencia a medicación (0.0 - 1.0).
  double get adherenciaMedicacion {
    if (dosisEsperadas == 0) return 0;
    return (dosisTomadas / dosisEsperadas).clamp(0.0, 1.0);
  }

  /// Porcentaje de días con ejercicio sobre 7.
  double get cumplimientoEjercicio {
    return (diasConEjercicio / 7).clamp(0.0, 1.0);
  }

  /// Total de acciones positivas de la semana.
  int get totalLogros {
    return eventosCompletados +
        tareasCompletadas +
        diasConEjercicio +
        registrosAlimentacion +
        dosisTomadas;
  }

  /// Mensaje motivacional dinámico según los logros.
  String get mensajeMotivacional {
    if (totalLogros == 0) {
      return 'Esta semana empieza de cero. ¡Vamos a por ella!';
    }
    if (totalLogros < 10) {
      return 'Buen comienzo. Cada pequeño paso cuenta.';
    }
    if (totalLogros < 30) {
      return '¡Buen ritmo! Sigue así esta semana.';
    }
    if (totalLogros < 60) {
      return '¡Excelente trabajo! Estás construyendo buenos hábitos.';
    }
    return '¡Increíble semana! Eres una inspiración.';
  }

  /// Devuelve true si la semana tiene datos relevantes que mostrar.
  bool get tieneDatos {
    return totalLogros > 0 || tareasPendientes > 0;
  }

  Map<String, dynamic> toJson() => {
        'inicioSemana': inicioSemana.toIso8601String(),
        'finSemana': finSemana.toIso8601String(),
        'eventosCreados': eventosCreados,
        'eventosCompletados': eventosCompletados,
        'tareasCompletadas': tareasCompletadas,
        'tareasPendientes': tareasPendientes,
        'diasConEjercicio': diasConEjercicio,
        'minutosEjercicio': minutosEjercicio,
        'registrosAlimentacion': registrosAlimentacion,
        'dosisTomadas': dosisTomadas,
        'dosisEsperadas': dosisEsperadas,
      };
}
