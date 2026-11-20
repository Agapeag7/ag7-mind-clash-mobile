# AG7 Mind Clash

Jeu mobile Android et iOS de tir à la corde mathématique, avec personnages cartoon 2D
dessinés en code et illustrations PNG transparentes pour les modes et résultats.
Les bonnes réponses déplacent progressivement la corde et les équipes avec elle :
l'équipe gagnante recule vers son camp tandis que l'équipe adverse avance vers
elle. Le mouvement s'inverse quand l'autre équipe gagne, sans modifier l'écart
entre les équipes. Les mains restent accrochées à la corde pendant le mouvement.
Les manches se jouent en portrait dans une arène verticale qui s’adapte à l’espace
disponible au-dessus du chronomètre, avec les commandes visibles à l’écran sans défilement.

## Lancer

    flutter pub get
    flutter run

## Compiler APK release

    flutter build apk --release

APK : `build/app/outputs/flutter-apk/app-release.apk`

## Compiler pour iOS

La cible iOS est configurée dans `ios/`. Depuis un Mac avec Xcode installé,
récupérer les dépendances puis compiler :

    flutter pub get
    flutter build ios --release

La signature de distribution et la publication nécessitent un compte Apple
Developer et une configuration de signature dans Xcode.

## Architecture

- `lib/core/` — constantes, enums, configuration de difficulté
- `lib/models/` — Team, Question, PowerUp, Inventory
- `lib/services/` — génération de questions, IA, audio, stockage
- `lib/game/` — moteur de jeu (GameManager, Ag7Game + composants Flame)
- `lib/providers/` — providers Riverpod (settings, stats)
- `lib/screens/` — les écrans de l'application
- `test/` — tests unitaires

## Compilation Android sur une machine à mémoire limitée

La mémoire du daemon Gradle est plafonnée à 1,5 Go et ses workers sont limités à deux pour éviter que la compilation ne dépasse la mémoire disponible. Pour générer l'APK :

    flutter build apk --release

