/// URL de base de l'API backend.
///
/// Se définit au lancement/build via --dart-define, ex :
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
///
/// Valeur par défaut : 10.0.2.2 est l'alias de "localhost" de la machine hôte
/// vu depuis un émulateur Android (localhost sur l'émulateur pointerait vers
/// l'émulateur lui-même, pas vers ta machine).
/// Sur iOS Simulator ou en desktop, utilise plutôt http://localhost:8080.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
