# Politique de confidentialité

[English](PRIVACY.md) · [Deutsch](PRIVACY-de.md) · [Español](PRIVACY-es.md) · **Français** · [Italiano](PRIVACY-it.md) · [Português (Brasil)](PRIVACY-pt-BR.md)

_Cette traduction est fournie à titre indicatif. En cas de divergence avec la [version anglaise](PRIVACY.md), la version anglaise prévaut._

_Dernière mise à jour : 9 novembre 2026_

Personal hShop est une app Mac. Elle ne collecte aucune donnée personnelle.

## Ce que l’app ne fait pas

- Elle ne collecte ni ne partage aucune information personnelle. Le peu qu’elle enregistre reste sur votre Mac (voir ci-dessous).
- Elle ne se connecte jamais à Internet ni à aucun service en ligne. Son bac à sable (sandbox) n’autorise même pas les connexions sortantes.
- Elle n’a ni comptes, ni statistiques, ni publicité, ni suivi, et ne contient aucun code tiers qui en aurait.
- Elle ne garde aucune trace des fichiers téléchargés, ni des appareils qui les téléchargent.

## Ce qui reste sur votre Mac

L’app elle-même enregistre trois réglages, uniquement sur votre Mac, dans son propre bac à sable :

- le port du serveur ;
- l’ouverture automatique ou non de la page au démarrage du serveur ;
- un signet vers le dossier que vous avez choisi, pour que l’app puisse le relire à son prochain lancement.

macOS peut aussi y conserver des informations courantes sur les fenêtres, comme l’emplacement de la fenêtre des réglages. Rien de tout cela ne quitte votre Mac. Les titres des jeux lus dans vos fichiers sont gardés en mémoire tant que l’app est ouverte, et disparaissent quand vous la quittez.

## Vos fichiers et votre réseau

- L’app lit uniquement le dossier que vous choisissez. Elle ne modifie, ne déplace et ne supprime jamais vos fichiers.
- Pendant que le serveur est en marche, tout appareil qui peut joindre votre Mac par le réseau, en général les appareils de votre réseau local, peut ouvrir la page et télécharger les fichiers qui y sont listés. La page et les fichiers sont envoyés en HTTP simple, sans chiffrement, et la page affiche les noms de vos jeux et l’adresse locale de votre Mac. Le serveur s’arrête quand vous l’arrêtez ou quittez l’app, et ne démarre jamais tout seul. Ne le démarrez que sur des réseaux de confiance.

## Conservation et suppression de vos données

Les réglages ci-dessus sont conservés jusqu’à ce que vous les supprimiez. Rien n’est conservé ailleurs et la personne qui développe l’app ne reçoit aucune donnée : il n’y a donc rien à lui demander de supprimer.

Pour que l’app cesse de lire votre dossier, choisissez un autre dossier dans les réglages, ou supprimez les réglages de l’app comme décrit ci-dessous.

Pour supprimer les réglages de l’app, quittez-la, choisissez **Aller › Aller au dossier…** dans le Finder, saisissez `~/Library/Containers` et placez dans la Corbeille le dossier nommé « Personal hShop ». Son vrai nom est `com.github.cesarse.Personal-hShop`. Si macOS demande une autorisation, accordez-la.

Placer l’app elle-même dans la Corbeille ne supprime pas ce dossier.

## Rapports de plantage

Si vous avez choisi dans macOS de partager les données d’analyse avec les développeurs d’apps, Apple peut transmettre des rapports de plantage anonymes pour cette app à la personne qui la développe. Apple les traite selon sa propre politique de confidentialité.

## Enfants

L’app ne collecte de données auprès de personne, enfants compris.

## Modifications de cette politique

Si cette politique change, la nouvelle version sera publiée ici avec une nouvelle date.

## Contact

Pour toute question sur cette politique, écrivez à l’adresse [personalhshop@icloud.com](mailto:personalhshop@icloud.com). Voir aussi la page [Assistance](SUPPORT-fr.md).
