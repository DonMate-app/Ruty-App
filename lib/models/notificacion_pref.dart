class NotificacionPref {
  bool habilitada;
  String sonido;
  String? customSoundPath;
  bool vibracion;
  bool pantallaCompleta;
  bool despertarPantalla;
  bool modoAlarma;
  int anticipacionMinutos;
  int reintentoMinutos;
  int maxReintentos;
  int snoozeMinutos;

  NotificacionPref({
    this.habilitada = true,
    this.sonido = 'default',
    this.customSoundPath,
    this.vibracion = true,
    this.pantallaCompleta = false,
    this.despertarPantalla = false,
    this.modoAlarma = false,
    this.anticipacionMinutos = 0,
    this.reintentoMinutos = 0,
    this.maxReintentos = 3,
    this.snoozeMinutos = 5,
  });

  Map<String, dynamic> toJson() => {
    'habilitada': habilitada,
    'sonido': sonido,
    'customSoundPath': customSoundPath,
    'vibracion': vibracion,
    'pantallaCompleta': pantallaCompleta,
    'despertarPantalla': despertarPantalla,
    'modoAlarma': modoAlarma,
    'anticipacionMinutos': anticipacionMinutos,
    'reintentoMinutos': reintentoMinutos,
    'maxReintentos': maxReintentos,
    'snoozeMinutos': snoozeMinutos,
  };

  factory NotificacionPref.fromJson(Map<String, dynamic> json) {
    return NotificacionPref(
      habilitada: json['habilitada'] ?? true,
      sonido: json['sonido'] ?? 'default',
      customSoundPath: json['customSoundPath'],
      vibracion: json['vibracion'] ?? true,
      pantallaCompleta: json['pantallaCompleta'] ?? false,
      despertarPantalla: json['despertarPantalla'] ?? false,
      modoAlarma: json['modoAlarma'] ?? false,
      anticipacionMinutos: json['anticipacionMinutos'] ?? 0,
      reintentoMinutos: json['reintentoMinutos'] ?? 0,
      maxReintentos: json['maxReintentos'] ?? 3,
      snoozeMinutos: json['snoozeMinutos'] ?? 5,
    );
  }
}