# EKLEZYA — Application Catholique Mobile

Application mobile catholique pour Android et iOS, conçue avec Flutter. Inspirée de YouVersion, EKLEZYA propose une Bible catholique complète (73 livres), des prières guidées, un calendrier liturgique, un compagnon IA théologique et la découverte des saints du jour.

---

## Table des matières

1. [Prérequis](#prérequis)
2. [Installation](#installation)
3. [Configuration Firebase](#configuration-firebase)
4. [Configuration OpenAI](#configuration-openai)
5. [Lancement](#lancement)
6. [Architecture](#architecture)
7. [Structure des fichiers](#structure-des-fichiers)
8. [Fonctionnalités](#fonctionnalités)
9. [Déploiement](#déploiement)

---

## Prérequis

- **Flutter 3.16+** — [Installer Flutter](https://docs.flutter.dev/get-started/install)
- **Dart 3.2+** (inclus avec Flutter)
- **Android Studio** ou **VS Code** avec les extensions Flutter/Dart
- Un projet **Firebase** (voir section Configuration Firebase)
- Une clé API **OpenAI** avec accès à GPT-4o
- **CocoaPods** (pour iOS) : `sudo gem install cocoapods`

Vérifiez votre environnement :

```bash
flutter doctor -v
```

---

## Installation

### 1. Cloner le dépôt

```bash
git clone https://github.com/votre-org/eklezya.git
cd eklezya
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Générer le code Freezed/Riverpod (si nécessaire)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Installer les pods iOS

```bash
cd ios
pod install
cd ..
```

---

## Configuration Firebase

### Créer le projet Firebase

1. Allez sur [console.firebase.google.com](https://console.firebase.google.com)
2. Créez un nouveau projet nommé **eklezya-prod** (ou similaire)
3. Activez les services suivants :
   - **Authentication** : Email/Password, Google Sign-In, Sign in with Apple
   - **Firestore Database** : mode Production
   - **Storage**
   - **Cloud Messaging (FCM)**
   - **Analytics**

### Configurer FlutterFire CLI

```bash
# Installer FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurer automatiquement les fichiers Firebase
flutterfire configure --project=votre-projet-firebase
```

Cette commande génère :
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- `ios/Runner/GoogleService-Info.plist`

### Règles Firestore

Copiez ces règles dans la console Firebase → Firestore → Règles :

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Utilisateurs : lecture/écriture par l'utilisateur lui-même
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /highlights/{doc} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /favorite_verses/{doc} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /verse_notes/{doc} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      match /ai_conversations/{doc} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Contenu public (lecture seule pour utilisateurs authentifiés)
    match /saints/{doc} {
      allow read: if request.auth != null;
      allow write: if false; // Admin seulement
    }
    match /prayers/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /liturgical_calendar/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /bible/{translation=**} {
      allow read: if request.auth != null;
      allow write: if false;
    }
    match /verse_of_day/{doc} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## Configuration OpenAI

### Obtenir une clé API

1. Créez un compte sur [platform.openai.com](https://platform.openai.com)
2. Générez une clé API dans **API Keys**
3. Assurez-vous d'avoir accès au modèle `gpt-4o`

### Utiliser la clé

La clé API est transmise via `--dart-define` (ne jamais la committer dans le code) :

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-votre-clé-ici
```

Pour le développement, créez un fichier `.env` (gitignore) et utilisez un script de lancement :

```bash
# .env (ne pas committer)
OPENAI_API_KEY=sk-votre-clé-ici
```

```bash
# scripts/run_dev.sh
#!/bin/bash
source .env
flutter run --dart-define=OPENAI_API_KEY=$OPENAI_API_KEY
```

---

## Lancement

### Mode développement (Android)

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-... -d android
```

### Mode développement (iOS)

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-... -d ios
```

### Avec flavor dev

```bash
flutter run --flavor dev --dart-define=OPENAI_API_KEY=sk-... -t lib/main.dart
```

### Build release Android (APK)

```bash
flutter build apk --release --flavor prod --dart-define=OPENAI_API_KEY=sk-...
```

### Build release Android (App Bundle pour Play Store)

```bash
flutter build appbundle --release --flavor prod --dart-define=OPENAI_API_KEY=sk-...
```

### Build release iOS

```bash
flutter build ios --release --flavor prod --dart-define=OPENAI_API_KEY=sk-...
```

---

## Architecture

EKLEZYA suit la **Clean Architecture** avec trois couches :

```
lib/
├── core/                    # Constantes, utilitaires, routeur
│   ├── constants/           # Couleurs, styles de texte
│   ├── router/              # GoRouter avec authentification
│   └── utils/               # Calculateur liturgique (algorithme Méeus)
│
├── domain/                  # Couche métier (aucune dépendance externe)
│   ├── entities/            # Modèles immuables (BibleVerse, Prayer, Saint…)
│   ├── repositories/        # Interfaces abstraites
│   └── usecases/            # Cas d'utilisation (un par action métier)
│
├── data/                    # Implémentations concrètes
│   ├── models/              # Modèles JSON/Hive (étendent les entités)
│   ├── datasources/         # Firebase, OpenAI, Hive
│   └── repositories/        # Implémentations des interfaces
│
└── presentation/            # UI Flutter
    ├── providers/            # Riverpod (state management)
    ├── screens/              # Écrans par fonctionnalité
    ├── widgets/              # Composants réutilisables
    └── theme/               # Thème Material 3
```

### Flux de données

```
UI (Screen) → Provider (Riverpod) → UseCase → Repository Interface
                                                      ↓
                                          Repository Implementation
                                                      ↓
                                          DataSource (Firebase/Hive/OpenAI)
```

---

## Structure des fichiers

```
eklezya/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── utils/
│   │       └── liturgy_calculator.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── bible_verse.dart
│   │   │   ├── prayer.dart
│   │   │   ├── saint.dart
│   │   │   ├── liturgical_day.dart
│   │   │   ├── user_profile.dart
│   │   │   └── ai_message.dart
│   │   ├── repositories/
│   │   │   ├── bible_repository.dart
│   │   │   ├── prayer_repository.dart
│   │   │   ├── saint_repository.dart
│   │   │   ├── liturgy_repository.dart
│   │   │   ├── ai_repository.dart
│   │   │   └── auth_repository.dart
│   │   └── usecases/
│   │       ├── bible/
│   │       │   ├── get_chapter.dart
│   │       │   ├── search_bible.dart
│   │       │   └── highlight_verse.dart
│   │       ├── prayers/
│   │       │   └── get_prayers_by_category.dart
│   │       ├── liturgy/
│   │       │   └── get_liturgical_day.dart
│   │       ├── saints/
│   │       │   └── get_saint_of_day.dart
│   │       ├── ai/
│   │       │   └── send_ai_message.dart
│   │       └── auth/
│   │           └── sign_in_with_google.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── bible_verse_model.dart
│   │   │   ├── prayer_model.dart
│   │   │   ├── saint_model.dart
│   │   │   └── liturgical_day_model.dart
│   │   ├── datasources/
│   │   │   ├── firebase_bible_datasource.dart
│   │   │   ├── firebase_saints_datasource.dart
│   │   │   ├── firebase_liturgy_datasource.dart
│   │   │   ├── openai_datasource.dart
│   │   │   └── local_bible_datasource.dart
│   │   └── repositories/
│   │       ├── bible_repository_impl.dart
│   │       ├── saint_repository_impl.dart
│   │       ├── liturgy_repository_impl.dart
│   │       ├── ai_repository_impl.dart
│   │       └── auth_repository_impl.dart
│   ├── presentation/
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   ├── bible_provider.dart
│   │   │   ├── liturgy_provider.dart
│   │   │   ├── saints_provider.dart
│   │   │   ├── ai_provider.dart
│   │   │   └── prayer_provider.dart
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   ├── onboarding/
│   │   │   ├── auth/
│   │   │   ├── home/
│   │   │   ├── bible/
│   │   │   ├── prayers/
│   │   │   ├── liturgy/
│   │   │   ├── saints/
│   │   │   ├── ai/
│   │   │   └── profile/
│   │   └── widgets/
│   │       ├── verse_card.dart
│   │       ├── saint_card.dart
│   │       ├── liturgical_color_badge.dart
│   │       ├── prayer_card.dart
│   │       ├── ai_message_bubble.dart
│   │       └── streak_display.dart
│   └── l10n/
│       ├── app_fr.arb
│       └── app_en.arb
├── assets/
│   └── data/
│       ├── prayers_seed.json
│       ├── saints_seed.json
│       └── liturgical_calendar_2026.json
├── android/
│   └── app/
│       └── build.gradle
└── pubspec.yaml
```

---

## Fonctionnalités

### Bible catholique
- 73 livres (46 AT incluant les deutérocanoniques, 27 NT)
- Lecture par livre/chapitre
- Recherche plein texte
- Surlignage (5 couleurs) et favoris
- Notes personnelles par verset
- Verset du jour
- Cache hors ligne via Hive

### Prières guidées
- 20+ prières catholiques complètes (FR + EN)
- Timer de prière avec contrôles play/pause
- Chapelet complet avec les 4 mystères
- Prières du matin et du soir
- Favoris et historique

### Calendrier liturgique
- Calcul local de Pâques (algorithme de Méeus/Jones/Butcher)
- Toutes les fêtes mobiles calculées en Dart (sans réseau)
- Couleurs liturgiques : vert, violet, blanc, rouge, rose, noir
- Lectures du jour depuis Firebase (enrichissement)
- Vue calendaire mensuelle avec `table_calendar`

### Saints du jour
- Biographies complètes FR + EN
- Photos des saints
- Prières et citations
- Patronages et informations biographiques
- Recherche et filtrage par catégorie

### Compagnon IA (EKLEZYA IA)
- Basé sur GPT-4o
- Spécialisé en théologie catholique
- Réponses en streaming (affichage token par token)
- Rendu Markdown avec style liturgique
- Historique des conversations (Firestore)
- Système de prompt complet en FR et EN

### Profil & Suivi
- Authentification : Google, Apple, Email/Password
- Série de prière (streak) avec jalons
- Statistiques : versets lus, prières, jours actifs
- Badges de fidélité
- Abonnement Premium (préparé)

---

## Déploiement

### Android — Google Play Store

1. Créez un keystore :
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

2. Créez `android/key.properties` (ne pas committer) :
```
storePassword=votre-mot-de-passe
keyPassword=votre-mot-de-passe
keyAlias=upload
storeFile=/Users/vous/upload-keystore.jks
```

3. Build :
```bash
flutter build appbundle --release --flavor prod \
  --dart-define=OPENAI_API_KEY=sk-...
```

4. Uploadez `build/app/outputs/bundle/prodRelease/app-prod-release.aab` sur la Play Console.

### iOS — App Store

1. Configurez votre profil de distribution dans Xcode
2. Build :
```bash
flutter build ios --release --flavor prod \
  --dart-define=OPENAI_API_KEY=sk-...
```
3. Ouvrez `ios/Runner.xcworkspace` dans Xcode et archivez.

---

## Variables d'environnement

| Variable | Description | Requis |
|----------|-------------|--------|
| `OPENAI_API_KEY` | Clé API OpenAI (GPT-4o) | Oui |

Transmises via `--dart-define=NOM=valeur` au moment du build.

---

## Contribution

1. Forkez le dépôt
2. Créez une branche : `git checkout -b feature/ma-fonctionnalite`
3. Committez : `git commit -m "feat: description"`
4. Poussez : `git push origin feature/ma-fonctionnalite`
5. Ouvrez une Pull Request

### Conventions de commit

- `feat:` — nouvelle fonctionnalité
- `fix:` — correction de bug
- `refactor:` — refactorisation sans changement de comportement
- `docs:` — documentation uniquement
- `test:` — ajout ou modification de tests
- `chore:` — tâches de maintenance

---

## Licence

Copyright © 2026 EKLEZYA. Tous droits réservés.

---

*Développé avec ❤️ pour la communauté catholique francophone.*
