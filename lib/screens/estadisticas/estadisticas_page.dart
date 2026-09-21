import 'package:flutter/material.dart';

import '../../widgets/guia_dialogo.dart';
import '../../widgets/pro_guard.dart';
import 'subpantallas/alimentacion_stats.dart';
import 'subpantallas/ejercicio_stats.dart';
import 'subpantallas/medicacion_stats.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mostrarGuiaSiNecesario(context, 'estadisticas');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProGuard(
      nombreFuncion: 'Estadísticas',
      descripcion:
          'Analiza tu progreso con gráficos detallados de alimentación, '
          'ejercicio y medicación. Descubre patrones y mejora tus hábitos.',
      icono: Icons.insights,
      requiereStats: true,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Estadísticas'),
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
              AlimentacionStats(),
              EjercicioStats(),
              MedicacionStats(),
            ],
          ),
        ),
      ),
    );
  }
}
