import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/notificaciones_prefs_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/alarma_service.dart';
import '../../services/notification_service.dart';
import '../../screens/alarma/alarma_page.dart';
import 'notificaciones_avanzadas_page.dart';

class NotificacionesPage extends StatefulWidget {
  const NotificacionesPage({super.key});

  @override
  State<NotificacionesPage> createState() => _NotificacionesPageState();
}

class _NotificacionesPageState extends State<NotificacionesPage> {
  final NotificationService _notificationService = NotificationService();

  bool _notifEventos = true;
  bool _notifTareas = true;
  bool _notifRutinas = true;
  bool _notifMedicacion = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifEventos = prefs.getBool('notif_eventos') ?? true;
      _notifTareas = prefs.getBool('notif_tareas') ?? true;
      _notifRutinas = prefs.getBool('notif_rutinas') ?? true;
      _notifMedicacion = prefs.getBool('notif_medicacion') ?? true;
    });
  }

  Future<void> _guardar(String clave, bool valor) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(clave, valor);
  }

  Future<void> _solicitarPermiso() async {
    final granted = await _notificationService.requestPermissions();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted ? 'Permiso concedido' : 'Permiso denegado o no disponible',
          ),
        ),
      );
    }
  }

  void _mostrarAyudaBateria() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Optimización de batería'),
        content: const Text(
          'Para que las notificaciones lleguen a tiempo, '
          'desactiva la optimización de batería para esta app:\n\n'
          '1. Ajustes del teléfono → Aplicaciones → Horario App → '
          'Batería → Sin restricciones.\n\n'
          '2. Si tu teléfono es TECNO/HiOS, ve a Battery Lab y '
          'desactiva "Gestión de ahorro de energía de apps".\n\n'
          '3. Desactiva "Bloquear notificaciones con pantalla apagada" '
          'si existe esa opción.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // ─── Pruebas de notificaciones ─────────────────────────────

  Future<void> _probarNotificacion(String categoria) async {
    final id = DateTime.now().millisecondsSinceEpoch & 0x7fffffff;

    String title = '';
    String body = '';

    switch (categoria) {
      case 'eventos':
        title = 'Prueba de evento';
        body = 'Esta es una notificación de la categoría Eventos.';
        break;
      case 'tareas':
        title = 'Prueba de tarea';
        body = 'Esta es una notificación de la categoría Tareas.';
        break;
      case 'rutinas':
        title = 'Prueba de rutina';
        body = 'Esta es una notificación de la categoría Rutinas.';
        break;
      case 'medicacion':
        title = 'Prueba de medicación';
        body = 'Esta es una notificación de la categoría Medicación.';
        break;
      case 'comunidad':
        title = 'Prueba de comunidad';
        body = 'Esta es una notificación de la categoría Comunidad.';
        break;
    }

    await _notificationService.scheduleNotification(
      id: id,
      categoria: categoria,
      title: title,
      body: body,
      scheduledDate: DateTime.now().add(const Duration(seconds: 5)),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notificación de prueba (${categoria}) en 5 segundos',
          ),
        ),
      );
    }
  }

  Future<void> _probarAlarma() async {
    final prefs = context.read<NotificacionesPrefsProvider>();
    final pref = prefs.getPref('medicacion');

    // 🔑 Forzar siempre "alarm" en la prueba
    String sonidoFinal = pref.sonido;
    if (sonidoFinal == 'default' || sonidoFinal.isEmpty) {
      sonidoFinal = 'alarm';
    }

    // Navegar INMEDIATAMENTE (sin esperar al audio)
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlarmaPage(
            categoria: 'medicacion',
            payload: 'test:alarma',
            sonidoInicial: sonidoFinal,
            tituloInicial: 'Alarma de prueba',
            cuerpoInicial:
                'Esta es una alarma de prueba. Toca "Detener" para pararla.',
            vibrarInicial: pref.vibracion,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  Widget _botonPrueba({
    required IconData icono,
    required String texto,
    required Color color,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onTap,
      icon: Icon(icono, size: 20),
      label: Text(texto, style: const TextStyle(fontSize: 13)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final fontFamily = themeProv.fontFamily;

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: ListView(
        children: [
          // ── Permisos ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Permisos',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Solicitar permiso de notificaciones'),
            subtitle: const Text('Necesario para recibir recordatorios'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _solicitarPermiso,
          ),
          ListTile(
            leading: const Icon(Icons.battery_saver),
            title: const Text('Optimización de batería'),
            subtitle: const Text(
              'Recomendado para que las notificaciones lleguen a tiempo',
            ),
            trailing: const Icon(Icons.help_outline),
            onTap: _mostrarAyudaBateria,
          ),

          // ── Configuración avanzada ──
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Configuración avanzada',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Personalizar por categoría'),
            subtitle: const Text('Sonido, vibración, anticipación y más'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificacionesAvanzadasPage(),
                ),
              );
            },
          ),

          // ── Categorías rápidas ──
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Activar/desactivar categorías',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Elige qué tipo de recordatorios quieres recibir.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: fontFamily,
              ),
            ),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            secondary: const Icon(Icons.calendar_month),
            title: const Text('Eventos del calendario'),
            subtitle: const Text('Recordatorios de eventos programados'),
            value: _notifEventos,
            onChanged: (v) {
              setState(() => _notifEventos = v);
              _guardar('notif_eventos', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.checklist),
            title: const Text('Tareas'),
            subtitle: const Text('Recordatorios de tareas pendientes'),
            value: _notifTareas,
            onChanged: (v) {
              setState(() => _notifTareas = v);
              _guardar('notif_tareas', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fitness_center),
            title: const Text('Rutinas'),
            subtitle: const Text('Recordatorios de rutinas diarias'),
            value: _notifRutinas,
            onChanged: (v) {
              setState(() => _notifRutinas = v);
              _guardar('notif_rutinas', v);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.medication),
            title: const Text('Medicación'),
            subtitle: const Text('Recordatorios de medicamentos'),
            value: _notifMedicacion,
            onChanged: (v) {
              setState(() => _notifMedicacion = v);
              _guardar('notif_medicacion', v);
            },
          ),

          // ── Limitador ──
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Limitador de notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: const Text('Sin límite de notificaciones'),
            subtitle: const Text(
              'Desactiva el límite de 6 por hora (las categorías '
              'prioritarias siempre pasan)',
            ),
            trailing: Switch(
              value: !_notificationService.limitadorActivo,
              onChanged: (v) {
                _notificationService.configurarLimitador(
                  activo: !v,
                  limite: 6,
                );
                setState(() {});
              },
            ),
          ),

          const SizedBox(height: 24),

          // ── Información ──
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Para mejor precisión, activa "Despertar pantalla" en '
                      'la configuración avanzada de medicación y rutinas.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Pruebas ──
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Probar notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontFamily: fontFamily,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Dispara una notificación de prueba de cada categoría '
              'con tu configuración actual. Se enviará en 5 segundos.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFamily: fontFamily,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _botonPrueba(
                  icono: Icons.calendar_month,
                  texto: 'Probar evento',
                  color: Colors.indigo,
                  onTap: () => _probarNotificacion('eventos'),
                ),
                const SizedBox(height: 8),
                _botonPrueba(
                  icono: Icons.checklist,
                  texto: 'Probar tarea',
                  color: Colors.orange,
                  onTap: () => _probarNotificacion('tareas'),
                ),
                const SizedBox(height: 8),
                _botonPrueba(
                  icono: Icons.fitness_center,
                  texto: 'Probar rutina',
                  color: Colors.green,
                  onTap: () => _probarNotificacion('rutinas'),
                ),
                const SizedBox(height: 8),
                _botonPrueba(
                  icono: Icons.medication,
                  texto: 'Probar medicación',
                  color: Colors.red,
                  onTap: () => _probarNotificacion('medicacion'),
                ),
                const SizedBox(height: 8),
                _botonPrueba(
                  icono: Icons.people,
                  texto: 'Probar comunidad',
                  color: Colors.teal,
                  onTap: () => _probarNotificacion('comunidad'),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.alarm,
                            color: theme.colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Prueba de alarma real',
                            style: TextStyle(
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Abre la pantalla de alarma inmediatamente. '
                        'El sonido suena en loop hasta que toques "Detener".',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: fontFamily,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: theme.colorScheme.error,
                            foregroundColor: theme.colorScheme.onError,
                          ),
                          onPressed: _probarAlarma,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            'Abrir alarma de prueba',
                            style: TextStyle(fontFamily: fontFamily),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
