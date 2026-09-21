import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/notificacion_pref.dart';
import '../../providers/estado_pro_provider.dart';
import '../../providers/notificaciones_prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/custom_sound_service.dart';
import '../../widgets/pro_feature_dialog.dart';

class NotificacionesAvanzadasPage extends StatelessWidget {
  const NotificacionesAvanzadasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final prefsProv = context.watch<NotificacionesPrefsProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración de notificaciones')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Personaliza cómo y cuándo quieres recibir notificaciones '
              'para cada categoría.',
              style: TextStyle(
                fontFamily: fontFamily,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ...NotificacionesPrefsProvider.categorias.map(
            (categoria) => _SeccionCategoria(
              categoria: categoria,
              pref: prefsProv.getPref(categoria),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SeccionCategoria extends StatelessWidget {
  final String categoria;
  final NotificacionPref pref;

  const _SeccionCategoria({
    required this.categoria,
    required this.pref,
  });

  String _tituloCategoria() {
    switch (categoria) {
      case 'eventos':
        return 'Eventos';
      case 'tareas':
        return 'Tareas';
      case 'rutinas':
        return 'Rutinas';
      case 'medicacion':
        return 'Medicación';
      case 'comunidad':
        return 'Comunidad';
      default:
        return categoria;
    }
  }

  IconData _iconoCategoria() {
    switch (categoria) {
      case 'eventos':
        return Icons.calendar_month;
      case 'tareas':
        return Icons.checklist;
      case 'rutinas':
        return Icons.fitness_center;
      case 'medicacion':
        return Icons.medication;
      case 'comunidad':
        return Icons.people;
      default:
        return Icons.notifications;
    }
  }

  Future<void> _elegirSonidoPersonalizado(
    BuildContext context,
    NotificacionesPrefsProvider prefsProv,
  ) async {
    // 🔒 Verificar acceso Pro
    final estado = context.read<EstadoProProvider>();
    if (!estado.tieneAccesoPro) {
      final activado = await mostrarDialogoFuncionPro(
        context,
        nombreFuncion: 'Sonidos personalizados',
        descripcion:
            'Sube tu propio archivo MP3, WAV u OGG y úsalo como sonido '
            'de notificación. Personaliza cada categoría con tu música.',
        icono: Icons.audiotrack,
      );
      if (!context.mounted) return;
      if (!activado || !context.read<EstadoProProvider>().tieneAccesoPro) {
        return;
      }
    }

    final messenger = ScaffoldMessenger.of(context);
    final resultado = await CustomSoundService().pickAndSaveSound();

    if (resultado.cancelado) return;

    if (resultado.error != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(resultado.error!)),
      );
      return;
    }

    if (resultado.path != null) {
      prefsProv.cambiarSonidoPersonalizado(categoria, resultado.path!);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Sonido guardado: ${CustomSoundService().nombreArchivo(resultado.path!)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefsProv = context.read<NotificacionesPrefsProvider>();
    final themeProv = context.watch<ThemeProvider>();
    final estado = context.watch<EstadoProProvider>();
    final fontFamily = themeProv.fontFamily;

    final esPro = estado.tieneAccesoPro;
    final tieneSonidoPersonalizado =
        pref.sonido == 'custom' && pref.customSoundPath != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: Icon(
          _iconoCategoria(),
          color: theme.colorScheme.primary,
        ),
        title: Text(
          _tituloCategoria(),
          style: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          pref.habilitada ? 'Activada' : 'Desactivada',
          style: TextStyle(
            fontFamily: fontFamily,
            color: pref.habilitada
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
        ),
        children: [
          SwitchListTile(
            title: Text(
              'Habilitar notificaciones',
              style: TextStyle(fontFamily: fontFamily),
            ),
            value: pref.habilitada,
            onChanged: (v) => prefsProv.toggleHabilitada(categoria, v),
          ),
          if (pref.habilitada) ...[
            SwitchListTile(
              secondary: Icon(
                Icons.alarm,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Modo alarma',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: const Text(
                'Sonido en loop + pantalla completa hasta detener',
              ),
              value: pref.modoAlarma,
              onChanged: (v) => prefsProv.toggleModoAlarma(categoria, v),
            ),
            if (pref.modoAlarma)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.orange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'En modo alarma, la notificación se repetirá '
                          'automáticamente cada 2 minutos hasta 5 veces '
                          'si no la atiendes.',
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ListTile(
              title: Text(
                'Sonido',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: DropdownButton<String>(
                value: pref.sonido,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'alarm', child: Text('Alarma')),
                  DropdownMenuItem(value: 'chime', child: Text('Campana')),
                  DropdownMenuItem(value: 'ding', child: Text('Ding')),
                  DropdownMenuItem(value: 'pop', child: Text('Pop')),
                  DropdownMenuItem(value: 'beep', child: Text('Beep')),
                  DropdownMenuItem(
                    value: 'custom',
                    child: Row(
                      children: [
                        Text('Personalizado'),
                        SizedBox(width: 6),
                        Icon(
                          Icons.workspace_premium,
                          size: 14,
                          color: Colors.amber,
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(value: 'default', child: Text('Sistema')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  if (v == 'custom') {
                    _elegirSonidoPersonalizado(context, prefsProv);
                  } else {
                    prefsProv.cambiarSonido(categoria, v);
                  }
                },
              ),
            ),
            if (tieneSonidoPersonalizado)
              ListTile(
                leading: const Icon(Icons.audiotrack),
                title: Text(
                  'Archivo actual',
                  style: TextStyle(fontFamily: fontFamily),
                ),
                subtitle: Text(
                  CustomSoundService()
                      .nombreArchivo(pref.customSoundPath ?? ''),
                  style: TextStyle(fontFamily: fontFamily),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Cambiar sonido',
                  onPressed: () =>
                      _elegirSonidoPersonalizado(context, prefsProv),
                ),
              ),
            SwitchListTile(
              title: Text(
                'Vibración',
                style: TextStyle(fontFamily: fontFamily),
              ),
              value: pref.vibracion,
              onChanged: (v) => prefsProv.toggleVibracion(categoria, v),
            ),
            SwitchListTile(
              title: Text(
                'Pantalla completa',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: const Text('Solo para eventos importantes'),
              value: pref.pantallaCompleta,
              onChanged: (v) => prefsProv.togglePantallaCompleta(categoria, v),
            ),
            SwitchListTile(
              title: Text(
                'Despertar pantalla',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: const Text(
                'La pantalla se encenderá aunque el teléfono esté bloqueado',
              ),
              value: pref.despertarPantalla,
              onChanged: (v) => prefsProv.toggleDespertarPantalla(categoria, v),
            ),
            ListTile(
              title: Text(
                'Anticipación',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: DropdownButton<int>(
                value: pref.anticipacionMinutos,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('A la hora exacta')),
                  DropdownMenuItem(value: 5, child: Text('5 min antes')),
                  DropdownMenuItem(value: 15, child: Text('15 min antes')),
                  DropdownMenuItem(value: 30, child: Text('30 min antes')),
                  DropdownMenuItem(value: 60, child: Text('1 hora antes')),
                ],
                onChanged: (v) {
                  if (v != null) prefsProv.cambiarAnticipacion(categoria, v);
                },
              ),
            ),
            ListTile(
              title: Text(
                'Reintentar si no se atiende',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: DropdownButton<int>(
                value: pref.reintentoMinutos,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 0, child: Text('No reintentar')),
                  DropdownMenuItem(value: 5, child: Text('Cada 5 min')),
                  DropdownMenuItem(value: 10, child: Text('Cada 10 min')),
                  DropdownMenuItem(value: 15, child: Text('Cada 15 min')),
                  DropdownMenuItem(value: 30, child: Text('Cada 30 min')),
                ],
                onChanged: (v) {
                  if (v != null) prefsProv.cambiarReintento(categoria, v);
                },
              ),
            ),
            ListTile(
              title: Text(
                'Número máximo de reintentos',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: DropdownButton<int>(
                value: pref.maxReintentos,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 0,
                    child: Text('0 (sin reintentos)'),
                  ),
                  DropdownMenuItem(value: 1, child: Text('1 reintento')),
                  DropdownMenuItem(value: 2, child: Text('2 reintentos')),
                  DropdownMenuItem(value: 3, child: Text('3 reintentos')),
                  DropdownMenuItem(value: 5, child: Text('5 reintentos')),
                ],
                onChanged: (v) {
                  if (v != null) prefsProv.cambiarMaxReintentos(categoria, v);
                },
              ),
            ),
            ListTile(
              title: Text(
                'Snooze (posponer)',
                style: TextStyle(fontFamily: fontFamily),
              ),
              subtitle: DropdownButton<int>(
                value: pref.snoozeMinutos,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 5, child: Text('5 minutos')),
                  DropdownMenuItem(value: 10, child: Text('10 minutos')),
                  DropdownMenuItem(value: 15, child: Text('15 minutos')),
                  DropdownMenuItem(value: 30, child: Text('30 minutos')),
                ],
                onChanged: (v) {
                  if (v != null) prefsProv.cambiarSnooze(categoria, v);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
