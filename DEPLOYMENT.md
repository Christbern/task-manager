# Guide de déploiement — GCP + CI/CD

Ce guide suppose que tu as déjà : créé un projet GCP, lié un compte de facturation (crédit d'essai 300$), et que `gcloud` est authentifié dans Cloud Shell (aucune install locale nécessaire — Cloud Shell est accessible directement depuis console.cloud.google.com).

Remplace `PROJECT_ID` par l'ID réel de ton projet (visible en haut de la console GCP) dans toutes les commandes ci-dessous.

## 1. Activer les APIs

```bash
gcloud config set project PROJECT_ID

gcloud services enable \
  run.googleapis.com \
  sqladmin.googleapis.com \
  artifactregistry.googleapis.com \
  secretmanager.googleapis.com
```

## 2. Créer le dépôt Artifact Registry (stockage des images Docker)

```bash
gcloud artifacts repositories create task-manager \
  --repository-format=docker \
  --location=europe-west1
```

## 3. Créer l'instance Cloud SQL

```bash
gcloud sql instances create task-manager-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=europe-west1 \
  --root-password=CHOISIS_UN_MOT_DE_PASSE_FORT

gcloud sql databases create taskmanager --instance=task-manager-db

# Récupère le "Connection name" — tu en auras besoin plus loin (format: PROJECT_ID:europe-west1:task-manager-db)
gcloud sql instances describe task-manager-db --format="value(connectionName)"
```

## 4. Stocker les secrets sensibles dans Secret Manager

Plutôt que de mettre le mot de passe DB et le secret JWT en clair dans la config Cloud Run, on les stocke dans Secret Manager (le workflow GitHub Actions les référence déjà via `--set-secrets`).

```bash
echo -n "CHOISIS_UN_MOT_DE_PASSE_FORT" | gcloud secrets create DB_PASSWORD --data-file=-

# Génère un secret JWT aléatoire de 32+ caractères
openssl rand -base64 32 | gcloud secrets create JWT_SECRET --data-file=-
```

## 5. Créer le Service Account utilisé par GitHub Actions

```bash
gcloud iam service-accounts create github-actions-deployer \
  --display-name="GitHub Actions Deployer"

SA_EMAIL="github-actions-deployer@PROJECT_ID.iam.gserviceaccount.com"

# Droit de déployer sur Cloud Run
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" --role="roles/run.admin"

# Droit de pousser des images sur Artifact Registry
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" --role="roles/artifactregistry.writer"

# Droit d'agir "en tant que" le service Cloud Run au déploiement
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" --role="roles/iam.serviceAccountUser"

# Droit de lire les secrets (DB_PASSWORD, JWT_SECRET)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" --role="roles/secretmanager.secretAccessor"

# Droit de se connecter à Cloud SQL (nécessaire au runtime Cloud Run, pas juste au déploiement)
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="serviceAccount:$SA_EMAIL" --role="roles/cloudsql.client"

# Génère la clé JSON à mettre dans les secrets GitHub (fichier sensible, à ne jamais committer)
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account="$SA_EMAIL"
```

## 6. Créer un projet Firebase (pour héberger le frontend)

Sur [console.firebase.google.com](https://console.firebase.google.com), clique "Ajouter un projet" et **sélectionne ton projet GCP existant** (`PROJECT_ID`) plutôt que d'en créer un nouveau — Firebase Hosting sera alors lié au même projet.

Génère ensuite une clé de service dédiée pour le déploiement automatique :
```bash
firebase init hosting   # à lancer une fois en local ou via Cloud Shell, pour lier le dossier frontend/
```
Ou plus simple : dans la console Firebase → Paramètres du projet → Comptes de service → "Générer une nouvelle clé privée". C'est ce JSON qui va dans le secret `FIREBASE_SERVICE_ACCOUNT` (étape suivante).

N'oublie pas de mettre à jour `frontend/.firebaserc` avec ton vrai `PROJECT_ID`.

## 7. Configurer les secrets GitHub

Dans ton repo GitHub → Settings → Secrets and variables → Actions, ajoute :

| Secret | Valeur |
|---|---|
| `GCP_PROJECT_ID` | Ton project ID GCP |
| `GCP_SA_KEY` | Le contenu complet du fichier `github-actions-key.json` (étape 5) |
| `INSTANCE_CONNECTION_NAME` | Le "Connection name" récupéré à l'étape 3 |
| `DB_USERNAME` | `root` (ou un utilisateur dédié si tu préfères) |
| `FRONTEND_URL` | L'URL Firebase Hosting (tu l'auras après le 1er déploiement frontend, ex: `https://PROJECT_ID.web.app`) |
| `BACKEND_URL` | L'URL Cloud Run du backend (tu l'auras après le 1er déploiement backend) |
| `FIREBASE_SERVICE_ACCOUNT` | Le contenu JSON de la clé de service Firebase (étape 6) |

**⚠️ Ordre de déploiement au premier lancement** : `FRONTEND_URL` et `BACKEND_URL` dépendent l'un de l'autre (CORS côté backend, `VITE_API_URL` côté frontend), mais tu ne les connais qu'après un premier déploiement. Solution simple : déploie le backend une première fois avec une valeur `FRONTEND_URL` provisoire (ex: `http://localhost:5173`), récupère l'URL Cloud Run générée, mets-la dans `BACKEND_URL`, déploie le frontend, récupère son URL, puis mets-la à jour dans `FRONTEND_URL` et redéclenche le déploiement backend.

## 8. Pousser sur `main`

```bash
git add .
git commit -m "CI/CD: déploiement Cloud Run + Firebase Hosting"
git push origin main
```

Les deux workflows (`backend-deploy.yml`, `frontend-deploy.yml`) se déclenchent automatiquement — visible dans l'onglet "Actions" du repo GitHub.

## 9. ⚠️ Nettoyage après évaluation du test (important)

Cloud Run et Firebase Hosting restent gratuits en permanence. **Cloud SQL, lui, continue de facturer même sans trafic** une fois le crédit d'essai épuisé. Une fois le test évalué par le recruteur, supprime l'instance pour éviter tout risque :

```bash
gcloud sql instances delete task-manager-db
```

Tu peux vérifier ta consommation de crédit à tout moment sur console.cloud.google.com → Billing.
