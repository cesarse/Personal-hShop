# Assistance Personal hShop

[English](SUPPORT.md) · [Deutsch](SUPPORT-de.md) · [Español](SUPPORT-es.md) · **Français** · [Italiano](SUPPORT-it.md) · [Português (Brasil)](SUPPORT-pt-BR.md)

_Cette traduction est fournie à titre indicatif. En cas de divergence avec la [version anglaise](SUPPORT.md), la version anglaise prévaut._

## Contact

E-mail : [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Prise en main

1. Choisissez **Personal hShop › Réglages…**, cliquez sur **Choisir un dossier…** et sélectionnez le dossier qui contient vos fichiers .cia.
2. Choisissez **Fichier › Démarrer le serveur**.
3. Ouvrez http://localhost:1234 (ou le port défini dans les réglages) dans un navigateur sur votre Mac, ou activez **Ouvrir la page automatiquement au démarrage du serveur** dans les réglages. Dès que le dossier contient des fichiers .cia, la page affiche l’adresse que la console et les autres appareils peuvent utiliser.
4. Sur la console, ouvrez FBI, choisissez **Remote Install › Scan QR Code** et scannez le code du fichier à installer.

## Configuration requise

- Un Mac sous macOS 27 ou ultérieur.
- Une Nintendo 3DS dotée d’un gestionnaire de titres homebrew capable d’installer à partir d’un code QR, comme FBI, sur le même réseau local que le Mac.
- Des fichiers .cia que vous avez le droit d’installer. Personal hShop ne contient aucun jeu, n’en télécharge aucun et ne renvoie vers aucun.

## Dépannage

**La console n’arrive pas à se connecter.**

- Vérifiez que la console et le Mac sont sur le même réseau. La console ne peut rejoindre que des réseaux Wi-Fi 2,4 GHz en IPv4 avec une sécurité WPA2 ou plus ancienne ; elle ne peut pas rejoindre un réseau uniquement WPA3.
- Les réseaux invités et les routeurs où l’« isolation AP » ou l’« isolation des clients » est activée empêchent les appareils de communiquer entre eux. Utilisez le réseau principal, ou désactivez cette option.
- Scannez les codes de la page ou utilisez l’adresse qu’elle affiche : « localhost » ne fonctionne que sur le Mac lui-même.
- Si le Mac est connecté à plusieurs réseaux (par exemple Ethernet et Wi-Fi), l’adresse de la page peut appartenir au mauvais réseau. Ouvrez alors la page à l’adresse http://<adresse du Mac sur le réseau de la console>:1234 ; les codes utiliseront ensuite cette adresse.
- Si le coupe-feu du Mac est activé, ouvrez **Réglages Système › Réseau › Coupe-feu › Options…** et vérifiez que **Bloquer toutes les connexions entrantes** est désactivé et que Personal hShop est réglé sur **Autoriser les connexions entrantes**.
- Un VPN actif sur le Mac peut empêcher la console de le joindre.

**« Le port … est déjà utilisé. »**
Une autre app utilise ce port. Choisissez-en un autre dans les réglages, puis redémarrez le serveur.

**Un fichier n’apparaît pas sur la page.**
Seuls les fichiers se terminant par .cia placés directement dans le dossier choisi sont listés, pas ceux de ses sous-dossiers.

**La page indique « Aucun fichier .cia trouvé », alors que le dossier en contient.**
Personal hShop n’a pas pu ouvrir le dossier, ou les fichiers sont dans un sous-dossier. Choisissez **Fichier › Arrêter le serveur**, ouvrez les réglages, cliquez sur **Choisir un dossier…**, sélectionnez de nouveau le dossier, puis démarrez le serveur. Si le dossier se trouve sur un disque externe ou réseau, connectez d’abord le disque.

**Un titre est différent du nom du fichier.**
Les titres proviennent du titre anglais enregistré dans le fichier. Quand le fichier n’en a pas, comme beaucoup de fichiers chiffrés, le titre provient du nom du fichier, sans l’identifiant de titre à 16 chiffres du début ni les détails entre parenthèses qui suivent le nom, comme le code produit, la version et la région. Les titres écrits entièrement en majuscules sont affichés avec une majuscule au début de chaque mot, les chiffres romains restant inchangés.

**Une installation s’est arrêtée en cours de route.**
Le Mac reste éveillé pendant l’envoi d’un fichier, mais fermer l’écran d’un MacBook le met tout de même en veille. FBI abandonne lorsqu’aucune donnée n’arrive pendant 15 secondes ; relancez l’installation.

**Les gros jeux prennent du temps.**
Le Wi-Fi de la console est lent : comptez environ 0,5 Mo/s sur une 3DS d’origine et environ 1,3 Mo/s sur une New 3DS. Un jeu de 1 Go prend donc environ 15 minutes sur une New 3DS et plus d’une demi-heure sur une 3DS d’origine.

## Désinstallation

Quittez Personal hShop et placez l’app dans la Corbeille. Pour supprimer aussi ses réglages, choisissez **Aller › Aller au dossier…** dans le Finder, saisissez `~/Library/Containers` et placez dans la Corbeille le dossier nommé « Personal hShop » (son vrai nom est `com.github.cesarse.Personal-hShop`).

## Confidentialité

Personal hShop ne collecte aucune donnée. Consultez la [politique de confidentialité](PRIVACY-fr.md).
