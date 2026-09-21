class UpdateInfo {
  final String version;
  final int versionCode;
  final String url;
  final List<String> cambios;
  final bool obligatoria;
  final int minVersionCode;

  const UpdateInfo({
    required this.version,
    required this.versionCode,
    required this.url,
    required this.cambios,
    required this.obligatoria,
    required this.minVersionCode,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: json['version'] ?? '0.0.0',
      versionCode: json['versionCode'] ?? 0,
      url: json['url'] ?? '',
      cambios: List<String>.from(json['cambios'] ?? []),
      obligatoria: json['obligatoria'] ?? false,
      minVersionCode: json['minVersionCode'] ?? 0,
    );
  }

  /// ¿Es esta actualización obligatoria para el usuario con [versionCodeActual]?
  bool esObligatoriaPara(int versionCodeActual) {
    if (obligatoria) return true;
    return versionCodeActual < minVersionCode;
  }
}
