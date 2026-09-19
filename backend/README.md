# Task Manager — Backend (Spring Boot)

API REST pour la gestion de tâches, avec authentification JWT.

## Stack
- Java 17, Spring Boot 3.3
- Spring Data JPA + MySQL
- Spring Security + JWT (jjwt)
- Lombok, Bean Validation

## Lancer en local (Docker Compose — recommandé)

```bash
docker compose up --build
```

Cela démarre MySQL + le backend. L'API est disponible sur `http://localhost:8080`.

## Lancer en local sans Docker

1. Démarrer une instance MySQL locale, créer la base `taskmanager`.
2. Exporter les variables d'environnement (ou éditer `application.properties`) :
   ```bash
   export DB_URL=jdbc:mysql://localhost:3306/taskmanager
   export DB_USERNAME=root
   export DB_PASSWORD=root
   export JWT_SECRET=un-secret-d-au-moins-32-caracteres
   ```
3. `mvn spring-boot:run`

## Endpoints

| Méthode | URL | Description | Auth requise |
|---|---|---|---|
| POST | `/api/auth/register` | Inscription | Non |
| POST | `/api/auth/login` | Connexion (retourne un JWT) | Non |
| GET | `/api/tasks?status=&search=` | Liste des tâches (filtrage/recherche) | Oui |
| POST | `/api/tasks` | Créer une tâche | Oui |
| PUT | `/api/tasks/{id}` | Modifier une tâche | Oui |
| DELETE | `/api/tasks/{id}` | Supprimer une tâche | Oui |

Pour les routes protégées, envoyer l'en-tête :
```
Authorization: Bearer <token>
```

## Sécurité — points clés
- Mots de passe hashés en BCrypt (jamais en clair).
- Chaque tâche est liée à un `user_id` : un utilisateur ne peut jamais lire/modifier les tâches d'un autre (vérifié côté serveur, pas seulement côté client).
- Le secret JWT et les identifiants MySQL viennent de variables d'environnement — **rien n'est en dur dans le code** pour la prod.
- CORS restreint à l'origine du frontend (configurable via `CORS_ALLOWED_ORIGINS`).

## Variables d'environnement (production)

| Variable | Description |
|---|---|
| `DB_URL` | URL JDBC MySQL (ex: Cloud SQL) |
| `DB_USERNAME` / `DB_PASSWORD` | Identifiants MySQL |
| `JWT_SECRET` | Secret de signature JWT (min. 32 caractères, aléatoire) |
| `CORS_ALLOWED_ORIGINS` | URL du frontend déployé |
| `PORT` | Injecté automatiquement par Cloud Run |
