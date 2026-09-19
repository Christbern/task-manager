# Task Manager — Test de recrutement

Mini-application de gestion de tâches : inscription/connexion, CRUD de tâches, filtrage et recherche, synchronisation web/mobile via une API commune.

## Structure du monorepo

```
.
├── backend/    # API REST Spring Boot (Java 17, Spring Data JPA, MySQL, JWT)
├── frontend/   # Web React + Vite + TypeScript + Tailwind + Shadcn UI
├── mobile/     # App Flutter (bonus)
└── .github/workflows/   # CI/CD GitHub Actions (build, test, déploiement)
```

Chaque dossier a son propre README avec les instructions détaillées :
- [`backend/README.md`](./backend/README.md)
- [`frontend/README.md`](./frontend/README.md)
- [`mobile/README.md`](./mobile/README.md)
- [`DEPLOYMENT.md`](./DEPLOYMENT.md) — mise en place complète de l'infra GCP et du CI/CD

## Architecture technique

```
┌─────────────┐      ┌─────────────┐      ┌──────────────┐
│  Frontend   │─────▶│   Backend   │─────▶│  Cloud SQL   │
│  (React)    │ HTTP │ (Spring     │ JDBC │  (MySQL)     │
│  Firebase   │ JSON │  Boot, JWT) │      │              │
│  Hosting    │      │  Cloud Run  │      │              │
└─────────────┘      └─────────────┘      └──────────────┘
                             ▲
                             │ même API
                      ┌─────────────┐
                      │   Mobile    │
                      │  (Flutter)  │
                      └─────────────┘
```

**Choix techniques principaux** :
- **JWT stateless** plutôt que sessions : le backend n'a aucun état à partager entre instances, ce qui correspond bien au fonctionnement de Cloud Run (qui peut démarrer/arrêter des instances à tout moment).
- **Isolation des données par utilisateur** vérifiée côté serveur à chaque requête (pas seulement côté client) : un utilisateur ne peut jamais accéder aux tâches d'un autre, même en devinant un ID.
- **Secrets jamais en dur dans le code** : tout passe par des variables d'environnement en local, et par Secret Manager en production (voir `DEPLOYMENT.md`).
- **Cloud SQL via socket Unix** plutôt qu'IP publique : la base n'est jamais exposée sur Internet.

## Lancer le projet en local

```bash
# 1. Backend + MySQL (Docker Compose)
cd backend
docker compose up --build
# API disponible sur http://localhost:8080

# 2. Frontend
cd frontend
npm install
cp .env.example .env
npm run dev
# App disponible sur http://localhost:5173

# 3. Mobile (optionnel)
cd mobile
flutter create . --project-name task_manager_mobile --org com.taskmanager
flutter pub get
flutter run
```

## CI/CD & déploiement

Deux pipelines GitHub Actions (`.github/workflows/`), déclenchés à chaque push sur `main` :
- **`backend-deploy.yml`** : build Maven + tests → build image Docker → push sur Artifact Registry → déploiement Cloud Run
- **`frontend-deploy.yml`** : `npm run build` (vérifie aussi les types TS) → déploiement Firebase Hosting

Les pull requests déclenchent uniquement le build + les tests (pas de déploiement), pour valider le code avant merge.

Mise en place complète de l'infrastructure GCP : voir [`DEPLOYMENT.md`](./DEPLOYMENT.md).

## Liens déployés

_À compléter après déploiement :_
- Frontend : `https://<PROJECT_ID>.web.app`
- Backend (API) : `https://task-manager-backend-xxxxx-ew.a.run.app`

## Captures d'écran

_À ajouter après avoir testé l'app en local ou en prod._
