import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AcercaDePage extends StatefulWidget {
  const AcercaDePage({super.key});

  @override
  State<AcercaDePage> createState() => _AcercaDePageState();
}

class _AcercaDePageState extends State<AcercaDePage> {
  String _version = '...';
  String _buildNumber = '...';
  String _packageName = '...';

  @override
  void initState() {
    super.initState();
    _cargarInfo();
  }

  Future<void> _cargarInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
        _packageName = info.packageName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final anioActual = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Encabezado ──
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 80,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ruty',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rutina y Organización',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'v$_version (build $_buildNumber)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Descripción ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ruty es una aplicación de gestión de tiempo y hábitos '
                      'que te permite organizar eventos, rutinas, tareas, '
                      'alimentación, ejercicio y medicación de forma intuitiva '
                      'y personalizable.\n\n'
                      'Diseñada para ayudarte a mantener una vida más '
                      'saludable y productiva, con recordatorios, estadísticas, '
                      'metas y recomendaciones personalizadas.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Información técnica ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información técnica',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _filaInfo('Versión', _version),
                    _filaInfo('Build', _buildNumber),
                    _filaInfo('Paquete', _packageName),
                    _filaInfo(
                      'Plataforma',
                      Theme.of(context).platform.name,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Desarrollador ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Desarrollador',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.business),
                      title: Text('DonMate'),
                      subtitle: Text('Leonard Vera · Sebastián Marín'),
                    ),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.email),
                      title: Text('Contacto'),
                      subtitle: Text('donmate.apps@gmail.com'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Créditos ──
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.music_note,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Créditos',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sonidos y recursos',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _credito(
                      context,
                      titulo: 'Alarm Clock',
                      autor: 'Pixabay',
                      licencia: 'Pixabay Content License',
                    ),
                    _credito(
                      context,
                      titulo: 'Alert Ding Tone',
                      autor: 'Pixabay',
                      licencia: 'Pixabay Content License',
                    ),
                    _credito(
                      context,
                      titulo: 'New Notification 028',
                      autor: 'Pixabay',
                      licencia: 'Pixabay Content License',
                    ),
                    _credito(
                      context,
                      titulo: 'Soft Digital UI Notification Chime',
                      autor: 'Orange Free Sounds',
                      licencia: 'CC BY 4.0',
                    ),
                    _credito(
                      context,
                      titulo: 'Popup Sound Effect',
                      autor: 'Orange Free Sounds',
                      licencia: 'CC BY 4.0',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Los sonidos de Orange Free Sounds se usan bajo la '
                      'licencia Creative Commons Attribution 4.0. '
                      'Los sonidos de Pixabay se usan bajo la licencia '
                      'Pixabay Content License.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Librerías open source',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _libreria(context, 'Flutter', 'Google LLC'),
                    _libreria(context, 'Provider', 'Remi Rousselet'),
                    _libreria(context, 'Table Calendar', 'Aleksander Woźny'),
                    _libreria(context, 'Shared Preferences', 'Flutter Team'),
                    _libreria(
                      context,
                      'flutter_local_notifications',
                      'Michael Bui',
                    ),
                    _libreria(context, 'TimeZone', 'Dart Team'),
                    _libreria(context, 'Intl', 'Dart Team'),
                    _libreria(context, 'UUID', 'Yulian Kuncheff'),
                    _libreria(context, 'Package Info Plus', 'Flutter Team'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Pie de página ──
            Center(
              child: Text(
                '© $anioActual DonMate. Todos los derechos reservados.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _filaInfo(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta),
          Flexible(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _credito(
    BuildContext context, {
    required String titulo,
    required String autor,
    required String licencia,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.audiotrack,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodySmall,
                children: [
                  TextSpan(
                    text: '"$titulo" ',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  TextSpan(text: 'por $autor · $licencia'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _libreria(
    BuildContext context,
    String nombre,
    String autor,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            Icons.code,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$nombre — $autor',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
