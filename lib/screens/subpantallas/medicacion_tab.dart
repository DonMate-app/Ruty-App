import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/registro_medicacion.dart';
import '../../providers/avisos_provider.dart';
import '../../providers/medicacion_provider.dart';
import '../../providers/sound_provider.dart';
import '../../widgets/add_medicamento_dialog.dart';
import '../../widgets/success_animation.dart';
import '../../models/aviso.dart';

class MedicacionTab extends StatefulWidget {
  const MedicacionTab({super.key});

  @override
  State<MedicacionTab> createState() => _MedicacionTabState();
}

class _MedicacionTabState extends State<MedicacionTab> {
  DateTime _fecha = DateTime.now();

  void _abrirNuevoMedicamento() {
    showDialog(
      context: context,
      builder: (_) => const AddMedicamentoDialog(),
    );
  }

  void _opcionesMedicamento(String id) {
    final prov = context.read<MedicacionProvider>();
    final med = prov.medicamentos.firstWhere((m) => m.id == id);

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
                  builder: (_) => AddMedicamentoDialog(
                    medicamentoExistente: med,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Eliminar'),
              onTap: () {
                Navigator.pop(ctx);
                prov.eliminarMedicamento(med.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MedicacionProvider>();
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
            child: prov.medicamentos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aún no has añadido medicamentos',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca el botón + para añadir tu primer medicamento.',
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
                    itemCount: prov.medicamentos.length,
                    itemBuilder: (_, i) {
                      final med = prov.medicamentos[i];
                      final registro = registros.firstWhere(
                        (r) => r.medicamentoId == med.id,
                        orElse: () => RegistroMedicacion(
                          id: '',
                          medicamentoId: med.id,
                          fechaHora: DateTime(
                            _fecha.year,
                            _fecha.month,
                            _fecha.day,
                            med.hora.hour,
                            med.hora.minute,
                          ),
                          tomado: false,
                        ),
                      );
                      return ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: registro.tomado,
                              onChanged: (value) {
                                context.read<SoundProvider>().reproducirClick();
                                if (registro.id.isEmpty) {
                                  prov.agregarRegistro(
                                    RegistroMedicacion(
                                      id: const Uuid().v4(),
                                      medicamentoId: med.id,
                                      fechaHora: DateTime(
                                        _fecha.year,
                                        _fecha.month,
                                        _fecha.day,
                                        med.hora.hour,
                                        med.hora.minute,
                                      ),
                                      tomado: value ?? false,
                                    ),
                                  );
                                } else {
                                  prov.marcarTomado(
                                    registro.id,
                                    value ?? false,
                                  );
                                }
                                if (value == true) {
                                  mostrarAnimacionExito(
                                    context,
                                    mensaje: '¡Tomado!',
                                    icono: Icons.check,
                                    duracion: const Duration(
                                      milliseconds: 900,
                                    ),
                                  );
                                  context.read<AvisosProvider>().mostrar(
                                        '${med.nombre} registrado',
                                        tipo: TipoAviso.exito,
                                      );
                                }
                              },
                            ),
                            CircleAvatar(
                              backgroundColor: med.color,
                              radius: 14,
                              child: const Icon(
                                Icons.medication,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                        title: Text(med.nombre),
                        subtitle: Text(
                          '${med.dosis} · ${med.frecuencia} · ${med.hora.format(context)}',
                        ),
                        onTap: () => _opcionesMedicamento(med.id),
                        onLongPress: () => _opcionesMedicamento(med.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Añadir medicamento',
        onPressed: _abrirNuevoMedicamento,
        child: const Icon(Icons.add),
      ),
    );
  }
}
