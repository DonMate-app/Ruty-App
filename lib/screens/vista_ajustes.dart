import 'package:flutter/material.dart';

import 'ajustes/perfil_page.dart';
import 'ajustes/personalizacion_page.dart';
import 'ajustes/notificaciones_page.dart';
import 'ajustes/datos_page.dart';

class VistaAjustesPage extends StatelessWidget {
  const VistaAjustesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ── Perfil ──
          _tarjetaMenu(
            context: context,
            icono: Icons.person,
            titulo: 'Perfil de usuario',
            subtitulo: 'Datos personales, estilo de vida, salud',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PerfilPage(),
              ),
            ),
          ),

          // ── Personalización ──
          _tarjetaMenu(
            context: context,
            icono: Icons.palette,
            titulo: 'Personalización',
            subtitulo: 'Colores, tipografía, tema, animaciones',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PersonalizacionPage(),
              ),
            ),
          ),

          // ── Notificaciones ──
          _tarjetaMenu(
            context: context,
            icono: Icons.notifications,
            titulo: 'Notificaciones',
            subtitulo: 'Permisos y recordatorios',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NotificacionesPage(),
              ),
            ),
          ),

          // ── Datos ──
          _tarjetaMenu(
            context: context,
            icono: Icons.storage,
            titulo: 'Datos',
            subtitulo: 'Color por defecto, onboarding, restablecer',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const DatosPage(),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              'Ruty',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _tarjetaMenu({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Card(
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: theme.colorScheme.primary, size: 26),
          ),
          title: Text(
            titulo,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(subtitulo),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
