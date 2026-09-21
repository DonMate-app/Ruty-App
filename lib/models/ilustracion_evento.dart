import 'package:flutter/material.dart';

class IlustracionEvento {
  final String id;
  final String emoji;
  final String nombre;

  const IlustracionEvento({
    required this.id,
    required this.emoji,
    required this.nombre,
  });
}

class IlustracionCategoria {
  final String titulo;
  final IconData icono;
  final Color color;
  final List<IlustracionEvento> ilustraciones;

  const IlustracionCategoria({
    required this.titulo,
    required this.icono,
    required this.color,
    required this.ilustraciones,
  });
}

class IlustracionesData {
  static const List<IlustracionCategoria> categorias = [
    IlustracionCategoria(
      titulo: 'Celebración',
      icono: Icons.celebration,
      color: Colors.pink,
      ilustraciones: [
        IlustracionEvento(id: 'fiesta', emoji: '🎉', nombre: 'Fiesta'),
        IlustracionEvento(id: 'cumple', emoji: '🎂', nombre: 'Cumpleaños'),
        IlustracionEvento(id: 'regalo', emoji: '🎁', nombre: 'Regalo'),
        IlustracionEvento(id: 'brindis', emoji: '🥂', nombre: 'Brindis'),
        IlustracionEvento(id: 'boda', emoji: '💍', nombre: 'Boda'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Salud',
      icono: Icons.local_hospital,
      color: Colors.red,
      ilustraciones: [
        IlustracionEvento(id: 'medico', emoji: '🩺', nombre: 'Médico'),
        IlustracionEvento(id: 'pastilla', emoji: '💊', nombre: 'Medicina'),
        IlustracionEvento(id: 'hospital', emoji: '🏥', nombre: 'Hospital'),
        IlustracionEvento(id: 'inyeccion', emoji: '💉', nombre: 'Vacuna'),
        IlustracionEvento(id: 'diente', emoji: '🦷', nombre: 'Dentista'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Deporte',
      icono: Icons.sports_soccer,
      color: Colors.green,
      ilustraciones: [
        IlustracionEvento(id: 'correr', emoji: '🏃', nombre: 'Correr'),
        IlustracionEvento(id: 'bici', emoji: '🚴', nombre: 'Bicicleta'),
        IlustracionEvento(id: 'futbol', emoji: '⚽', nombre: 'Fútbol'),
        IlustracionEvento(id: 'pesas', emoji: '🏋️', nombre: 'Gimnasio'),
        IlustracionEvento(id: 'yoga', emoji: '🧘', nombre: 'Yoga'),
        IlustracionEvento(id: 'natacion', emoji: '🏊', nombre: 'Natación'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Trabajo',
      icono: Icons.work,
      color: Colors.indigo,
      ilustraciones: [
        IlustracionEvento(id: 'trabajo', emoji: '💼', nombre: 'Trabajo'),
        IlustracionEvento(id: 'reunion', emoji: '👥', nombre: 'Reunión'),
        IlustracionEvento(id: 'portatil', emoji: '💻', nombre: 'Portátil'),
        IlustracionEvento(id: 'llamada', emoji: '📞', nombre: 'Llamada'),
        IlustracionEvento(id: 'informe', emoji: '📊', nombre: 'Informe'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Estudio',
      icono: Icons.school,
      color: Colors.deepPurple,
      ilustraciones: [
        IlustracionEvento(id: 'libro', emoji: '📚', nombre: 'Estudiar'),
        IlustracionEvento(id: 'examen', emoji: '📝', nombre: 'Examen'),
        IlustracionEvento(id: 'graduacion', emoji: '🎓', nombre: 'Graduación'),
        IlustracionEvento(id: 'clase', emoji: '🏫', nombre: 'Clase'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Comida',
      icono: Icons.restaurant,
      color: Colors.orange,
      ilustraciones: [
        IlustracionEvento(id: 'desayuno', emoji: '🥐', nombre: 'Desayuno'),
        IlustracionEvento(id: 'almuerzo', emoji: '🍽️', nombre: 'Almuerzo'),
        IlustracionEvento(id: 'cena', emoji: '🍲', nombre: 'Cena'),
        IlustracionEvento(id: 'cafe', emoji: '☕', nombre: 'Café'),
        IlustracionEvento(id: 'pizza', emoji: '🍕', nombre: 'Pizza'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Viaje',
      icono: Icons.flight,
      color: Colors.lightBlue,
      ilustraciones: [
        IlustracionEvento(id: 'avion', emoji: '✈️', nombre: 'Vuelo'),
        IlustracionEvento(id: 'coche', emoji: '🚗', nombre: 'Viaje'),
        IlustracionEvento(id: 'hotel', emoji: '🏨', nombre: 'Hotel'),
        IlustracionEvento(id: 'mapa', emoji: '🗺️', nombre: 'Ruta'),
        IlustracionEvento(id: 'playa', emoji: '🏖️', nombre: 'Playa'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Ocio',
      icono: Icons.movie,
      color: Colors.teal,
      ilustraciones: [
        IlustracionEvento(id: 'cine', emoji: '🎬', nombre: 'Cine'),
        IlustracionEvento(id: 'musica', emoji: '🎵', nombre: 'Música'),
        IlustracionEvento(id: 'juego', emoji: '🎮', nombre: 'Juego'),
        IlustracionEvento(id: 'arte', emoji: '🎨', nombre: 'Arte'),
        IlustracionEvento(id: 'leer', emoji: '📖', nombre: 'Lectura'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Hogar',
      icono: Icons.home,
      color: Colors.brown,
      ilustraciones: [
        IlustracionEvento(id: 'casa', emoji: '🏠', nombre: 'Casa'),
        IlustracionEvento(id: 'limpieza', emoji: '🧹', nombre: 'Limpieza'),
        IlustracionEvento(id: 'compra', emoji: '🛒', nombre: 'Compras'),
        IlustracionEvento(id: 'mascota', emoji: '🐶', nombre: 'Mascota'),
        IlustracionEvento(id: 'planta', emoji: '🪴', nombre: 'Plantas'),
      ],
    ),
    IlustracionCategoria(
      titulo: 'Naturaleza',
      icono: Icons.forest,
      color: Colors.green,
      ilustraciones: [
        IlustracionEvento(id: 'sol', emoji: '☀️', nombre: 'Día'),
        IlustracionEvento(id: 'luna', emoji: '🌙', nombre: 'Noche'),
        IlustracionEvento(id: 'flor', emoji: '🌸', nombre: 'Flor'),
        IlustracionEvento(id: 'arbol', emoji: '🌳', nombre: 'Árbol'),
        IlustracionEvento(id: 'montana', emoji: '⛰️', nombre: 'Montaña'),
      ],
    ),
  ];

  /// Todas las ilustraciones en una lista plana (útil para búsqueda por id).
  static List<IlustracionEvento> get todas {
    final resultado = <IlustracionEvento>[];
    for (final cat in categorias) {
      resultado.addAll(cat.ilustraciones);
    }
    return resultado;
  }

  /// Devuelve el emoji correspondiente a un id, o null si no existe.
  static String? emojiPorId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final cat in categorias) {
      for (final il in cat.ilustraciones) {
        if (il.id == id) return il.emoji;
      }
    }
    return null;
  }
}
