# Task Manager — Frontend (React + Vite + TSX)

## Stack
- React 18 + Vite + TypeScript
- Tailwind CSS + composants style Shadcn UI (Button, Input, Card, Badge, Select, Textarea)
- React Router pour la navigation
- Axios avec injection automatique du JWT

## Lancer en local

```bash
npm install
cp .env.example .env   # ajuster VITE_API_URL si besoin
npm run dev
```

L'app tourne sur `http://localhost:5173` et attend le backend sur `http://localhost:8080` (voir le README du backend).

## Fonctionnalités
- Inscription / connexion (JWT stocké en `localStorage`, injecté sur chaque requête API)
- Déconnexion automatique si le token est invalide/expiré (intercepteur Axios sur les 401)
- Liste des tâches avec recherche texte + filtre par statut (debounce 300ms pour ne pas spammer l'API)
- Création, édition, suppression de tâches
- Gestion des erreurs API (messages affichés dans l'UI)

## Build production

```bash
npm run build
```

Génère `dist/` (fichiers statiques), servis ensuite via Nginx dans le `Dockerfile`.
