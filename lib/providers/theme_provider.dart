import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _colorPrimario = Colors.indigo;
  Color get colorPrimario => _colorPrimario;

  ThemeMode _modoManual = ThemeMode.system;
  ThemeMode get modoManual => _modoManual;

  bool _modoAutomatico = false;
  bool get modoAutomatico => _modoAutomatico;

  /// Hora + minuto de inicio del modo oscuro automático.
  TimeOfDay _inicioOscuro = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay get inicioOscuro => _inicioOscuro;

  /// Hora + minuto de fin del modo oscuro automático.
  TimeOfDay _finOscuro = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay get finOscuro => _finOscuro;

  bool _animacionesActivadas = true;
  bool get animacionesActivadas => _animacionesActivadas;

  double _radioBorde = 8.0;
  double get radioBorde => _radioBorde;

  bool _modoExperto = false;
  bool get modoExperto => _modoExperto;

  // ── Tipografía ──
  String _fontFamily = 'Roboto';
  String get fontFamily => _fontFamily;

  double _fontScale = 1.0;
  double get fontScale => _fontScale;

  Color? _textColor;
  Color? get textColor => _textColor;

  double _textOpacity = 1.0;
  double get textOpacity => _textOpacity;

  ThemeMode? _ultimoModoEfectivo;
  Timer? _timerModoAutomatico;

  ThemeProvider() {
    _ultimoModoEfectivo = themeMode;
    _iniciarTimerModoAutomatico();
  }

  /// Minutos desde medianoche para comparar horas y minutos.
  int _aMinutos(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Modo efectivo que se aplica a la app.
  ThemeMode get themeMode {
    if (!_modoAutomatico) return _modoManual;

    final ahora = DateTime.now();
    final minutosActuales = ahora.hour * 60 + ahora.minute;
    final inicio = _aMinutos(_inicioOscuro);
    final fin = _aMinutos(_finOscuro);

    if (inicio == fin) return _modoManual;

    final cruzaMedianoche = inicio > fin;

    final esOscuro = cruzaMedianoche
        ? (minutosActuales >= inicio || minutosActuales < fin)
        : (minutosActuales >= inicio && minutosActuales < fin);

    return esOscuro ? ThemeMode.dark : ThemeMode.light;
  }

  /// Descripción legible del rango horario.
  String get descripcionRangoOscuro {
    final ini =
        '${_inicioOscuro.hour.toString().padLeft(2, '0')}:${_inicioOscuro.minute.toString().padLeft(2, '0')}';
    final fin =
        '${_finOscuro.hour.toString().padLeft(2, '0')}:${_finOscuro.minute.toString().padLeft(2, '0')}';
    return 'De $ini a $fin';
  }

  // ─── Setters ───────────────────────────────────────────────

  void cambiarColor(Color c) {
    _colorPrimario = c;
    notifyListeners();
    _guardar();
  }

  void cambiarModoManual(ThemeMode mode) {
    _modoManual = mode;
    notifyListeners();
    _guardar();
  }

  void toggleModoAutomatico(bool activado) {
    _modoAutomatico = activado;
    _ultimoModoEfectivo = themeMode;
    notifyListeners();
    _guardar();
  }

  void cambiarInicioOscuro(TimeOfDay hora) {
    _inicioOscuro = hora;
    _ultimoModoEfectivo = themeMode;
    notifyListeners();
    _guardar();
  }

  void cambiarFinOscuro(TimeOfDay hora) {
    _finOscuro = hora;
    _ultimoModoEfectivo = themeMode;
    notifyListeners();
    _guardar();
  }

  void toggleAnimaciones(bool activadas) {
    _animacionesActivadas = activadas;
    notifyListeners();
    _guardar();
  }

  void cambiarRadioBorde(double radio) {
    _radioBorde = radio;
    notifyListeners();
    _guardar();
  }

  void toggleModoExperto(bool activado) {
    _modoExperto = activado;
    notifyListeners();
    _guardar();
  }

  void cambiarFuente(String fuente) {
    _fontFamily = fuente;
    notifyListeners();
    _guardar();
  }

  void cambiarEscalaFuente(double escala) {
    _fontScale = escala;
    notifyListeners();
    _guardar();
  }

  void cambiarColorTexto(Color? color) {
    _textColor = color;
    notifyListeners();
    _guardar();
  }

  void cambiarOpacidadTexto(double opacidad) {
    _textOpacity = opacidad.clamp(0.0, 1.0);
    notifyListeners();
    _guardar();
  }

  // ─── Timer del modo automático ─────────────────────────────

  void _iniciarTimerModoAutomatico() {
    _timerModoAutomatico?.cancel();
    _timerModoAutomatico = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (!_modoAutomatico) return;
        final nuevo = themeMode;
        if (nuevo != _ultimoModoEfectivo) {
          _ultimoModoEfectivo = nuevo;
          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _timerModoAutomatico?.cancel();
    super.dispose();
  }

  // ─── Persistencia ──────────────────────────────────────────

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();

    final val = prefs.getInt('themeColor');
    if (val != null) _colorPrimario = Color(val & 0xFFFFFFFF);

    final modeIndex = prefs.getInt('themeMode');
    if (modeIndex != null &&
        modeIndex >= 0 &&
        modeIndex < ThemeMode.values.length) {
      _modoManual = ThemeMode.values[modeIndex];
    }

    final auto = prefs.getBool('modoAutomatico');
    if (auto != null) _modoAutomatico = auto;

    final minutosInicio = prefs.getInt('inicioOscuroMinutos');
    if (minutosInicio != null) {
      _inicioOscuro = TimeOfDay(
        hour: minutosInicio ~/ 60,
        minute: minutosInicio % 60,
      );
    }

    final minutosFin = prefs.getInt('finOscuroMinutos');
    if (minutosFin != null) {
      _finOscuro = TimeOfDay(
        hour: minutosFin ~/ 60,
        minute: minutosFin % 60,
      );
    }

    final anim = prefs.getBool('animacionesActivadas');
    if (anim != null) _animacionesActivadas = anim;

    final radio = prefs.getDouble('radioBorde');
    if (radio != null) _radioBorde = radio;

    final experto = prefs.getBool('modoExperto');
    if (experto != null) _modoExperto = experto;

    final fuente = prefs.getString('fontFamily');
    if (fuente != null) _fontFamily = fuente;

    final escala = prefs.getDouble('fontScale');
    if (escala != null) _fontScale = escala;

    final colorTexto = prefs.getInt('textColor');
    if (colorTexto != null) {
      _textColor = colorTexto == -1 ? null : Color(colorTexto & 0xFFFFFFFF);
    }

    final opacidad = prefs.getDouble('textOpacity');
    if (opacidad != null) _textOpacity = opacidad;

    _ultimoModoEfectivo = themeMode;
    notifyListeners();
  }

  Future<void> _guardar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', _colorPrimario.toARGB32());
    await prefs.setInt('themeMode', _modoManual.index);
    await prefs.setBool('modoAutomatico', _modoAutomatico);
    await prefs.setInt('inicioOscuroMinutos', _aMinutos(_inicioOscuro));
    await prefs.setInt('finOscuroMinutos', _aMinutos(_finOscuro));
    await prefs.setBool('animacionesActivadas', _animacionesActivadas);
    await prefs.setDouble('radioBorde', _radioBorde);
    await prefs.setBool('modoExperto', _modoExperto);
    await prefs.setString('fontFamily', _fontFamily);
    await prefs.setDouble('fontScale', _fontScale);
    await prefs.setInt('textColor', _textColor?.toARGB32() ?? -1);
    await prefs.setDouble('textOpacity', _textOpacity);
  }

  Future<void> reset() async {
    _colorPrimario = Colors.indigo;
    _modoManual = ThemeMode.system;
    _modoAutomatico = false;
    _inicioOscuro = const TimeOfDay(hour: 20, minute: 0);
    _finOscuro = const TimeOfDay(hour: 7, minute: 0);
    _animacionesActivadas = true;
    _radioBorde = 8.0;
    _modoExperto = false;
    _fontFamily = 'Roboto';
    _fontScale = 1.0;
    _textColor = null;
    _textOpacity = 1.0;
    _ultimoModoEfectivo = themeMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
