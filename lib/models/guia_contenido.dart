import 'package:flutter/material.dart';

class GuiaContenido {
  final String id;
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final List<GuiaPaso> pasos;

  const GuiaContenido({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.pasos,
  });
}

class GuiaPaso {
  final IconData icono;
  final String titulo;
  final String descripcion;

  const GuiaPaso({
    required this.icono,
    required this.titulo,
    required this.descripcion,
  });
}

/// Contenido predefinido de todas las guías de la app.
class GuiasContenido {
  static const Map<String, GuiaContenido> _guias = {
    'panel_control': GuiaContenido(
      id: 'panel_control',
      titulo: 'Panel de Control',
      subtitulo: 'Tu centro de mando',
      icono: Icons.dashboard,
      color: Colors.indigo,
      pasos: [
        GuiaPaso(
          icono: Icons.lightbulb_outline,
          titulo: 'Recomendaciones inteligentes',
          descripcion: 'Basadas en tu perfil y tu actividad diaria. '
              'Se actualizan automáticamente.',
        ),
        GuiaPaso(
          icono: Icons.expand_more,
          titulo: 'Secciones expandibles',
          descripcion: 'Toca cada sección (Eventos, Tareas, Rutinas, Salud) '
              'para colapsarla o expandirla.',
        ),
        GuiaPaso(
          icono: Icons.insights,
          titulo: 'Acceso a estadísticas',
          descripcion: 'Toca el icono de gráfico en la esquina superior '
              'para ver tus estadísticas detalladas.',
        ),
      ],
    ),
    'comunidad': GuiaContenido(
      id: 'comunidad',
      titulo: 'Comunidad',
      subtitulo: 'Comparte y descubre',
      icono: Icons.people,
      color: Colors.teal,
      pasos: [
        GuiaPaso(
          icono: Icons.verified,
          titulo: 'Contenido del sistema',
          descripcion: 'En la pestaña "Del sistema" encuentras rutinas, '
              'consejos y recetas curadas por nosotros.',
        ),
        GuiaPaso(
          icono: Icons.favorite,
          titulo: 'Vota tus favoritos',
          descripcion: 'Toca el corazón en cada aporte para marcarlo '
              'como favorito y verlo destacado.',
        ),
        GuiaPaso(
          icono: Icons.download,
          titulo: 'Importa como rutina',
          descripcion: 'Los aportes con el icono de descarga se pueden '
              'importar directamente a tus rutinas.',
        ),
      ],
    ),
    'estadisticas': GuiaContenido(
      id: 'estadisticas',
      titulo: 'Estadísticas',
      subtitulo: 'Mide tu progreso',
      icono: Icons.insights,
      color: Colors.purple,
      pasos: [
        GuiaPaso(
          icono: Icons.tune,
          titulo: 'Elige el rango',
          descripcion: 'Alterna entre 7, 14 o 30 días según lo que '
              'quieras analizar.',
        ),
        GuiaPaso(
          icono: Icons.bar_chart,
          titulo: 'Gráficos de barras',
          descripcion: 'Muestran tus registros día a día para detectar '
              'patrones y tendencias.',
        ),
        GuiaPaso(
          icono: Icons.check_circle_outline,
          titulo: 'Adherencia y progreso',
          descripcion: 'En medicación y ejercicio verás el porcentaje '
              'de cumplimiento para motivarte.',
        ),
      ],
    ),
    'notas': GuiaContenido(
      id: 'notas',
      titulo: 'Aclaración mental',
      subtitulo: 'Vacía tu mente',
      icono: Icons.psychology_outlined,
      color: Colors.amber,
      pasos: [
        GuiaPaso(
          icono: Icons.edit,
          titulo: 'Anota sin complicaciones',
          descripcion: 'Notas rápidas de texto para ideas, pendientes '
              'o pensamientos sueltos.',
        ),
        GuiaPaso(
          icono: Icons.palette_outlined,
          titulo: 'Personaliza el color',
          descripcion: 'Elige entre 8 colores pastel para organizar tus '
              'notas visualmente.',
        ),
        GuiaPaso(
          icono: Icons.push_pin,
          titulo: 'Fija las importantes',
          descripcion: 'Usa el pin para mantener las notas clave al '
              'inicio de la lista.',
        ),
      ],
    ),
    'mi_rutina': GuiaContenido(
      id: 'mi_rutina',
      titulo: 'Mi Rutina',
      subtitulo: 'Organiza tus actividades',
      icono: Icons.fitness_center,
      color: Colors.green,
      pasos: [
        GuiaPaso(
          icono: Icons.group_work,
          titulo: 'Agrupa por categorías',
          descripcion: 'Crea grupos como Salud, Trabajo o Estudios para '
              'organizar tus rutinas.',
        ),
        GuiaPaso(
          icono: Icons.access_time,
          titulo: 'Horarios ordenados',
          descripcion: 'Las rutinas se ordenan automáticamente por la hora '
              'en que debes realizarlas.',
        ),
        GuiaPaso(
          icono: Icons.notifications_active,
          titulo: 'Notificaciones diarias',
          descripcion: 'Cada rutina te avisa a su hora todos los días '
              'sin que tengas que hacer nada.',
        ),
      ],
    ),
    'salud': GuiaContenido(
      id: 'salud',
      titulo: 'Salud',
      subtitulo: 'Cuida tu cuerpo',
      icono: Icons.health_and_safety,
      color: Colors.red,
      pasos: [
        GuiaPaso(
          icono: Icons.restaurant,
          titulo: 'Alimentación',
          descripcion: 'Registra lo que comes y bebes. Anota líquidos, '
              'sólidos y platos completos.',
        ),
        GuiaPaso(
          icono: Icons.fitness_center,
          titulo: 'Ejercicio',
          descripcion: 'Define tus ejercicios con objetivos y marca '
              'los días que los completas.',
        ),
        GuiaPaso(
          icono: Icons.medication,
          titulo: 'Medicación',
          descripcion: 'Añade tus medicamentos con su dosis y frecuencia. '
              'Recibirás recordatorios automáticos.',
        ),
      ],
    ),
  };

  static GuiaContenido? obtener(String id) => _guias[id];
  static List<GuiaContenido> get todas => _guias.values.toList();
}
