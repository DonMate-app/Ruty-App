import '../models/comunidad_item.dart';

/// Catálogo inicial de items curados por el desarrollador.
/// Estos items son la base de la sección "Del sistema".
List<ComunidadItem> obtenerSeedComunidad() {
  final ahora = DateTime.now();
  int i = 0;
  ComunidadItem item({
    required String titulo,
    required String descripcion,
    required CategoriaComunidad categoria,
    List<String> tags = const [],
    int likes = 0,
    List<String> pasos = const [],
    int duracionMinutos = 0,
    String dificultad = 'media',
    bool esImportable = false,
  }) {
    i++;
    return ComunidadItem(
      id: 'seed_$i',
      titulo: titulo,
      descripcion: descripcion,
      autor: 'Sistema',
      esSistema: true,
      categoria: categoria,
      tags: tags,
      likes: likes,
      fechaCreacion: ahora,
      pasos: pasos,
      duracionMinutos: duracionMinutos,
      dificultad: dificultad,
      esImportable: esImportable,
    );
  }

  return [
    // ── Nutrición ──
    item(
      titulo: 'Desayuno energético en 5 minutos',
      descripcion:
          'Avena con frutas, yogur y un puñado de frutos secos. Te da energía para toda la mañana.',
      categoria: CategoriaComunidad.nutricion,
      tags: ['desayuno', 'rápido', 'energía'],
      likes: 42,
      pasos: [
        'Calienta 200ml de leche o bebida vegetal.',
        'Añade 4 cucharadas de avena.',
        'Agrega frutas troceadas (plátano o fresas).',
        'Cubre con yogur natural y frutos secos.',
      ],
      duracionMinutos: 5,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Snack saludable para media tarde',
      descripcion:
          'Combinación de proteína y fibra para evitar el hambre entre comidas.',
      categoria: CategoriaComunidad.nutricion,
      tags: ['snack', 'proteína'],
      likes: 28,
      pasos: [
        'Mezcla 1 manzana troceada con 1 cucharada de mantequilla de maní.',
        'Acompaña con 10 almendras.',
      ],
      duracionMinutos: 3,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Regla del plato equilibrado',
      descripcion:
          'Divide tu plato: 50% vegetales, 25% proteína, 25% carbohidratos complejos.',
      categoria: CategoriaComunidad.nutricion,
      tags: ['hábito', 'porciones'],
      likes: 67,
    ),
    item(
      titulo: 'Reduce el azúcar en 3 pasos',
      descripcion:
          'Plan para disminuir progresivamente el azúcar añadido sin extrañarlo.',
      categoria: CategoriaComunidad.nutricion,
      tags: ['azúcar', 'hábito'],
      likes: 51,
      pasos: [
        'Semana 1: cambia refrescos por agua con gas y limón.',
        'Semana 2: reduce el azúcar en el café a la mitad.',
        'Semana 3: elige postres naturales (fruta) en vez de procesados.',
      ],
      duracionMinutos: 0,
      dificultad: 'media',
    ),
    item(
      titulo: 'Prepara comidas el domingo',
      descripcion:
          'Dedica 1 hora a preparar comidas de la semana y ahorra tiempo y decisiones.',
      categoria: CategoriaComunidad.nutricion,
      tags: ['meal prep', 'organización'],
      likes: 89,
      pasos: [
        'Elige 3 recetas base.',
        'Cocina las proteínas y carbohidratos.',
        'Guarda porciones en recipientes herméticos.',
        'Etiqueta con fecha de preparación.',
      ],
      duracionMinutos: 60,
      dificultad: 'media',
    ),

    // ── Ejercicio ──
    item(
      titulo: 'Rutina matutina en 5 pasos',
      descripcion: 'Activa tu cuerpo al despertar sin necesidad de equipo.',
      categoria: CategoriaComunidad.ejercicio,
      tags: ['mañana', 'casa', 'sin equipo'],
      likes: 124,
      pasos: [
        'Estiramiento de brazos al cielo (30s)',
        'Sentadillas suaves (10 repeticiones)',
        'Rotaciones de cadera (10 por lado)',
        'Flexiones de rodillas (5-10)',
        'Caminata en el lugar (2 minutos)',
      ],
      duracionMinutos: 5,
      dificultad: 'facil',
      esImportable: true,
    ),
    item(
      titulo: 'Cardio en casa 15 minutos',
      descripcion:
          'Rutina de alta intensidad sin equipos. Ideal para días ocupados.',
      categoria: CategoriaComunidad.ejercicio,
      tags: ['cardio', 'HIIT', 'casa'],
      likes: 78,
      pasos: [
        'Jumping jacks (1 min)',
        'Sentadillas (1 min)',
        'Descanso (30s)',
        'Repetir 4 rondas',
      ],
      duracionMinutos: 15,
      dificultad: 'media',
      esImportable: true,
    ),
    item(
      titulo: 'Estiramiento nocturno',
      descripcion:
          'Relaja los músculos antes de dormir para mejorar el descanso.',
      categoria: CategoriaComunidad.ejercicio,
      tags: ['estiramiento', 'noche', 'relajación'],
      likes: 95,
      pasos: [
        'Postura del niño (1 min)',
        'Torsión espinal en el suelo (1 min por lado)',
        'Estiramiento de isquiotibiales (1 min por pierna)',
        'Respiración profunda sentado (2 min)',
      ],
      duracionMinutos: 7,
      dificultad: 'facil',
      esImportable: true,
    ),
    item(
      titulo: 'Fuerza básica sin pesas',
      descripcion:
          'Usa tu propio peso para tonificar todo el cuerpo en 20 minutos.',
      categoria: CategoriaComunidad.ejercicio,
      tags: ['fuerza', 'casa'],
      likes: 60,
      pasos: [
        'Flexiones (3x10)',
        'Sentadillas (3x15)',
        'Plancha (3x30s)',
        'Zancadas (3x10 por pierna)',
      ],
      duracionMinutos: 20,
      dificultad: 'media',
      esImportable: true,
    ),
    item(
      titulo: 'Caminata consciente',
      descripcion:
          'Sal a caminar 30 minutos sin distracciones, prestando atención a tu entorno y respiración.',
      categoria: CategoriaComunidad.ejercicio,
      tags: ['caminar', 'mindfulness'],
      likes: 45,
      duracionMinutos: 30,
      dificultad: 'facil',
      esImportable: true,
    ),

    // ── Bienestar ──
    item(
      titulo: 'Respiración 4-7-8',
      descripcion:
          'Técnica para calmar la ansiedad en 2 minutos. Inhala 4, sostén 7, exhala 8.',
      categoria: CategoriaComunidad.bienestar,
      tags: ['ansiedad', 'respiración'],
      likes: 156,
      pasos: [
        'Siéntate cómodamente.',
        'Inhala por la nariz contando 4.',
        'Sostén el aire contando 7.',
        'Exhala por la boca contando 8.',
        'Repite 4 ciclos.',
      ],
      duracionMinutos: 2,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Diario de gratitud',
      descripcion: 'Escribe 3 cosas por las que estás agradecido cada noche.',
      categoria: CategoriaComunidad.bienestar,
      tags: ['gratitud', 'diario'],
      likes: 88,
      duracionMinutos: 5,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Pausa consciente cada 90 minutos',
      descripcion:
          'Levántate, estira y respira durante 2 minutos cada hora y media de trabajo.',
      categoria: CategoriaComunidad.bienestar,
      tags: ['pausa', 'trabajo'],
      likes: 71,
      duracionMinutos: 2,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Meditación de 5 minutos',
      descripcion:
          'Cierra los ojos y enfócate solo en tu respiración durante 5 minutos.',
      categoria: CategoriaComunidad.bienestar,
      tags: ['meditación', 'mindfulness'],
      likes: 102,
      duracionMinutos: 5,
      dificultad: 'facil',
    ),

    // ── Hidratación ──
    item(
      titulo: 'Regla del vaso al despertar',
      descripcion:
          'Bebe un vaso grande de agua al despertar para reactivar el cuerpo.',
      categoria: CategoriaComunidad.hidratacion,
      tags: ['agua', 'mañana'],
      likes: 145,
      duracionMinutos: 1,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Agua saborizada natural',
      descripcion:
          'Añade rodajas de limón, pepino o menta al agua para beber más.',
      categoria: CategoriaComunidad.hidratacion,
      tags: ['agua', 'receta'],
      likes: 55,
      duracionMinutos: 2,
      dificultad: 'facil',
    ),
    item(
      titulo: '8 vasos distribuidos en el día',
      descripcion:
          'Reparte el consumo de agua: 2 vasos al despertar, 3 antes del mediodía, 3 por la tarde.',
      categoria: CategoriaComunidad.hidratacion,
      tags: ['hábito', 'agua'],
      likes: 92,
    ),
    item(
      titulo: 'Bebe antes de sentir sed',
      descripcion:
          'Programa recordatorios cada 2 horas para mantenerte hidratado.',
      categoria: CategoriaComunidad.hidratacion,
      tags: ['recordatorio', 'agua'],
      likes: 63,
    ),

    // ── Sueño ──
    item(
      titulo: 'Rutina de sueño en 30 minutos',
      descripcion:
          'Prepara tu cuerpo para dormir con actividades relajantes antes de acostarte.',
      categoria: CategoriaComunidad.sueno,
      tags: ['dormir', 'rutina'],
      likes: 110,
      pasos: [
        'Apaga pantallas 30 min antes.',
        'Toma una infusión relajante.',
        'Lee un libro físico.',
        'Prepara la habitación oscura y fresca.',
      ],
      duracionMinutos: 30,
      dificultad: 'facil',
      esImportable: true,
    ),
    item(
      titulo: 'Sin cafeína después de las 15h',
      descripcion:
          'La cafeína tarda 6 horas en eliminarse. Evítala por la tarde.',
      categoria: CategoriaComunidad.sueno,
      tags: ['cafeína', 'hábito'],
      likes: 74,
    ),
    item(
      titulo: 'Regla 20-20-20 para pantallas',
      descripcion:
          'Cada 20 minutos mira algo a 20 pies (6m) durante 20 segundos.',
      categoria: CategoriaComunidad.sueno,
      tags: ['pantalla', 'vista'],
      likes: 48,
    ),
    item(
      titulo: 'Horario fijo para dormir',
      descripcion:
          'Acuéstate y despiértate a la misma hora todos los días, incluso fines de semana.',
      categoria: CategoriaComunidad.sueno,
      tags: ['hábito', 'sueño'],
      likes: 82,
    ),

    // ── Organización ──
    item(
      titulo: 'Método 1-3-5 para el día',
      descripcion: 'Planifica 1 tarea grande, 3 medianas y 5 pequeñas por día.',
      categoria: CategoriaComunidad.organizacion,
      tags: ['productividad', 'planificación'],
      likes: 118,
    ),
    item(
      titulo: 'Revisión semanal los domingos',
      descripcion:
          'Dedica 20 minutos a planificar la semana y revisar lo hecho.',
      categoria: CategoriaComunidad.organizacion,
      tags: ['planificación', 'semanal'],
      likes: 66,
      duracionMinutos: 20,
      dificultad: 'facil',
    ),
    item(
      titulo: 'Regla de los 2 minutos',
      descripcion: 'Si algo toma menos de 2 minutos, hazlo inmediatamente.',
      categoria: CategoriaComunidad.organizacion,
      tags: ['productividad', 'hábito'],
      likes: 97,
    ),
    item(
      titulo: 'Bloques de tiempo profundo',
      descripcion:
          'Reserva 90 minutos sin interrupciones para tu tarea más importante.',
      categoria: CategoriaComunidad.organizacion,
      tags: ['enfoque', 'productividad'],
      likes: 84,
      duracionMinutos: 90,
      dificultad: 'media',
    ),

    // ── Salud ──
    item(
      titulo: 'Chequeo médico anual',
      descripcion:
          'Programa una revisión general una vez al año para prevención.',
      categoria: CategoriaComunidad.salud,
      tags: ['prevención', 'médico'],
      likes: 79,
    ),
    item(
      titulo: 'Revisa tu postura cada hora',
      descripcion:
          'Ajusta espalda recta, hombros relajados y pies en el suelo.',
      categoria: CategoriaComunidad.salud,
      tags: ['postura', 'ergonomía'],
      likes: 52,
    ),
    item(
      titulo: 'Cuidado de la vista',
      descripcion:
          'Parpadea con frecuencia y usa iluminación adecuada al leer o trabajar.',
      categoria: CategoriaComunidad.salud,
      tags: ['vista', 'cuidado'],
      likes: 41,
    ),
    item(
      titulo: 'Lavado de manos frecuente',
      descripcion:
          'Mínimo 20 segundos con agua y jabón, especialmente antes de comer.',
      categoria: CategoriaComunidad.salud,
      tags: ['higiene', 'prevención'],
      likes: 88,
    ),
  ];
}
