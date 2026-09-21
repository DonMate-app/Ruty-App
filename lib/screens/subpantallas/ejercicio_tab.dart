import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/registro_ejercicio.dart';
import '../../providers/ejercicio_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/add_ejercicio_dialog.dart';

class EjercicioTab extends StatefulWidget {
  const EjercicioTab({super.key});

  @override
  State<EjercicioTab> createState() => _EjercicioTabState();
}

class _EjercicioTabState extends State<EjercicioTab> {
  DateTime _fecha = DateTime.now();

  void _abrirNuevoEjercicio() {
    showDialog(
      context: context,
      builder: (_) => const AddEjercicioDialog(),
    );
  }

  void _opcionesEjercicio(String id) {
    final prov = context.read<EjercicioProvider>();
    final ej = prov.ejercicios.firstWhere((e) => e.id == id);

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modificar'),
              onTap: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AddEjercicioDialog(
                    ejercicioExistente: ej,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                prov.eliminarEjercicio(ej.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EjercicioProvider>();
    final registros = prov.registrosDeDia(_fecha);
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _fecha = _fecha.subtract(const Duration(days: 1));
                  }),
                ),
                Text(
                  '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                  style: const TextStyle(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _fecha = _fecha.add(const Duration(days: 1));
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: prov.ejercicios.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no has añadido ejercicios',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para añadir tu primer ejercicio.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: prov.ejercicios.length,
                    itemBuilder: (_, i) {
                      final ejercicio = prov.ejercicios[i];
                      final registro = registros.firstWhere(
                        (r) => r.ejercicioId == ejercicio.id,
                        orElse: () => RegistroEjercicio(
                          id: '',
                          ejercicioId: ejercicio.id,
                          fecha: _fecha,
                          completado: false,
                        ),
                      );
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: registro.completado,
                              onChanged: (value) {
                                context.read<SoundProvider>().reproducirClick();
                                if (registro.id.isEmpty) {
                                  prov.agregarRegistro(
                                    RegistroEjercicio(
                                      id: const Uuid().v4(),
                                      ejercicioId: ejercicio.id,
                                      fecha: _fecha,
                                      completado: value ?? false,
                                    ),
                                  );
                                } else {
                                  prov.marcarCompletado(
                                    registro.id,
                                    value ?? false,
                                  );
                                }
                              },
                            ),
                            CircleAvatar(
                              backgroundColor: ejercicio.color,
                              radius: 14,
                              child: const Icon(
                                Icons.fitness_center,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        title: Text(ejercicio.nombre),
                        subtitle: Text(
                          '${ejercicio.tipo} · ${ejercicio.objetivoMinutos} min · ${ejercicio.objetivoRepeticiones} reps',
                        ),
                        onTap: () => _opcionesEjercicio(ejercicio.id),
                        onLongPress: () => _opcionesEjercicio(ejercicio.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir ejercicio',
        onPressed: _abrirNuevoEjercicio,
        child: const Icon(Icons.add),
      ),
    );
  }
}
