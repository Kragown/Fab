# Fab - Application de Gestion de Decklists

Application iOS native développée avec SwiftUI pour la gestion de decklists de jeu de cartes.

## 🚀 Fonctionnalités

### 🔐 Authentification

- **Connexion** : Connexion sécurisée avec email et mot de passe
- **Inscription** : Création de compte avec email, mot de passe et nom d'utilisateur
- **Gestion de session** : Connexion automatique et déconnexion
- **Profil utilisateur** : Affichage du profil avec nom d'utilisateur et email
- **Synchronisation** : Toutes les données sont synchronisées avec Firebase pour l'utilisateur connecté

### 📋 Gestion des Decklists

#### Liste des Decklists
- **Affichage** : Liste complète de toutes vos decklists
- **Tri automatique** : Les decklists sont triées par date (plus récentes en premier)
- **Filtrage par format** : Filtrez les decklists par format de jeu :
  - Classic Constructed
  - Living Legend
  - Silver Age
- **Filtrage par héros** : Filtrez les decklists par héros sélectionné
- **Combinaison de filtres** : Utilisez les deux filtres simultanément
- **Navigation** : Appuyez sur une decklist pour voir ses détails

#### Création de Decklist
- **Modal d'ajout** : Bouton flottant (+) pour créer une nouvelle decklist
- **Formulaire complet** :
  - Titre de la decklist
  - Sélection du héros (avec images)
  - Choix du format de jeu
  - Date de création
- **Validation** : Vérification que tous les champs requis sont remplis
- **Feedback** : Messages d'erreur en cas de problème

#### Modification de Decklist
- **Mode édition** : Bouton "Modifier" dans l'écran de détails
- **Édition inline** : Modification directe de tous les champs :
  - Titre
  - Héros
  - Format
  - Date
- **Sauvegarde** : Synchronisation automatique avec le backend
- **Annulation** : Retour au mode affichage sans sauvegarder

#### Suppression de Decklist
- **Long press** : Maintenez appuyé sur une decklist dans la liste
- **Confirmation** : Popup de confirmation avant suppression
- **Sécurité** : Message d'avertissement indiquant que l'action est irréversible
- **Synchronisation** : Suppression immédiate dans le backend

#### Détails de Decklist
- **Affichage complet** : Toutes les informations de la decklist
- **Image du héros** : Affichage de l'image du héros associé
- **Informations détaillées** :
  - Titre
  - Nom et classe du héros
  - Format de jeu
  - Date de création
- **Actions** : Boutons pour modifier ou supprimer

### 🦸 Gestion des Héros

- **Catalogue complet** : Liste de tous les héros disponibles
- **Images** : Affichage des images des héros depuis Firebase Storage
- **Tri alphabétique** : Héros triés par nom
- **Informations** : Nom et classe de chaque héros
- **Synchronisation** : Chargement automatique depuis Firebase

### 🎨 Personnalisation

#### Thème
- **Mode sombre** : Activation/désactivation du mode sombre
- **Persistance** : Préférence sauvegardée avec UserDefaults
- **Application immédiate** : Changement de thème en temps réel

#### Paramètres
- **Section Notifications** : Toggle pour activer/désactiver les notifications
- **Section Apparence** : Contrôle du mode sombre
- **Informations** : Version de l'application

### 📊 Profil Utilisateur

- **Statistiques** : Nombre total de decklists créées
- **Informations personnelles** :
  - Nom d'utilisateur
  - Adresse email
  - Avatar (icône par défaut)
- **Déconnexion** : Bouton pour se déconnecter

### 🧭 Navigation

- **Tab Bar** : Navigation principale avec 3 onglets :
  - Liste des decklists
  - Profil utilisateur
  - Paramètres
- **Navigation hiérarchique** : Navigation entre liste et détails
- **Transitions animées** : Animations fluides entre les écrans
- **Modals** : Présentation modale pour l'ajout de decklists

### 💾 Stockage et Synchronisation

- **Backend Firebase** : Synchronisation en temps réel avec Firebase Firestore
- **Stockage local** : UserDefaults pour les préférences utilisateur (thème)
- **Écoute en temps réel** : Mise à jour automatique des decklists
- **Sécurité** : Données associées à l'utilisateur connecté uniquement

### 🎯 Interface Utilisateur

- **Design moderne** : Interface SwiftUI native et élégante
- **Animations** : Transitions fluides et animations de printemps
- **Feedback visuel** : Indicateurs de chargement et messages d'erreur
- **Accessibilité** : Utilisation des composants natifs iOS
- **Responsive** : Adaptation à différentes tailles d'écran

### 🔔 Notifications

- **Paramètres** : Section dédiée dans les paramètres
- **Toggle** : Activation/désactivation des notifications

## 📱 Écrans

1. **Écran de Connexion/Inscription** : Authentification utilisateur
2. **Écran de Liste** : Liste des decklists avec filtres
3. **Écran de Détails** : Détails complets d'une decklist
4. **Modal d'Ajout** : Formulaire de création de decklist
5. **Écran de Profil** : Informations utilisateur et statistiques
6. **Écran de Paramètres** : Configuration de l'application

## 🛠️ Technologies

- **SwiftUI** : Framework d'interface utilisateur
- **Firebase Authentication** : Authentification utilisateur
- **Firebase Firestore** : Base de données en temps réel
- **Firebase Storage** : Stockage des images des héros
- **UserDefaults** : Stockage local des préférences
- **Combine** : Gestion réactive des données

## 📦 Structure du Projet

```
Fab/
├── Models/
│   ├── Decklist.swift      # Modèle de données decklist
│   └── Hero.swift          # Modèle de données héros
├── Services/
│   ├── AuthService.swift   # Service d'authentification
│   ├── DecklistService.swift # Service de gestion des decklists
│   ├── HeroService.swift   # Service de gestion des héros
│   └── ThemeService.swift  # Service de gestion du thème
└── Views/
    ├── ContentView.swift    # Écran de liste
    ├── DecklistDetailView.swift # Écran de détails
    ├── NewDecklistView.swift # Modal d'ajout
    ├── LoginView.swift     # Écran d'authentification
    ├── ProfileView.swift   # Écran de profil
    ├── SettingsView.swift  # Écran de paramètres
    ├── MainTabView.swift   # Navigation principale
    └── RootView.swift      # Vue racine
```

## 🎮 Formats de Jeu Supportés

- **Classic Constructed** : Format classique
- **Living Legend** : Format Living Legend
- **Silver Age** : Format Silver Age

## ✨ Expérience Utilisateur

- **Feedback immédiat** : Confirmations et messages d'erreur clairs
- **Animations fluides** : Transitions et animations de printemps
- **Interface intuitive** : Navigation logique et cohérente
- **Design épuré** : Interface simple et claire
- **Performance** : Chargement optimisé des images et données
