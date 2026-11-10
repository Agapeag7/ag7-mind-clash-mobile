# AG7 Mind Clash

Jeu mobile Android de tir à la corde mathématique.
Personnages cartoon 2D entièrement dessinés en code (aucun asset externe).

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
