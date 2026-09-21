import 'package:flutter/material.dart';

enum TipoEvento {
  alimentacion,
  accion,
  dormitar,
  medicacion,
  trabajo,
  estudio,
  ocio,
  otro,
}

enum Recurrencia {
  ninguna,
  diaria,
  semanal,
  mensual,
  anual,
}

class Evento {
  final String id;
  String titulo;
  DateTime fecha;
  TimeOfDay horaInicio;
  TimeOfDay horaFin;
  Color color;
  bool suspendido;
  bool cruzaMedianoche;
  TipoEvento tipo;
  Recurrencia recurrencia;

  /// Id de la ilustración (emoji) asociada. Null si no tiene.
  String? ilustracion;

  Evento({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.color,
    this.suspendido = false,
    this.cruzaMedianoche = false,
    this.tipo = TipoEvento.otro,
    this.recurrencia = Recurrencia.ninguna,
    this.ilustracion,
  });

  factory Evento.conDuracion({
    required String id,
    required String titulo,
    required DateTime fecha,
    required TimeOfDay horaInicio,
    required Duration duracion,
    required Color color,
    bool suspendido = false,
    TipoEvento tipo = TipoEvento.otro,
    Recurrencia recurrencia = Recurrencia.ninguna,
    String? ilustracion,
  }) {
    final minutosInicio = horaInicio.hour * 60 + horaInicio.minute;
    final minutosFin = minutosInicio + duracion.inMinutes;
    final cruza = minutosFin >= 24 * 60;
    final minutosFinAjustados = cruza ? 24 * 60 - 1 : minutosFin;
    return Evento(
      id: id,
      titulo: titulo,
      fecha: fecha,
      horaInicio: horaInicio,
      horaFin: TimeOfDay(
        hour: minutosFinAjustados ~/ 60,
        minute: minutosFinAjustados % 60,
      ),
      color: color,
      suspendido: suspendido,
      cruzaMedianoche: cruza,
      tipo: tipo,
      recurrencia: recurrencia,
      ilustracion: ilustracion,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'fecha': fecha.toIso8601String(),
        'horaInicio': horaInicio.hour * 60 + horaInicio.minute,
        'horaFin': horaFin.hour * 60 + horaFin.minute,
        'color': color.toARGB32(),
        'suspendido': suspendido,
        'cruzaMedianoche': cruzaMedianoche,
        'tipo': tipo.name,
        'recurrencia': recurrencia.name,
        'ilustracion': ilustracion,
      };

  factory Evento.fromJson(Map<String, dynamic> json) {
    final fecha = DateTime.parse(json['fecha']);
    final ini = json['horaInicio'] as int;
    final fin = json['horaFin'] as int;
    return Evento(
      id: json['id'],
      titulo: json['titulo'],
      fecha: fecha,
      horaInicio: TimeOfDay(hour: ini ~/ 60, minute: ini % 60),
      horaFin: TimeOfDay(hour: fin ~/ 60, minute: fin % 60),
      color: Color(json['color'] & 0xFFFFFFFF),
      suspendido: json['suspendido'] ?? false,
      cruzaMedianoche: json['cruzaMedianoche'] ?? false,
      tipo: TipoEvento.values.firstWhere(
        (t) => t.name == json['tipo'],
        orElse: () => TipoEvento.otro,
      ),
      recurrencia: Recurrencia.values.firstWhere(
        (r) => r.name == json['recurrencia'],
        orElse: () => Recurrencia.ninguna,
      ),
      ilustracion: json['ilustracion'],
    );
  }

  bool ocurreEnFecha(DateTime fecha) {
    if (recurrencia == Recurrencia.ninguna) {
      return this.fecha.year == fecha.year &&
          this.fecha.month == fecha.month &&
          this.fecha.day == fecha.day;
    }
    final fechaBase = this.fecha;
    final diferencia = fecha.difference(fechaBase).inDays;
    if (diferencia < 0) return false;
    switch (recurrencia) {
      case Recurrencia.diaria:
        return true;
      case Recurrencia.semanal:
        return diferencia % 7 == 0;
      case Recurrencia.mensual:
        return fecha.day == fechaBase.day && fecha.month != fechaBase.month ||
            (fecha.month == fechaBase.month && fecha.day == fechaBase.day);
      case Recurrencia.anual:
        return fecha.day == fechaBase.day && fecha.month == fechaBase.month;
      default:
        return false;
    }
  }

  Evento copiaParaFecha(DateTime nuevaFecha) {
    return Evento(
      id: id,
      titulo: titulo,
      fecha: nuevaFecha,
      horaInicio: horaInicio,
      horaFin: horaFin,
      color: color,
      suspendido: suspendido,
      cruzaMedianoche: cruzaMedianoche,
      tipo: tipo,
      recurrencia: recurrencia,
      ilustracion: ilustracion,
    );
  }
}
