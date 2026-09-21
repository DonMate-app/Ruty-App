import '../models/feriado.dart';

class FeriadosData {
  static const List<PaisDisponible> paises = [
    PaisDisponible(codigo: 'VE', nombre: 'Venezuela', emoji: '🇻🇪'),
    PaisDisponible(codigo: 'CO', nombre: 'Colombia', emoji: '🇨🇴'),
    PaisDisponible(codigo: 'AR', nombre: 'Argentina', emoji: '🇦🇷'),
    PaisDisponible(codigo: 'MX', nombre: 'México', emoji: '🇲🇽'),
    PaisDisponible(codigo: 'ES', nombre: 'España', emoji: '🇪🇸'),
    PaisDisponible(codigo: 'US', nombre: 'Estados Unidos', emoji: '🇺🇸'),
  ];

  static PaisDisponible? paisPorCodigo(String codigo) {
    try {
      return paises.firstWhere((p) => p.codigo == codigo);
    } catch (_) {
      return null;
    }
  }

  /// Calcula el Domingo de Pascua para un año dado (algoritmo de Gauss).
  static DateTime _pascua(int anio) {
    final a = anio % 19;
    final b = anio ~/ 100;
    final c = anio % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final mes = (h + l - 7 * m + 114) ~/ 31;
    final dia = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(anio, mes, dia);
  }

  /// Devuelve la lista de feriados de un país para un año específico.
  static List<Feriado> feriadosDePais(int anio, String paisCodigo) {
    switch (paisCodigo) {
      case 'VE':
        return _venezuela(anio);
      case 'CO':
        return _colombia(anio);
      case 'AR':
        return _argentina(anio);
      case 'MX':
        return _mexico(anio);
      case 'ES':
        return _espana(anio);
      case 'US':
        return _estadosUnidos(anio);
      default:
        return [];
    }
  }

  // ═══════════════════════════════════════════════════════════
  // VENEZUELA
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _venezuela(int anio) {
    final pascua = _pascua(anio);
    return [
      Feriado(
        id: 've_anio_nuevo_$anio',
        nombre: 'Año Nuevo',
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_carnaval_lunes_$anio',
        nombre: 'Lunes de Carnaval',
        fecha: pascua.subtract(const Duration(days: 48)),
        tipo: TipoFeriado.cultural,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_carnaval_martes_$anio',
        nombre: 'Martes de Carnaval',
        fecha: pascua.subtract(const Duration(days: 47)),
        tipo: TipoFeriado.cultural,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_jueves_santo_$anio',
        nombre: 'Jueves Santo',
        fecha: pascua.subtract(const Duration(days: 3)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_viernes_santo_$anio',
        nombre: 'Viernes Santo',
        fecha: pascua.subtract(const Duration(days: 2)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_declaracion_independencia_$anio',
        nombre: 'Declaración de la Independencia',
        fecha: DateTime(anio, 4, 19),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_dia_trabajador_$anio',
        nombre: 'Día Mundial del Trabajador',
        fecha: DateTime(anio, 5, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_batalla_carabobo_$anio',
        nombre: 'Batalla de Carabobo',
        fecha: DateTime(anio, 6, 24),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_independencia_$anio',
        nombre: 'Día de la Independencia',
        fecha: DateTime(anio, 7, 5),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_natalicio_bolivar_$anio',
        nombre: 'Natalicio de Simón Bolívar',
        fecha: DateTime(anio, 7, 24),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_resistencia_indigena_$anio',
        nombre: 'Día de la Resistencia Indígena',
        fecha: DateTime(anio, 10, 12),
        tipo: TipoFeriado.cultural,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_nochebuena_$anio',
        nombre: 'Nochebuena',
        fecha: DateTime(anio, 12, 24),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_navidad_$anio',
        nombre: 'Navidad',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'VE',
      ),
      Feriado(
        id: 've_fin_anio_$anio',
        nombre: 'Fin de Año',
        fecha: DateTime(anio, 12, 31),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'VE',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // COLOMBIA
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _colombia(int anio) {
    final pascua = _pascua(anio);
    return [
      Feriado(
        id: 'co_anio_nuevo_$anio',
        nombre: 'Año Nuevo',
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_jueves_santo_$anio',
        nombre: 'Jueves Santo',
        fecha: pascua.subtract(const Duration(days: 3)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_viernes_santo_$anio',
        nombre: 'Viernes Santo',
        fecha: pascua.subtract(const Duration(days: 2)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_trabajo_$anio',
        nombre: 'Día del Trabajo',
        fecha: DateTime(anio, 5, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_independencia_$anio',
        nombre: 'Día de la Independencia',
        fecha: DateTime(anio, 7, 20),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_batalla_boyaca_$anio',
        nombre: 'Batalla de Boyacá',
        fecha: DateTime(anio, 8, 7),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'CO',
      ),
      Feriado(
        id: 'co_navidad_$anio',
        nombre: 'Navidad',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'CO',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // ARGENTINA
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _argentina(int anio) {
    final pascua = _pascua(anio);
    return [
      Feriado(
        id: 'ar_anio_nuevo_$anio',
        nombre: 'Año Nuevo',
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_carnaval_lunes_$anio',
        nombre: 'Lunes de Carnaval',
        fecha: pascua.subtract(const Duration(days: 48)),
        tipo: TipoFeriado.cultural,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_carnaval_martes_$anio',
        nombre: 'Martes de Carnaval',
        fecha: pascua.subtract(const Duration(days: 47)),
        tipo: TipoFeriado.cultural,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_malvinas_$anio',
        nombre: 'Día del Veterano de Malvinas',
        fecha: DateTime(anio, 4, 2),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_viernes_santo_$anio',
        nombre: 'Viernes Santo',
        fecha: pascua.subtract(const Duration(days: 2)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_trabajo_$anio',
        nombre: 'Día del Trabajador',
        fecha: DateTime(anio, 5, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_revolucion_mayo_$anio',
        nombre: 'Revolución de Mayo',
        fecha: DateTime(anio, 5, 25),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_independencia_$anio',
        nombre: 'Día de la Independencia',
        fecha: DateTime(anio, 7, 9),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'AR',
      ),
      Feriado(
        id: 'ar_navidad_$anio',
        nombre: 'Navidad',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'AR',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // MÉXICO
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _mexico(int anio) {
    return [
      Feriado(
        id: 'mx_anio_nuevo_$anio',
        nombre: 'Año Nuevo',
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_constitucion_$anio',
        nombre: 'Día de la Constitución',
        fecha: _primerLunesDe(anio, 2),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_juarez_$anio',
        nombre: 'Natalicio de Benito Juárez',
        fecha: _tercerLunesDe(anio, 3),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_trabajo_$anio',
        nombre: 'Día del Trabajo',
        fecha: DateTime(anio, 5, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_independencia_$anio',
        nombre: 'Día de la Independencia',
        fecha: DateTime(anio, 9, 16),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_revolucion_$anio',
        nombre: 'Revolución Mexicana',
        fecha: _tercerLunesDe(anio, 11),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'MX',
      ),
      Feriado(
        id: 'mx_navidad_$anio',
        nombre: 'Navidad',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'MX',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // ESPAÑA
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _espana(int anio) {
    final pascua = _pascua(anio);
    return [
      Feriado(
        id: 'es_anio_nuevo_$anio',
        nombre: 'Año Nuevo',
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_reyes_$anio',
        nombre: 'Día de Reyes',
        fecha: DateTime(anio, 1, 6),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_viernes_santo_$anio',
        nombre: 'Viernes Santo',
        fecha: pascua.subtract(const Duration(days: 2)),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_trabajo_$anio',
        nombre: 'Día del Trabajador',
        fecha: DateTime(anio, 5, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_asuncion_$anio',
        nombre: 'Asunción de la Virgen',
        fecha: DateTime(anio, 8, 15),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_hispanidad_$anio',
        nombre: 'Día de la Hispanidad',
        fecha: DateTime(anio, 10, 12),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_todos_los_santos_$anio',
        nombre: 'Todos los Santos',
        fecha: DateTime(anio, 11, 1),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_constitucion_$anio',
        nombre: 'Día de la Constitución',
        fecha: DateTime(anio, 12, 6),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_inmaculada_$anio',
        nombre: 'Inmaculada Concepción',
        fecha: DateTime(anio, 12, 8),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
      Feriado(
        id: 'es_navidad_$anio',
        nombre: 'Navidad',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'ES',
      ),
    ];
  }

  // ═══════════════════════════════════════════════════════════
  // ESTADOS UNIDOS
  // ═══════════════════════════════════════════════════════════

  static List<Feriado> _estadosUnidos(int anio) {
    return [
      Feriado(
        id: 'us_anio_nuevo_$anio',
        nombre: "New Year's Day",
        fecha: DateTime(anio, 1, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_martin_luther_$anio',
        nombre: 'Martin Luther King Jr. Day',
        fecha: _tercerLunesDe(anio, 1),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_presidentes_$anio',
        nombre: "Presidents' Day",
        fecha: _tercerLunesDe(anio, 2),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_memorial_$anio',
        nombre: 'Memorial Day',
        fecha: _ultimoLunesDe(anio, 5),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_independencia_$anio',
        nombre: 'Independence Day',
        fecha: DateTime(anio, 7, 4),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_trabajo_$anio',
        nombre: 'Labor Day',
        fecha: _primerLunesDe(anio, 9),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_colon_$anio',
        nombre: 'Columbus Day',
        fecha: _segundoLunesDe(anio, 10),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_veteranos_$anio',
        nombre: 'Veterans Day',
        fecha: DateTime(anio, 11, 11),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_accion_gracias_$anio',
        nombre: 'Thanksgiving',
        fecha: _cuartoJuevesDe(anio, 11),
        tipo: TipoFeriado.nacional,
        paisCodigo: 'US',
      ),
      Feriado(
        id: 'us_navidad_$anio',
        nombre: 'Christmas',
        fecha: DateTime(anio, 12, 25),
        tipo: TipoFeriado.religioso,
        paisCodigo: 'US',
      ),
    ];
  }

  // ─── Helpers de fechas dinámicas ───────────────────────────

  static DateTime _primerLunesDe(int anio, int mes) {
    final primero = DateTime(anio, mes, 1);
    final offset = (8 - primero.weekday) % 7;
    return primero.add(Duration(days: offset));
  }

  static DateTime _segundoLunesDe(int anio, int mes) {
    return _primerLunesDe(anio, mes).add(const Duration(days: 7));
  }

  static DateTime _tercerLunesDe(int anio, int mes) {
    return _primerLunesDe(anio, mes).add(const Duration(days: 14));
  }

  static DateTime _cuartoJuevesDe(int anio, int mes) {
    final primero = DateTime(anio, mes, 1);
    // Jueves = 4
    final offset = (4 - primero.weekday + 7) % 7;
    final primerJueves = primero.add(Duration(days: offset));
    return primerJueves.add(const Duration(days: 21));
  }

  static DateTime _ultimoLunesDe(int anio, int mes) {
    // Último día del mes
    final ultimoDia = DateTime(anio, mes + 1, 0);
    final offset = (ultimoDia.weekday - 1 + 7) % 7;
    return ultimoDia.subtract(Duration(days: offset));
  }
}
