import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/eventos_provider.dart';
import '../../providers/rutinas_provider.dart';
import '../../providers/tareas_provider.dart';
import '../../providers/alimentacion_provider.dart';
import '../../providers/ejercicio_provider.dart';
import '../../providers/medicacion_provider.dart';
import '../../providers/perfil_provider.dart';
import '../../providers/comunidad_provider.dart';
import '../../providers/notificaciones_prefs_provider.dart';
import '../../providers/notas_provider.dart';
import '../../providers/guias_provider.dart';
import '../../providers/resumen_semanal_provider.dart';
import '../../providers/comentarios_provider.dart';
import '../../providers/feriados_provider.dart';
import '../../providers/licencia_provider.dart';
import '../../providers/metas_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/backup_service.dart';
import '../../services/update_service.dart';

class DatosPage extends StatelessWidget {
  const DatosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Datos')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ── Eventos ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Eventos',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Color por defecto para eventos'),
            subtitle: _ColorSelector(
              onChanged: (c) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('defaultEventColor', c.toARGB32());
              },
            ),
          ),

          const Divider(height: 32),

          // ── Respaldo ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Respaldo',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Exporta todos tus datos a un archivo JSON para '
              'respaldarlos o compartirlos.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Exportar datos'),
            subtitle: const Text(
              'Crea un archivo JSON con toda tu información',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _exportarDatos(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Importar datos'),
            subtitle: const Text(
              'Restaura tu información desde un archivo JSON',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _importarDatos(context),
          ),

          const Divider(height: 32),

          // ── Aplicación ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Aplicación',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Volver a ver onboarding'),
            subtitle: const Text('Se mostrará al reiniciar la aplicación'),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('onboarding_visto', false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Onboarding reiniciado. Cierra y abre la app.',
                    ),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Volver a ver las guías'),
            subtitle: const Text(
              'Las guías aparecerán otra vez al entrar a cada sección',
            ),
            onTap: () {
              context.read<GuiasProvider>().reiniciarTodas();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Guías reiniciadas. Se mostrarán la próxima vez.',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text('Volver a ver el resumen semanal'),
            subtitle: const Text(
              'Se mostrará de nuevo al abrir el Panel de Control',
            ),
            onTap: () {
              context.read<ResumenSemanalProvider>().reiniciar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Resumen reiniciado. Se mostrará la próxima vez.',
                  ),
                ),
              );
            },
          ),

          const Divider(height: 32),

          // ── Zona de riesgo ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Zona de riesgo',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: theme.colorScheme.error,
            ),
            title: const Text('Restablecer todos los datos'),
            subtitle: const Text(
              'Elimina eventos, rutinas, tareas, salud, perfil, '
              'comunidad, notas, guías, comentarios, feriados, '
              'licencia, metas y ajustes',
            ),
            onTap: () => _confirmarReset(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Exportar ──────────────────────────────────────────────

  Future<void> _exportarDatos(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final backupService = BackupService();

    try {
      final eventos = context.read<EventosProvider>().eventos;
      final rutinasProv = context.read<RutinasProvider>();
      final tareas = context.read<TareasProvider>().tareas;
      final alimentacion = context.read<AlimentacionProvider>().registros;
      final ejercicioProv = context.read<EjercicioProvider>();
      final medicacionProv = context.read<MedicacionProvider>();
      final perfil = context.read<PerfilProvider>().perfil;
      final comunidadProv = context.read<ComunidadProvider>();
      final notas = context.read<NotasProvider>().notasSinFiltrar;

      final backup = backupService.generarBackup(
        eventos: eventos,
        rutinas: rutinasProv.rutinas,
        grupos: rutinasProv.gruposReales,
        tareas: tareas,
        alimentacion: alimentacion,
        ejercicios: ejercicioProv.ejercicios,
        registrosEjercicio: ejercicioProv.registros,
        medicamentos: medicacionProv.medicamentos,
        registrosMedicacion: medicacionProv.registros,
        perfil: perfil,
        itemsUsuario: comunidadProv.itemsUsuario,
        likesComunidad: {},
        notas: notas,
      );

      final archivo = await backupService.guardarBackupEnArchivo(backup);

      await Share.shareXFiles(
        [XFile(archivo.path)],
        subject: 'Respaldo de Ruty',
        text: 'Aquí tienes tu respaldo de Ruty.',
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Respaldo generado correctamente'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  // ─── Importar ──────────────────────────────────────────────

  Future<void> _importarDatos(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final backupService = BackupService();

    try {
      final backup = await backupService.seleccionarYLeerBackup();
      if (backup == null) return;

      final error = backupService.validarBackup(backup);
      if (error != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(error)),
        );
        return;
      }

      if (!context.mounted) return;

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Importar datos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se reemplazarán todos tus datos actuales por los del '
                'archivo seleccionado.\n\n'
                'Esta acción no se puede deshacer.',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  backupService.describirBackup(backup),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importar'),
            ),
          ],
        ),
      );

      if (confirmar != true) return;
      if (!context.mounted) return;

      await _aplicarBackup(context, backup);

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Datos importados correctamente'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al importar: $e')),
      );
    }
  }

  Future<void> _aplicarBackup(
    BuildContext context,
    Map<String, dynamic> backup,
  ) async {
    final backupService = BackupService();
    final datos = backupService.extraerDatos(backup);
    final prefs = await SharedPreferences.getInstance();

    Future<void> guardarLista(String clave, String? jsonValue) async {
      if (jsonValue == null) {
        await prefs.remove(clave);
      } else {
        await prefs.setString(clave, jsonValue);
      }
    }

    await guardarLista(
      'eventos',
      datos['eventos'] != null ? json.encode(datos['eventos']) : null,
    );
    await guardarLista(
      'rutinas',
      datos['rutinas'] != null ? json.encode(datos['rutinas']) : null,
    );
    await guardarLista(
      'grupos',
      datos['grupos'] != null ? json.encode(datos['grupos']) : null,
    );
    await guardarLista(
      'tareas',
      datos['tareas'] != null ? json.encode(datos['tareas']) : null,
    );
    await guardarLista(
      'alimentacion',
      datos['alimentacion'] != null ? json.encode(datos['alimentacion']) : null,
    );
    await guardarLista(
      'ejercicios',
      datos['ejercicios'] != null ? json.encode(datos['ejercicios']) : null,
    );
    await guardarLista(
      'registros_ejercicio',
      datos['registrosEjercicio'] != null
          ? json.encode(datos['registrosEjercicio'])
          : null,
    );
    await guardarLista(
      'medicamentos',
      datos['medicamentos'] != null ? json.encode(datos['medicamentos']) : null,
    );
    await guardarLista(
      'registros_medicacion',
      datos['registrosMedicacion'] != null
          ? json.encode(datos['registrosMedicacion'])
          : null,
    );
    await guardarLista(
      'perfil_usuario',
      datos['perfil'] != null ? json.encode(datos['perfil']) : null,
    );
    await guardarLista(
      'comunidad_usuario',
      datos['comunidadUsuario'] != null
          ? json.encode(datos['comunidadUsuario'])
          : null,
    );
    await guardarLista(
      'notas_rapidas',
      datos['notas'] != null ? json.encode(datos['notas']) : null,
    );
  }

  // ─── Reset ────────────────────────────────────────────────

  Future<void> _confirmarReset(BuildContext context) async {
    final eventosProv = context.read<EventosProvider>();
    final rutinasProv = context.read<RutinasProvider>();
    final tareasProv = context.read<TareasProvider>();
    final alimentacionProv = context.read<AlimentacionProvider>();
    final ejercicioProv = context.read<EjercicioProvider>();
    final medicacionProv = context.read<MedicacionProvider>();
    final perfilProv = context.read<PerfilProvider>();
    final comunidadProv = context.read<ComunidadProvider>();
    final notificacionesPrefsProv = context.read<NotificacionesPrefsProvider>();
    final notasProv = context.read<NotasProvider>();
    final guiasProv = context.read<GuiasProvider>();
    final resumenProv = context.read<ResumenSemanalProvider>();
    final comentariosProv = context.read<ComentariosProvider>();
    final feriadosProv = context.read<FeriadosProvider>();
    final licenciaProv = context.read<LicenciaProvider>();
    final metasProv = context.read<MetasProvider>();
    final themeProv = context.read<ThemeProvider>();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Restablecer todo?'),
        content: const Text(
          'Se eliminarán todos tus datos: eventos, rutinas, tareas, '
          'registros de salud, perfil, comunidad, notas, guías, '
          'comentarios, feriados, licencia, metas y '
          'personalizaciones.\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar todo'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Future.wait([
        eventosProv.reset(),
        rutinasProv.reset(),
        tareasProv.reset(),
        alimentacionProv.reset(),
        ejercicioProv.reset(),
        medicacionProv.reset(),
        perfilProv.reset(),
        comunidadProv.reset(),
        notificacionesPrefsProv.reset(),
        notasProv.reset(),
        guiasProv.reset(),
        resumenProv.reset(),
        comentariosProv.reset(),
        feriadosProv.reset(),
        licenciaProv.reset(),
        metasProv.reset(),
        themeProv.reset(),
        UpdateService.reset(),
      ]);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todos los datos fueron restablecidos'),
          ),
        );
      }
    }
  }
}

class _ColorSelector extends StatelessWidget {
  final ValueChanged<Color> onChanged;

  const _ColorSelector({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colores = [
      Colors.indigo,
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.amber,
      Colors.grey,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colores
          .map(
            (c) => GestureDetector(
              onTap: () => onChanged(c),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
