# AG7 Mind Clash

Jeu mobile Android de tir à la corde mathématique, avec personnages cartoon 2D
dessinés en code et illustrations PNG transparentes pour les modes et résultats.
Les manches se jouent en portrait dans une arène 16:9, avec les commandes visibles
à l’écran sans défilement.

## Lancer

    flutter pub get
    flutter run

## Compiler APK release

    flutter build apk --release

APK : `build/app/outputs/flutter-apk/app-release.apk`

## Architecture

- `lib/core/` — constantes, enums, configuration de difficulté
- `lib/models/` — Team, Question, PowerUp, Inventory
- `lib/services/` — génération de questions, IA, audio, stockage
- `lib/game/` — moteur de jeu (GameManager, Ag7Game + composants Flame)
- `lib/providers/` — providers Riverpod (settings, stats)
- `lib/screens/` — les 10 écrans de l'application
- `test/` — tests unitaires

## Compilation Android sur une machine à mémoire limitée

La mémoire du daemon Gradle est plafonnée à 1,5 Go et ses workers sont limités à deux pour éviter que la compilation ne dépasse la mémoire disponible. Pour générer l'APK :

    flutter build apk --release
