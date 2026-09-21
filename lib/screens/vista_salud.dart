import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/medicacion_provider.dart';
import '../widgets/guia_dialogo.dart';
import 'subpantallas/alimentacion_tab.dart';
import 'subpantallas/ejercicio_tab.dart';
import 'subpantallas/medicacion_tab.dart';
import 'salud_resumen.dart';

class VistaSalud extends StatefulWidget {
  const VistaSalud({super.key});

  @override
  State<VistaSalud> createState() => _VistaSaludState();
}

class _VistaSaludState extends State<VistaSalud> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'salud');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MedicacionProvider>().recargarRegistros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salud'),
          actions: [
            IconButton(
              icon: const Icon(Icons.insights),
              tooltip: 'Ver resumen mensual',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SaludResumenPage(),
                  ),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Alimentación'),
              Tab(icon: Icon(Icons.fitness_center), text: 'Ejercicio'),
              Tab(icon: Icon(Icons.medication), text: 'Medicación'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AlimentacionTab(),
            EjercicioTab(),
            MedicacionTab(),
          ],
        ),
      ),
    );
  }
}
