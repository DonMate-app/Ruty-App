import 'package:flutter/material.dart';

class AyudaCategoria {
  final String id;
  final String titulo;
  final IconData icono;
  final Color color;
  final List<AyudaPregunta> preguntas;

  const AyudaCategoria({
    required this.id,
    required this.titulo,
    required this.icono,
    required this.color,
    required this.preguntas,
  });
}

class AyudaPregunta {
  final String id;
  final String pregunta;
  final String respuesta;

  const AyudaPregunta({
    required this.id,
    required this.pregunta,
    required this.respuesta,
  });
}

class AyudaContenido {
  static const List<AyudaCategoria> categorias = [
    AyudaCategoria(
      id: 'inicio',
      titulo: 'Primeros pasos',
      icono: Icons.rocket_launch,
      color: Colors.indigo,
      preguntas: [
        AyudaPregunta(
          id: 'primer_evento',
          pregunta: '¿Cómo creo mi primer evento?',
          respuesta: 'Ve a la pestaña "Mes" y toca el botón "+" en la parte '
              'inferior derecha. Se abrirá un formulario donde puedes '
              'poner título, hora, duración, tipo y color del evento.',
        ),
        AyudaPregunta(
          id: 'primer_rutina',
          pregunta: '¿Qué son las rutinas y cómo las creo?',
          respuesta: 'Las rutinas son actividades que repites a diario. '
              'Ve a la pestaña "Mi Rutina", selecciona un grupo y toca '
              '"Agregar rutina". Cada rutina tiene una hora fija y te '
              'enviará una notificación diaria automáticamente.',
        ),
        AyudaPregunta(
          id: 'perfil_uso',
          pregunta: '¿Para qué sirve el perfil de usuario?',
          respuesta: 'El perfil (Ajustes → Perfil de usuario) guarda tus datos '
              'de estilo de vida, alergias y condiciones. Con esa '
              'información, la app genera recomendaciones personalizadas '
              'y mejores avisos según tu situación.',
        ),
        AyudaPregunta(
          id: 'trial',
          pregunta: '¿Qué es el período de prueba?',
          respuesta: 'Si estás usando una versión de prueba, verás un aviso '
              'cuando se acerque el final del período. Después de ese '
              'tiempo la app deja de funcionar hasta que el desarrollador '
              'te proporcione una licencia completa.',
        ),
      ],
    ),
    AyudaCategoria(
      id: 'notificaciones',
      titulo: 'Notificaciones',
      icono: Icons.notifications,
      color: Colors.orange,
      preguntas: [
        AyudaPregunta(
          id: 'no_llegan',
          pregunta: 'No me llegan las notificaciones, ¿qué hago?',
          respuesta: 'Verifica:\n'
              '1. Ajustes → Notificaciones → "Solicitar permiso" esté '
              'concedido.\n'
              '2. Que la categoría esté activada en "Activar/desactivar '
              'categorías".\n'
              '3. Que el teléfono no esté en modo "No molestar".\n'
              '4. Desactiva la optimización de batería para esta app '
              '(especialmente en TECNO, Xiaomi, Huawei).\n'
              '5. Si usas pantalla apagada, activa "Despertar pantalla" '
              'en la configuración avanzada.',
        ),
        AyudaPregunta(
          id: 'sonidos_personalizados',
          pregunta: '¿Puedo usar mis propios sonidos?',
          respuesta: 'Sí. Ve a Ajustes → Notificaciones → Personalizar por '
              'categoría → elige la categoría → toca "Sonido" y selecciona '
              '"Personalizado". Se abrirá el selector de archivos donde '
              'puedes elegir un MP3, WAV u OGG de tu dispositivo.',
        ),
        AyudaPregunta(
          id: 'botones_accion',
          pregunta: '¿Cómo funcionan los botones de las notificaciones?',
          respuesta: 'En las notificaciones de medicación aparecen 3 botones:\n'
              '• Tomado: registra la dosis como tomada.\n'
              '• Posponer: reprograma el aviso en X minutos.\n'
              '• Ignorar: descarta el aviso.\n\n'
              'Estos botones funcionan incluso si la app está cerrada.',
        ),
        AyudaPregunta(
          id: 'reintentos',
          pregunta: '¿Qué son los reintentos?',
          respuesta: 'Si no atiendes una notificación, la app puede volver a '
              'avisarte después de X minutos. Configúralo en Ajustes → '
              'Notificaciones → Personalizar → "Reintentar si no se '
              'atiende" y "Número máximo de reintentos".',
        ),
      ],
    ),
    AyudaCategoria(
      id: 'personalizacion',
      titulo: 'Personalización',
      icono: Icons.palette,
      color: Colors.purple,
      preguntas: [
        AyudaPregunta(
          id: 'cambiar_color',
          pregunta: '¿Cómo cambio el color de la app?',
          respuesta: 'Ve a Ajustes → Personalización → "Color del tema". '
              'Elige entre más de 20 colores. El cambio se aplica '
              'inmediatamente a toda la app.',
        ),
        AyudaPregunta(
          id: 'modo_oscuro_auto',
          pregunta: '¿Cómo activo el modo oscuro automático?',
          respuesta: 'Ve a Ajustes → Personalización → activa "Modo oscuro por '
              'horario". Configura la hora de inicio y fin. Por ejemplo, '
              'de 20:00 a 07:00. La app cambiará sola según la hora.',
        ),
        AyudaPregunta(
          id: 'tipografia',
          pregunta: '¿Puedo cambiar la tipografía?',
          respuesta: 'Sí. En Ajustes → Personalización puedes elegir la fuente '
              '(Roboto, serif, monospace), ajustar el tamaño y cambiar el '
              'color y opacidad del texto.',
        ),
        AyudaPregunta(
          id: 'animaciones',
          pregunta: '¿Cómo desactivo las animaciones?',
          respuesta: 'Ajustes → Personalización → desactiva el interruptor '
              '"Animaciones". Esto hace que la app sea más rápida en '
              'dispositivos con poca RAM.',
        ),
      ],
    ),
    AyudaCategoria(
      id: 'salud',
      titulo: 'Salud y hábitos',
      icono: Icons.health_and_safety,
      color: Colors.red,
      preguntas: [
        AyudaPregunta(
          id: 'registrar_medicamento',
          pregunta: '¿Cómo registro un medicamento?',
          respuesta:
              'Ve a la pestaña "Salud" → pestaña "Medicación" → botón "+". '
              'Añade nombre, dosis, frecuencia, hora y color. La app '
              'programará recordatorios automáticos.',
        ),
        AyudaPregunta(
          id: 'registrar_ejercicio',
          pregunta: '¿Cómo añado ejercicios a mi rutina?',
          respuesta: 'En la pestaña "Salud" → "Ejercicio" → botón "+". Define '
              'el nombre, tipo (cardio, fuerza, etc.), objetivo de minutos '
              'o repeticiones. Cada día podrás marcarlo como completado.',
        ),
        AyudaPregunta(
          id: 'resumen_semanal',
          pregunta: '¿Qué es el resumen semanal?',
          respuesta:
              'Cada lunes, al abrir el Panel de Control, verás un resumen '
              'de la semana anterior: eventos cumplidos, tareas, ejercicio, '
              'alimentación y adherencia a medicación. Te ayuda a ver tu '
              'progreso.',
        ),
        AyudaPregunta(
          id: 'recomendaciones',
          pregunta: '¿De dónde vienen las recomendaciones?',
          respuesta:
              'Se generan automáticamente combinando tu perfil (alergias, '
              'condiciones) con tu actividad diaria (hidratación, ejercicio, '
              'medicación, tareas). Cambian según lo que vayas registrando.',
        ),
      ],
    ),
    AyudaCategoria(
      id: 'avanzado',
      titulo: 'Funciones avanzadas',
      icono: Icons.build,
      color: Colors.teal,
      preguntas: [
        AyudaPregunta(
          id: 'comunidad',
          pregunta: '¿Cómo funciona la comunidad?',
          respuesta: 'En el menú lateral → "Comunidad". Tienes 3 pestañas: '
              'contenido curado por el sistema, aportes de usuarios y '
              'tus propios aportes. Puedes votar con el corazón e '
              'importar rutinas de otros a tu horario.',
        ),
        AyudaPregunta(
          id: 'importar_rutina',
          pregunta: '¿Cómo importo una rutina de la comunidad?',
          respuesta:
              'Abre un aporte de la comunidad. Si tiene pasos definidos, '
              'verás el botón "Importar como rutina". Elige el grupo '
              'destino y se creará una rutina con ese título.',
        ),
        AyudaPregunta(
          id: 'exportar',
          pregunta: '¿Puedo respaldar mis datos?',
          respuesta: 'Sí. Ajustes → Datos → "Exportar datos". Se genera un '
              'archivo JSON que puedes guardar o compartir. Para '
              'restaurarlo, usa "Importar datos" y selecciona el archivo.',
        ),
        AyudaPregunta(
          id: 'notas_rapidas',
          pregunta: '¿Qué es "Aclaración mental"?',
          respuesta: 'Es un espacio para escribir notas rápidas: ideas, '
              'pendientes o pensamientos sueltos. Accede desde el menú '
              'lateral. Puedes poner color a las notas y fijar las '
              'importantes al inicio.',
        ),
      ],
    ),
  ];
}
