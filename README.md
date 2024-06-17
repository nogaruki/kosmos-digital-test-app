Voici une version en français du fichier README pour votre projet :

---

# Projet Kosmos digital app test
Application test pour l'entreprise Kosmos digital



## Table des matières

- [Fonctionnalités](#fonctionnalités)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Tests](#tests)
- 
## Fonctionnalités

- Authentification utilisateur (Firebase Auth)
- Base de données en temps réel (Firestore)
- Téléchargement d'images (Firebase Storage)
- Gestion de profil
- Création et suppression de posts
- Notifications et alertes
- Polices personnalisées et thématisation

## Installation

1. **Cloner le dépôt :**

   ```sh
   git clone https://github.com/yourusername/projet_kosmos.git
   cd projet_kosmos
   ```

2. **Installer les dépendances :**

   ```sh
   flutter pub get
   ```

3. **Configurer Firebase :**

   Assurez-vous d'avoir configuré un projet Firebase. Téléchargez les fichiers `google-services.json` (pour Android) et `GoogleService-Info.plist` (pour iOS) et placez-les dans leurs répertoires respectifs.

4. **Exécuter l'application :**

   ```sh
   flutter run
   ```

## Utilisation

### Principales fonctionnalités

- **Authentification :** Les utilisateurs peuvent s'inscrire et se connecter avec leur email et mot de passe.
- **Gestion de profil :** Les utilisateurs peuvent consulter et modifier leurs informations de profil.
- **Création de posts :** Les utilisateurs peuvent créer, consulter et supprimer des posts avec des images.
- **Notifications :** Notifications en temps réel utilisant Flushbar pour diverses actions telles que la création de posts, la suppression et la gestion des erreurs.


## Tests

L'application a été testée sur le dispositif suivant :

- **Appareil :** Pixel 3a
- **Niveau API :** 34
- **Niveau d'extension :** 7
- **Architecture :** x86 64 (mobile)
