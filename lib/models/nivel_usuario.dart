class NivelUsuario {
  final int nivel;
  final String nombre;
  final int xpAcumulado;
  final int xpNivelActual;
  final int xpSiguienteNivel;

  const NivelUsuario({
    required this.nivel,
    required this.nombre,
    required this.xpAcumulado,
    required this.xpNivelActual,
    required this.xpSiguienteNivel,
  });

  /// Progreso al siguiente nivel (0.0 a 1.0).
  double get progreso {
    final rango = xpSiguienteNivel - xpNivelActual;
    if (rango <= 0) return 1.0;
    final actual = xpAcumulado - xpNivelActual;
    return (actual / rango).clamp(0.0, 1.0);
  }

  /// XP que falta para el siguiente nivel.
  int get xpFaltante {
    final falta = xpSiguienteNivel - xpAcumulado;
    return falta > 0 ? falta : 0;
  }

  /// ¿Es el nivel máximo?
  bool get esNivelMaximo => nivel >= _niveles.length;

  /// Definiciones de los niveles de Ruty.
  static const List<Map<String, dynamic>> _niveles = [
    {'nivel': 1, 'nombre': 'Iniciado', 'xp': 0},
    {'nivel': 2, 'nombre': 'Aprendiz', 'xp': 50},
    {'nivel': 3, 'nombre': 'Practicante', 'xp': 150},
    {'nivel': 4, 'nombre': 'Constante', 'xp': 350},
    {'nivel': 5, 'nombre': 'Disciplinado', 'xp': 700},
    {'nivel': 6, 'nombre': 'Maestro', 'xp': 1200},
    {'nivel': 7, 'nombre': 'Sabio', 'xp': 2000},
    {'nivel': 8, 'nombre': 'Templo', 'xp': 3000},
  ];

  /// Calcula el nivel del usuario según su XP acumulado.
  static NivelUsuario calcular(int xpAcumulado) {
    int nivelActual = 1;
    String nombreActual = 'Iniciado';
    int xpBase = 0;
    int xpSig = 50;

    for (int i = 0; i < _niveles.length; i++) {
      final item = _niveles[i];
      final xpRequerido = item['xp'] as int;

      if (xpAcumulado >= xpRequerido) {
        nivelActual = item['nivel'] as int;
        nombreActual = item['nombre'] as String;
        xpBase = xpRequerido;
        xpSig = i < _niveles.length - 1
            ? _niveles[i + 1]['xp'] as int
            : xpRequerido;
      } else {
        break;
      }
    }

    // Si alcanzó el máximo
    if (nivelActual >= _niveles.length) {
      xpSig = xpBase;
    }

    return NivelUsuario(
      nivel: nivelActual,
      nombre: nombreActual,
      xpAcumulado: xpAcumulado,
      xpNivelActual: xpBase,
      xpSiguienteNivel: xpSig,
    );
  }
}
