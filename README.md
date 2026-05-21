# Ch'ti Face Bouc

**Ch'ti Face Bouc** est une application mobile de reseau social hyper-locale concue pour connecter les habitants des Hauts-de-France. Elle melange le partage social classique (photos, statuts) avec des fonctionnalites ancrees dans la culture du Nord : entraide entre voisins, expressions picardes et convivialite ch'ti.

## Fonctionnalites

- **Authentification** : Inscription et connexion par email/mot de passe via Firebase Auth, avec messages d'erreur en francais (email invalide, compte existant, mot de passe trop faible, etc.)
- **Fil d'actualite** : Affichage de tous les posts de la communaute, tries du plus recent au plus ancien
- **Ecriture de posts** : Publication de textes et/ou photos (galerie ou appareil photo)
- **Profil utilisateur** : Photo de profil, photo de couverture, description personnalisable
- **Liste des membres** : Consultation de tous les membres du reseau et acces a leur profil
- **Likes** : Systeme de "Vindidi !" pour aimer les posts
- **Commentaires** : Ajout et lecture de commentaires sur chaque post
- **Notifications** : Notifications internes pour les commentaires et les likes sur vos publications
- **Gestion de compte** : Modification du profil, deconnexion et suppression de compte (Auth + Firestore)

## Technologies

| Technologie | Usage |
|---|---|
| **Flutter** | Framework UI multi-plateforme |
| **Dart** | Langage de programmation |
| **Firebase Auth** | Authentification des utilisateurs |
| **Cloud Firestore** | Base de donnees temps reel |
| **Firebase Storage** | Stockage des images |
| **image_picker** | Selection de photos (galerie/camera) |
| **intl** | Formatage des dates |

## Architecture du projet

```
lib/
  modeles/                          # Modeles de donnees
    commentaire.dart                  Modele commentaire
    constantes.dart                   Cles Firestore (collections, champs)
    donnees.dart                      Donnees complementaires
    membre.dart                       Modele utilisateur
    notif.dart                        Modele notification
    post.dart                         Modele publication
  pages/                            # Pages de l'application
    page_accueil.dart                 Fil d'actualite
    page_application1.dart            Page de base
    page_authentification.dart        Connexion / Inscription
    page_detail_post.dart             Detail d'un post + commentaires
    page_ecrire_post.dart             Ecriture d'un nouveau post
    page_membres.dart                 Liste de tous les membres
    page_modifier_profil.dart         Modification du profil, deconnexion, suppression de compte
    page_navigation.dart              Navigation principale (5 onglets)
    page_notif.dart                   Liste des notifications
    page_profil.dart                  Profil utilisateur + ses posts
  services_firebase/                # Services d'acces a Firebase
    service_authentification.dart     Auth (signIn, createAccount, signOut, deleteAccount)
    service_firestore.dart            CRUD Firestore (membres, posts, likes, notifications, ...)
    service_storage.dart              Upload d'images vers Firebase Storage
  widgets/                          # Widgets reutilisables
    avatar.dart                       Image de profil circulaire
    bouton_camera.dart                Bouton de prise/selection de photo
    contenu_post.dart                 Contenu visuel d'un post
    entete_membre.dart                En-tete avec avatar + nom + date
    formatage_date.dart               Formatage intelligent des dates
    liste_commentaire.dart            Liste des commentaires d'un post
    style_champ_texte.dart            Style pour les champs de saisie
    widget_notif.dart                 Affichage d'une notification
    widget_post.dart                  Affichage d'un post complet
    widget_vide.dart                  Widgets placeholder (vide/chargement)
  firebase_options.dart             # Configuration Firebase (non versionne)
  main.dart                         # Point d'entree de l'application
```

## Prerequisites

- Flutter SDK >= 3.11.1
- Dart SDK >= 3.11.1
- Un projet Firebase configure avec :
  - **Authentication** (fournisseur Email/Mot de passe)
  - **Cloud Firestore** (mode production, region europe)
  - **Storage**
- Compte Firebase avec les applications Android et/ou iOS enregistrees

## Installation

1. **Cloner le depot**
   ```bash
   git clone https://github.com/mathismr/chti_face_bouc.git
   cd chti_face_bouc
   ```

2. **Configurer Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project=<votre-project-id>
   ```
   Cela genere le fichier `lib/firebase_options.dart`.

3. **Installer les dependances**
   ```bash
   flutter pub get
   ```

4. **Configurer les regles Firestore**
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

5. **Configurer les regles Storage**
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /{allPaths=**} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

6. **Creer l'index composite Firestore**
   - Collection : `posts`
   - Champ 1 : `memberID` (Croissant)
   - Champ 2 : `date` (Decroissant)

7. **Lancer l'application**
   ```bash
   flutter run
   ```

## Configuration iOS

Pour utiliser la camera et la galerie photo sur iOS, les permissions suivantes sont configurees dans `ios/Runner/Info.plist` :

- `NSCameraUsageDescription` : Acces a la camera
- `NSPhotoLibraryUsageDescription` : Acces a la galerie photo

> **Note** : Le simulateur iOS ne supporte pas la camera. Utilisez la galerie ou un appareil physique pour tester cette fonctionnalite.

## Auteur

Projet realise dans le cadre du module **"Developpement d'une application mobile"** a **IMT Nord Europe**.
