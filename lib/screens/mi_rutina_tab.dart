import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/eventos_provider.dart';
import '../providers/rutinas_provider.dart';
import '../providers/sound_provider.dart';
import '../providers/theme_provider.dart';
import '../models/evento.dart';
import '../models/rutina.dart';
import '../widgets/guia_dialogo.dart';

class MiRutinaTab extends StatefulWidget {
  const MiRutinaTab({super.key});

  @override
  State<MiRutinaTab> createState() => _MiRutinaTabState();
}

class _MiRutinaTabState extends State<MiRutinaTab> {
  String? _grupoSelId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'mi_rutina');
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final rutinasProv = context.watch<RutinasProvider>();
    final fontFamily = themeProv.fontFamily;
    final grupos = rutinasProv.grupos;

    if (_grupoSelId == null && grupos.isNotEmpty) {
      _grupoSelId = grupos.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Rutina')),
      body: Column(
        children: [
          _barraDeTiempo(rutinasProv, fontFamily),
          const Divider(height: 1),
          Row(
            children: [
              const SizedBox(width: 8),
              Text('Grupos:', style: TextStyle(fontFamily: fontFamily)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...grupos.map(
                        (g) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(g.nombre),
                            selected: _grupoSelId == g.id,
                            onSelected: (_) =>
                                setState(() => _grupoSelId = g.id),
                          ),
                        ),
                      ),
                      if (rutinasProv.gruposReales.length < 6)
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Nuevo grupo',
                          onPressed: _dialogoAgregarGrupo,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: _grupoSelId == null
                ? const Center(child: Text('Selecciona un grupo'))
                : _contenidoGrupo(rutinasProv, fontFamily),
          ),
        ],
      ),
    );
  }

  Widget _barraDeTiempo(RutinasProvider prov, String fontFamily) {
    final grupoId = _grupoSelId;
    final rutinas =
        grupoId != null ? prov.rutinasDeGrupo(grupoId).toList() : <Rutina>[];
    rutinas.sort((a, b) {
      final aMin = a.hora.hour * 60 + a.hora.minute;
      final bMin = b.hora.hour * 60 + b.hora.minute;
      return aMin.compareTo(bMin);
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Horario del grupo',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) {
              final anchoTotal = constraints.maxWidth;
              return Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Stack(
                  children: [
                    ...rutinas.map((r) {
                      final left = (r.hora.hour / 24) * anchoTotal;
                      final width = (1 / 24) * anchoTotal;
                      return Positioned(
                        left: left,
                        top: 2,
                        bottom: 2,
                        width: width,
                        child: GestureDetector(
                          onTap: () => _agregarEventoDesdeRutina(r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: r.color.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Center(
                              child: Text(
                                r.titulo,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _agregarEventoDesdeRutina(Rutina r) {
    final eventosProv = context.read<EventosProvider>();
    final nuevoEvento = Evento.conDuracion(
      id: const Uuid().v4(),
      titulo: r.titulo,
      fecha: DateTime.now(),
      horaInicio: r.hora,
      duracion: const Duration(hours: 1),
      color: r.color,
    );
    eventosProv.agregarEvento(nuevoEvento);
    context.read<SoundProvider>().reproducirClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Evento "${r.titulo}" añadido a hoy')),
    );
  }

  Widget _contenidoGrupo(RutinasProvider prov, String fontFamily) {
    final grupoId = _grupoSelId!;
    final esTodos = grupoId == RutinasProvider.idGrupoTodos;

    final rutinas = prov.rutinasDeGrupo(grupoId).toList()
      ..sort((a, b) {
        final aMin = a.hora.hour * 60 + a.hora.minute;
        final bMin = b.hora.hour * 60 + b.hora.minute;
        return aMin.compareTo(bMin);
      });

    return Column(
      children: [
        if (!esTodos)
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => _dialogoEditarGrupo(grupoId),
                child: const Text('Editar grupo'),
              ),
              TextButton(
                onPressed: () => _dialogoEliminarGrupo(grupoId),
                child: const Text('Eliminar grupo'),
              ),
              TextButton.icon(
                onPressed: () {
                  prov.eliminarDuplicadosDeGrupo(grupoId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Duplicados eliminados')),
                  );
                },
                icon: const Icon(Icons.cleaning_services, size: 18),
                label: const Text('Limpiar duplicados'),
              ),
            ],
          ),
        if (esTodos)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Vista general de todas las rutinas de todos los grupos',
              style: TextStyle(
                fontFamily: fontFamily,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ElevatedButton.icon(
          onPressed: () => _mostrarOpcionesAplicarRutinas(
            prov,
            grupoId,
            esTodos,
          ),
          icon: const Icon(Icons.today),
          label: Text(
            esTodos ? 'Aplicar TODAS las rutinas' : 'Aplicar rutinas',
          ),
        ),
        Expanded(
          child: rutinas.isEmpty
              ? Center(
                  child: Text(
                    esTodos
                        ? 'No hay rutinas en ningún grupo'
                        : 'Este grupo no tiene rutinas aún',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: rutinas.length,
                  itemBuilder: (_, i) {
                    final r = rutinas[i];
                    final grupo = prov.gruposReales
                        .where((g) => g.id == r.grupoId)
                        .toList();
                    final nombreGrupo =
                        grupo.isNotEmpty ? grupo.first.nombre : '';

                    return ListTile(
                      leading: CircleAvatar(backgroundColor: r.color),
                      title: Text(
                        r.titulo,
                        style: TextStyle(fontFamily: fontFamily),
                      ),
                      subtitle: Text(
                        esTodos
                            ? '${r.hora.format(context)} · $nombreGrupo'
                            : 'A las ${r.hora.format(context)}',
                        style: TextStyle(fontFamily: fontFamily),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => prov.eliminarRutina(r.id),
                      ),
                    );
                  },
                ),
        ),
        if (!esTodos)
          ElevatedButton.icon(
            onPressed: () => _dialogoAgregarRutina(grupoId),
            icon: const Icon(Icons.add),
            label: const Text('Agregar rutina'),
          ),
      ],
    );
  }

  Future<void> _mostrarOpcionesAplicarRutinas(
    RutinasProvider prov,
    String grupoId,
    bool esTodos,
  ) async {
    final opcion = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aplicar rutinas'),
        content: Text(
          esTodos
              ? 'Se aplicarán TODAS las rutinas de todos los grupos. '
                  '¿A qué días quieres aplicarlas?'
              : 'Se aplicarán las rutinas de este grupo. '
                  '¿A qué días quieres aplicarlas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(ctx, 'hoy'),
            icon: const Icon(Icons.today, size: 18),
            label: const Text('Solo hoy'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, 'recurrente'),
            icon: const Icon(Icons.repeat, size: 18),
            label: const Text('Hoy y siguientes'),
          ),
        ],
      ),
    );

    if (opcion == null) return;

    final eventosProv = context.read<EventosProvider>();
    final ahora = DateTime.now();

    if (opcion == 'hoy') {
      prov.aplicarRutinasDeGrupo(grupoId, ahora, eventosProv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rutinas aplicadas al día de hoy'),
          ),
        );
      }
    } else if (opcion == 'recurrente') {
      prov.aplicarRutinasDeGrupoRecurrente(grupoId, ahora, eventosProv);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Rutinas aplicadas desde hoy en adelante (recurrentes)',
            ),
          ),
        );
      }
    }

    if (mounted) {
      context.read<SoundProvider>().reproducirClick();
    }
  }

  void _dialogoAgregarGrupo() {
    final nombreCtrl = TextEditingController();
    Color colorSeleccionado = Colors.indigo;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nuevo grupo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(hintText: 'Nombre del grupo'),
              ),
              const SizedBox(height: 10),
              const Text('Color del grupo:'),
              Wrap(
                spacing: 8,
                children: [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal,
                ]
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => colorSeleccionado = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: colorSeleccionado == c
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nombreCtrl.text.trim().isNotEmpty) {
                  context
                      .read<RutinasProvider>()
                      .agregarGrupo(nombreCtrl.text.trim(), colorSeleccionado);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _dialogoEditarGrupo(String grupoId) {
    final prov = context.read<RutinasProvider>();
    final grupo = prov.gruposReales.firstWhere((g) => g.id == grupoId);
    final ctrl = TextEditingController(text: grupo.nombre);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar grupo'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                prov.modificarGrupo(grupoId, ctrl.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _dialogoEliminarGrupo(String grupoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar grupo?'),
        content: const Text('Se borrarán también todas sus rutinas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RutinasProvider>().eliminarGrupo(grupoId);
              setState(() => _grupoSelId = null);
              Navigator.pop(ctx);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _dialogoAgregarRutina(String grupoId) {
    final titCtrl = TextEditingController();
    TimeOfDay hora = const TimeOfDay(hour: 8, minute: 0);
    Color colorSel = context
        .read<RutinasProvider>()
        .gruposReales
        .firstWhere((g) => g.id == grupoId)
        .color;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Nueva rutina'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              ListTile(
                title: const Text('Hora'),
                subtitle: Text(hora.format(context)),
                onTap: () async {
                  final h = await showTimePicker(
                    context: context,
                    initialTime: hora,
                  );
                  if (h != null) {
                    setState(() => hora = h);
                  }
                },
              ),
              Wrap(
                spacing: 8,
                children: [
                  Colors.red,
                  Colors.blue,
                  Colors.green,
                  Colors.orange,
                  Colors.purple,
                  Colors.teal,
                  Colors.indigo,
                ]
                    .map(
                      (c) => GestureDetector(
                        onTap: () => setState(() => colorSel = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: colorSel == c
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titCtrl.text.trim().isNotEmpty) {
                  context.read<RutinasProvider>().agregarRutina(
                        grupoId,
                        titCtrl.text.trim(),
                        hora,
                        colorSel,
                      );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
