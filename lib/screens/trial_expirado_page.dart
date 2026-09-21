import 'package:flutter/material.dart';

import 'activacion/activacion_page.dart';

class TrialExpiradoPage extends StatelessWidget {
  const TrialExpiradoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // ── Icono ──
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_clock,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),

              // ── Título ──
              Text(
                'Prueba finalizada',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ── Descripción ──
              Text(
                'Tu período de prueba de 2 días ha terminado.\n\n'
                'Para seguir usando Horario App, activa tu licencia '
                'completa insertando el código que te proporcionó '
                'el desarrollador.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ── Botón principal ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ActivacionPage(bloqueante: true),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_open),
                  label: const Text(
                    'Insertar código de activación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Contacto ──
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Contacto del desarrollador',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.person),
                        title: Text('Leonard Vera'),
                        subtitle: Text('DonMate'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.email),
                        title: Text('Correo'),
                        subtitle: Text('correo@ejemplo.com'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
