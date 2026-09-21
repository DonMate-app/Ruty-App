import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/feriados_data.dart';
import '../../providers/estado_pro_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/sound_provider.dart';
import '../../providers/feriados_provider.dart';
import '../../widgets/pro_feature_dialog.dart';

class PersonalizacionPage extends StatelessWidget {
  const PersonalizacionPage({super.key});

  static const List<String> _fuentes = [
    'Roboto',
    'sans-serif',
    'serif',
    'monospace',
  ];

  static const List<Color> _coloresTexto = [
    Colors.black,
    Colors.white,
    Colors.grey,
    Colors.blueGrey,
    Colors.brown,
    Colors.indigo,
    Colors.teal,
  ];

  static const List<Color> _paletaAmpliada = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black87,
  ];

  Future<void> _toggleModoExperto(BuildContext context, bool value) async {
    final themeProv = context.read<ThemeProvider>();
    final estado = context.read<EstadoProProvider>();

    // Si se está desactivando, permitir siempre
    if (!value) {
      themeProv.toggleModoExperto(false);
      return;
    }

    // Si se está activando y no es Pro → bloquear
    if (!estado.tieneAccesoPro) {
      final activado = await mostrarDialogoFuncionPro(
        context,
        nombreFuncion: 'Modo experto',
        descripcion: 'Desbloquea opciones avanzadas de personalización: '
            'control fino de tipografía, opacidad, transparencias y más.',
        icono: Icons.build,
      );
      if (!context.mounted) return;
      if (!activado || !context.read<EstadoProProvider>().tieneAccesoPro) {
        return;
      }
    }

    themeProv.toggleModoExperto(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final soundProv = context.watch<SoundProvider>();
    final feriadosProv = context.watch<FeriadosProvider>();
    final estado = context.watch<EstadoProProvider>();
    final esPro = estado.tieneAccesoPro;

    return Scaffold(
      appBar: AppBar(title: const Text('Personalización')),
      body: ListView(
        children: [
          // ── Color del tema ──
          _seccionTitulo(context, 'Color del tema'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _paletaAmpliada
                  .map(
                    (c) => GestureDetector(
                      onTap: () => themeProv.cambiarColor(c),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: themeProv.colorPrimario == c
                              ? Border.all(
                                  color: theme.colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ── Tipografía ──
          _seccionTitulo(context, 'Tipografía'),
          ListTile(
            title: const Text('Fuente'),
            subtitle: DropdownButton<String>(
              value: _fuentes.contains(themeProv.fontFamily)
                  ? themeProv.fontFamily
                  : _fuentes.first,
              isExpanded: true,
              items: _fuentes
                  .map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, style: TextStyle(fontFamily: f)),
                    ),
                  )
                  .toList(),
              onChanged: (f) {
                if (f != null) themeProv.cambiarFuente(f);
              },
            ),
          ),
          ListTile(
            title: const Text('Tamaño de texto'),
            subtitle: Slider(
              value: themeProv.fontScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: '${(themeProv.fontScale * 100).toInt()}%',
              onChanged: (v) => themeProv.cambiarEscalaFuente(v),
            ),
          ),
          ListTile(
            title: const Text('Color del texto'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  GestureDetector(
                    onTap: () => themeProv.cambiarColorTexto(null),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                        color: themeProv.textColor == null
                            ? Colors.grey.shade300
                            : Colors.transparent,
                      ),
                      child: const Icon(Icons.autorenew, size: 18),
                    ),
                  ),
                  ..._coloresTexto.map(
                    (c) => GestureDetector(
                      onTap: () => themeProv.cambiarColorTexto(c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: themeProv.textColor == c
                              ? Border.all(color: Colors.black, width: 3)
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: const Text('Opacidad del texto'),
            subtitle: Slider(
              value: themeProv.textOpacity,
              min: 0.3,
              max: 1.0,
              divisions: 7,
              label: '${(themeProv.textOpacity * 100).toInt()}%',
              onChanged: (v) => themeProv.cambiarOpacidadTexto(v),
            ),
          ),
          const SizedBox(height: 16),

          // ── Tema ──
          _seccionTitulo(context, 'Tema'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('Sistema'),
                  icon: Icon(Icons.settings_suggest),
                ),
              ],
              selected: {themeProv.modoManual},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                themeProv.cambiarModoManual(newSelection.first);
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Este modo se aplica cuando el modo automático por horario '
              'está desactivado.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Modo oscuro automático ──
          SwitchListTile(
            secondary: const Icon(Icons.nights_stay),
            title: const Text('Modo oscuro por horario'),
            subtitle: const Text(
              'Activa automáticamente el modo oscuro en un rango de horas',
            ),
            value: themeProv.modoAutomatico,
            onChanged: (v) => themeProv.toggleModoAutomatico(v),
          ),
          if (themeProv.modoAutomatico) ...[
            ListTile(
              leading: const Icon(Icons.bedtime),
              title: const Text('Inicio del modo oscuro'),
              subtitle: Text(_formatHora(themeProv.inicioOscuro)),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final h = await showTimePicker(
                  context: context,
                  initialTime: themeProv.inicioOscuro,
                );
                if (h != null) {
                  themeProv.cambiarInicioOscuro(h);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Fin del modo oscuro'),
              subtitle: Text(_formatHora(themeProv.finOscuro)),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final h = await showTimePicker(
                  context: context,
                  initialTime: themeProv.finOscuro,
                );
                if (h != null) {
                  themeProv.cambiarFinOscuro(h);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Activo ${themeProv.descripcionRangoOscuro}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Feriados ──
          _seccionTitulo(context, 'Feriados y calendarios'),
          SwitchListTile(
            secondary: const Icon(Icons.celebration),
            title: const Text('Mostrar feriados en el calendario'),
            subtitle: const Text(
              'Los días festivos se marcarán con un color distintivo',
            ),
            value: feriadosProv.mostrarFeriados,
            onChanged: (v) => feriadosProv.toggleMostrarFeriados(v),
          ),
          if (feriadosProv.mostrarFeriados)
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('País'),
              subtitle: Text(
                feriadosProv.paisActual != null
                    ? '${feriadosProv.paisActual!.emoji} '
                        '${feriadosProv.paisActual!.nombre}'
                    : 'Sin país seleccionado',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _seleccionarPais(context, feriadosProv),
            ),
          const SizedBox(height: 16),

          // ── Aspecto ──
          _seccionTitulo(context, 'Aspecto'),
          SwitchListTile(
            title: const Text('Animaciones'),
            subtitle: const Text(
              'Activar o desactivar animaciones de interfaz',
            ),
            value: themeProv.animacionesActivadas,
            onChanged: (v) => themeProv.toggleAnimaciones(v),
          ),
          SwitchListTile(
            title: const Text('Sonidos'),
            subtitle: const Text('Reproducir sonido al interactuar'),
            value: soundProv.sonidosActivados,
            onChanged: (v) => soundProv.toggleSonidos(v),
          ),
          ListTile(
            title: const Text('Radio de bordes'),
            subtitle: Slider(
              value: themeProv.radioBorde,
              min: 0,
              max: 24,
              divisions: 8,
              label: '${themeProv.radioBorde.toInt()}',
              onChanged: (v) => themeProv.cambiarRadioBorde(v),
            ),
          ),

          // ── Modo experto (con bloqueo) ──
          SwitchListTile(
            secondary: esPro
                ? const Icon(Icons.build)
                : const Icon(Icons.lock_outline),
            title: Row(
              children: [
                const Text('Modo experto'),
                if (!esPro) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              esPro
                  ? 'Mostrar opciones avanzadas'
                  : 'Función Pro. Actívala para acceder.',
            ),
            value: themeProv.modoExperto,
            onChanged: (v) => _toggleModoExperto(context, v),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _formatHora(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}';
  }

  void _seleccionarPais(
    BuildContext context,
    FeriadosProvider prov,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Selecciona tu país',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...FeriadosData.paises.map(
              (p) => ListTile(
                leading: Text(
                  p.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(p.nombre),
                trailing: prov.paisCodigo == p.codigo
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  prov.cambiarPais(p.codigo);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionTitulo(BuildContext context, String texto) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texto,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
