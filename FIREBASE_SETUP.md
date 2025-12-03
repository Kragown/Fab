# Configuration Firebase

## Fichier GoogleService-Info.plist

Le fichier `GoogleService-Info.plist` contient des informations sensibles et n'est **pas versionné** dans ce dépôt pour des raisons de sécurité.

### Comment obtenir le fichier

1. Accédez à la [Console Firebase](https://console.firebase.google.com/)
2. Sélectionnez votre projet : `fab-firebase-3ae31`
3. Cliquez sur l'icône d'engrenage ⚙️ à côté de "Project Overview"
4. Sélectionnez "Project settings"
5. Allez dans l'onglet "General"
6. Dans la section "Your apps", trouvez votre application iOS
7. Téléchargez le fichier `GoogleService-Info.plist`
8. Placez-le dans le dossier `Fab/` à la racine du projet

### Alternative : Utiliser le template

Vous pouvez également copier `GoogleService-Info.plist.template` vers `GoogleService-Info.plist` et remplacer les valeurs placeholder par vos vraies valeurs depuis la Console Firebase.

### Sécurité

⚠️ **Important** : Même si les clés Firebase sont techniquement "publiques" côté client, il est recommandé de :

1. Configurer des restrictions d'API dans la [Console Google Cloud](https://console.cloud.google.com/)
2. Limiter l'utilisation de la clé API par domaine/IP
3. Surveiller l'utilisation de la clé API pour détecter tout usage suspect

Si votre clé API a été exposée publiquement, vous devriez :
- La révoquer dans la Console Google Cloud
- Générer une nouvelle clé API avec des restrictions appropriées
- Mettre à jour le fichier `GoogleService-Info.plist` avec la nouvelle clé

