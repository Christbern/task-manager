# Task Manager — Mobile (Flutter)

Reproduit l'essentiel de l'interface web : connexion via l'API Spring Boot (même JWT), liste et gestion des tâches.

## ⚠️ Étape indispensable avant de lancer le projet

Ce dossier contient uniquement le code Dart (`lib/`) et `pubspec.yaml`. Les dossiers `android/`, `ios/` (spécifiques à chaque plateforme, générés par Flutter) **ne sont pas inclus** — ils dépendent de ta version exacte du SDK Flutter installée, donc c'est plus fiable de les régénérer chez toi :

```bash
cd mobile
flutter create . --project-name task_manager_mobile --org com.taskmanager
flutter pub get
```

Cela ajoute les dossiers `android/`, `ios/` sans toucher à `lib/`.

### Autoriser l'accès réseau (important, souvent oublié)

Après `flutter create .`, ajoute la permission Internet dans `android/app/src/main/AndroidManifest.xml` (juste avant `<application`) :
```xml
<uses-permission android:name="android.permission.INTERNET" />
```
(Sur iOS, l'accès réseau en HTTP local nécessite d'autoriser App Transport Security en dev — voir la doc Flutter si tu testes sur un vrai iPhone plutôt que le simulateur.)

## Lancer l'app

```bash
# Émulateur Android : localhost de ta machine = 10.0.2.2 (déjà la valeur par défaut)
flutter run

# Simulateur iOS ou desktop : redéfinir l'URL
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

Le backend (`../backend`) doit tourner en parallèle (`docker compose up`).

## Stack
- Flutter + Dart
- `dio` pour les appels HTTP (avec intercepteur JWT, comme côté web)
- `provider` pour l'état d'authentification global
- `shared_preferences` pour stocker le token/l'utilisateur localement

## Fonctionnalités
- Connexion / inscription, session restaurée automatiquement au redémarrage de l'app
- Déconnexion automatique si le token expire (même logique 401 que le frontend web)
- Liste des tâches (`ListView`) avec recherche (`TextField`, debounce 300ms) et filtre par statut
- Créer/éditer une tâche via un formulaire en bottom sheet (`TextField` + `ElevatedButton`)
- Supprimer une tâche avec confirmation
