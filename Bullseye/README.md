# Bullseye – gra z suwakiem (Technologie Mobilne)

UIKit + Swift, interfejs budowany kodem (Auto Layout), tylko orientacja pozioma.
UWAGA: projekt nie był kompilowany ani uruchamiany (brak Xcode/macOS w środowisku, w którym powstał).

## Uruchomienie (macOS + Xcode 26)
    brew install xcodegen
    cd Bullseye
    xcodegen
    open Bullseye.xcodeproj
Wybierz symulator iPhone i naciśnij Cmd+R.

## Zawartość
- ViewController.swift – logika gry, interfejs, dźwięki, wygląd suwaka
- Resources/ – SliderIcon/Left/Right.png, Background.png (wygenerowane tło), 3 pliki mp3
  (restart.mp3 – Restart, nice_shot.mp3 – 100 punktów, win.mp3 – koniec gry)
- Assets.xcassets/AppIcon – ikona aplikacji 1024x1024
