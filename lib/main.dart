import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import './models/registro_medicacion.dart';
import './providers/eventos_provider.dart';
import './providers/theme_provider.dart';
import './providers/rutinas_provider.dart';
import './providers/alimentacion_provider.dart';
import './providers/ejercicio_provider.dart';
import './providers/medicacion_provider.dart';
import './providers/sound_provider.dart';
import './providers/tareas_provider.dart';
import './providers/perfil_provider.dart';
import './providers/comunidad_provider.dart';
import './providers/notificaciones_prefs_provider.dart';
import './providers/avisos_provider.dart';
import './providers/notas_provider.dart';
import './providers/guias_provider.dart';
import './providers/resumen_semanal_provider.dart';
import './providers/comentarios_provider.dart';
import './providers/feriados_provider.dart';
import './providers/licencia_provider.dart';
import './providers/trial_provider.dart';
import './providers/estado_pro_provider.dart';
import './services/notification_service.dart';
import './services/alarma_service.dart';
import './services/update_service.dart';
import './screens/pagina_principal.dart';
import './screens/onboarding_page.dart';
import './screens/alarma/alarma_page.dart';
import './widgets/update_dialog.dart';
import './providers/metas_provider.dart';

@pragma('vm:entry-point')
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es_ES', null);

  final notificationService = NotificationService();
  await notificationService.init();

  final eventosProv = EventosProvider(notificationService: notificationService);
  final themeProv = ThemeProvider();
  final rutinasProv = RutinasProvider(notificationService: notificationService);
  final alimentacionProv = AlimentacionProvider();
  final ejercicioProv = EjercicioProvider();
  final medicacionProv =
      MedicacionProvider(notificationService: notificationService);
  final soundProv = SoundProvider();
  final tareasProv = TareasProvider();
  final perfilProv = PerfilProvider();
  final comunidadProv = ComunidadProvider();
  final notificacionesPrefsProv = NotificacionesPrefsProvider();
  final avisosProv = AvisosProvider();
  final notasProv = NotasProvider();
  final guiasProv = GuiasProvider();
  final resumenProv = ResumenSemanalProvider();
  final comentariosProv = ComentariosProvider();
  final feriadosProv = FeriadosProvider();
  final licenciaProv = LicenciaProvider();
  final trialProv = TrialProvider();
  final estadoProProv = EstadoProProvider();
  final alarmaService = AlarmaService();
  final metasProv = MetasProvider();

  await Future.wait([
    eventosProv.cargar(),
    themeProv.cargar(),
    rutinasProv.cargar(),
    alimentacionProv.cargar(),
    ejercicioProv.cargar(),
    medicacionProv.cargar(),
    tareasProv.cargar(),
    perfilProv.cargar(),
    comunidadProv.cargar(),
    notificacionesPrefsProv.cargar(),
    notasProv.cargar(),
    guiasProv.cargar(),
    resumenProv.cargar(),
    comentariosProv.cargar(),
    feriadosProv.cargar(),
    licenciaProv.cargar(),
    trialProv.cargar(),
    metasProv.cargar(),
  ]);

  estadoProProv.setTrialProvider(trialProv);
  await estadoProProv.cargar();

  notificationService.setPrefsProvider(notificacionesPrefsProv);
  medicacionProv.setPrefsProvider(notificacionesPrefsProv);

  final navigatorKey = GlobalKey<NavigatorState>();

  notificationService.setAccionCallback((accion, payload) {
    final partes = payload.split(':');
    if (partes.length < 2) return;
    final tipo = partes[0];
    final entidadId = partes.sublist(1).join(':');

    if (accion == 'tocado') {
      final pref = notificacionesPrefsProv.getPref(tipo);
      if (pref.modoAlarma) {
        _abrirAlarmaDesde(payload, tipo, entidadId, navigatorKey,
            medicacionProv, notificacionesPrefsProv, alarmaService);
      }
      return;
    }

    if (tipo == 'medicacion') {
      final med =
          medicacionProv.medicamentos.where((m) => m.id == entidadId).toList();
      if (med.isEmpty) return;
      final medicamento = med.first;

      if (accion == 'tomado') {
        final hoy = DateTime.now();
        final registros = medicacionProv
            .registrosDeDia(hoy)
            .where((r) => r.medicamentoId == entidadId)
            .toList();

        if (registros.isNotEmpty) {
          medicacionProv.marcarTomado(registros.first.id, true);
        } else {
          final id = DateTime.now().millisecondsSinceEpoch.toString();
          medicacionProv.agregarRegistro(
            RegistroMedicacion(
              id: id,
              medicamentoId: entidadId,
              fechaHora: hoy,
              tomado: true,
            ),
          );
        }
        alarmaService.detener();
      } else if (accion == 'posponer') {
        final prefs = notificacionesPrefsProv.getPref('medicacion');
        notificationService.snooze(
          categoria: 'medicacion',
          title: medicamento.nombre,
          body: 'Hora de tomar tu medicamento: ${medicamento.dosis}',
          minutos: prefs.snoozeMinutos,
          payload: 'medicacion:$entidadId',
          acciones: [
            const AndroidNotificationAction(
              'tomado',
              'Tomado',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'posponer',
              'Posponer',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            const AndroidNotificationAction(
              'ignorar',
              'Ignorar',
              showsUserInterface: false,
              cancelNotification: true,
            ),
          ],
        );
        alarmaService.detener();
      }
    }
  });

  final prefs = await SharedPreferences.getInstance();
  final onboardingVisto = prefs.getBool('onboarding_visto') ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: eventosProv),
        ChangeNotifierProvider.value(value: themeProv),
        ChangeNotifierProvider.value(value: rutinasProv),
        ChangeNotifierProvider.value(value: alimentacionProv),
        ChangeNotifierProvider.value(value: ejercicioProv),
        ChangeNotifierProvider.value(value: medicacionProv),
        ChangeNotifierProvider.value(value: soundProv),
        ChangeNotifierProvider.value(value: tareasProv),
        ChangeNotifierProvider.value(value: perfilProv),
        ChangeNotifierProvider.value(value: comunidadProv),
        ChangeNotifierProvider.value(value: notificacionesPrefsProv),
        ChangeNotifierProvider.value(value: avisosProv),
        ChangeNotifierProvider.value(value: notasProv),
        ChangeNotifierProvider.value(value: guiasProv),
        ChangeNotifierProvider.value(value: resumenProv),
        ChangeNotifierProvider.value(value: comentariosProv),
        ChangeNotifierProvider.value(value: feriadosProv),
        ChangeNotifierProvider.value(value: licenciaProv),
        ChangeNotifierProvider.value(value: trialProv),
        ChangeNotifierProvider.value(value: estadoProProv),
        ChangeNotifierProvider.value(value: alarmaService),
        ChangeNotifierProvider.value(value: metasProv),
      ],
      child: HorarioApp(
        mostrarOnboarding: !onboardingVisto,
        navigatorKey: navigatorKey,
      ),
    ),
  );
}

void _abrirAlarmaDesde(
  String payload,
  String categoria,
  String entidadId,
  GlobalKey<NavigatorState> navigatorKey,
  MedicacionProvider medicacionProv,
  NotificacionesPrefsProvider prefsProv,
  AlarmaService alarmaService,
) {
  String titulo = 'Alarma';
  String cuerpo = '';

  if (categoria == 'medicacion') {
    final med =
        medicacionProv.medicamentos.where((m) => m.id == entidadId).toList();
    if (med.isNotEmpty) {
      titulo = med.first.nombre;
      cuerpo = 'Hora de tomar tu medicamento: ${med.first.dosis}';
    }
  }

  final pref = prefsProv.getPref(categoria);
  final sonido = pref.sonido == 'custom' && pref.customSoundPath != null
      ? 'custom:${pref.customSoundPath}'
      : (pref.sonido == 'default' || pref.sonido.isEmpty
          ? 'alarm'
          : pref.sonido);

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => AlarmaPage(
        categoria: categoria,
        payload: payload,
        sonidoInicial: sonido,
        tituloInicial: titulo,
        cuerpoInicial: cuerpo,
        vibrarInicial: pref.vibracion,
      ),
      fullscreenDialog: true,
    ),
  );
}

class HorarioApp extends StatefulWidget {
  final bool mostrarOnboarding;
  final GlobalKey<NavigatorState>? navigatorKey;

  const HorarioApp({
    super.key,
    required this.mostrarOnboarding,
    this.navigatorKey,
  });

  @override
  State<HorarioApp> createState() => _HorarioAppState();
}

class _HorarioAppState extends State<HorarioApp> {
  @override
  void initState() {
    super.initState();
    // Comprobar actualizaciones después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarActualizacion();
    });
  }

  Future<void> _verificarActualizacion() async {
    // Esperar 4 segundos para no bloquear el arranque
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // ¿Ha pasado el intervalo mínimo?
    final debe = await UpdateService.debeChequear();
    if (!debe) return;

    final info = await UpdateService.verificarActualizacion();
    await UpdateService.marcarConsultado();

    if (info == null || !mounted) return;

    // ¿El usuario ya pospuso esta versión?
    final versionPospuesta = await UpdateService.versionPospuesta();
    if (versionPospuesta != null && versionPospuesta >= info.versionCode) {
      return;
    }

    final versionCodeActual = await UpdateService.versionCodeActual();

    await mostrarDialogoActualizacion(context, info, versionCodeActual);

    // Guardar para no volver a molestar hasta próxima versión.
    if (info.versionCode > versionCodeActual) {
      await UpdateService.posponerVersion(info.versionCode);
    }
  }

  ThemeData _buildTheme(ThemeProvider themeProv, Brightness brightness) {
    final base = ThemeData(
      brightness: brightness,
      primarySwatch: _crearSwatch(themeProv.colorPrimario),
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProv.colorPrimario,
        brightness: brightness,
        primary: themeProv.colorPrimario,
      ),
    );

    final textoPersonalizado = base.textTheme.apply(
      fontFamily: themeProv.fontFamily,
    );

    final colorTextoFinal = themeProv.textColor?.withValues(
      alpha: themeProv.textOpacity,
    );

    final textThemeFinal = colorTextoFinal != null
        ? textoPersonalizado.apply(
            bodyColor: colorTextoFinal,
            displayColor: colorTextoFinal,
          )
        : textoPersonalizado;

    return base.copyWith(
      textTheme: textThemeFinal,
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(themeProv.radioBorde),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: base.colorScheme.surfaceContainerHighest,
        indicatorColor: themeProv.colorPrimario.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(
            fontFamily: themeProv.fontFamily,
            fontSize: 12,
            color: colorTextoFinal ?? base.colorScheme.onSurface,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: themeProv.colorPrimario);
          }
          return IconThemeData(
            color: colorTextoFinal ?? base.colorScheme.onSurfaceVariant,
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: widget.navigatorKey,
      theme: _buildTheme(themeProv, Brightness.light),
      darkTheme: _buildTheme(themeProv, Brightness.dark),
      themeMode: themeProv.themeMode,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(themeProv.fontScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: widget.mostrarOnboarding
          ? const OnboardingPage()
          : const PaginaPrincipal(),
    );
  }

  MaterialColor _crearSwatch(Color color) {
    final int alpha = color.toARGB32();
    return MaterialColor(alpha, {
      50: color.withValues(alpha: 0.1),
      100: color.withValues(alpha: 0.2),
      200: color.withValues(alpha: 0.3),
      300: color.withValues(alpha: 0.4),
      400: color.withValues(alpha: 0.5),
      500: color.withValues(alpha: 0.6),
      600: color.withValues(alpha: 0.7),
      700: color.withValues(alpha: 0.8),
      800: color.withValues(alpha: 0.9),
      900: color,
    });
  }
}
