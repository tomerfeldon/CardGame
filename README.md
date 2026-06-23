# CardGame 🃏

CardGame is an iOS card game built with UIKit. When you open the app it reads the
device's GPS location to decide which side of the world you play on — **East** or
**West** — then runs an automatic 10-round duel against the computer, where the
stronger card wins each round. It works in light and dark appearance, in portrait
and landscape, and comes with background music and sound effects.

Built in Swift with Storyboard (Interface Builder), Core Location, AVFoundation,
and unit tests using Swift Testing.

---

## 🎬 Demo

<!-- Drag your gameplay video here while editing this file on GitHub.
     GitHub will upload it and replace this comment with a video link. -->

---

## 📱 Screens

| Screen | Description |
|--------|-------------|
| **Menu** | The first time, an **Insert name** button is shown; once a name is entered it is saved and displayed as **"Hi \<name\>"**. On every launch the location is sampled, the side (West/East) is highlighted, and the **START** button appears only when both a name and a location exist. |
| **Game** | Starts automatically, with no buttons. Every 5 seconds the cards flip: the faces are shown for ~3 seconds, the stronger card scores a point, then they flip back. The score and timer update each round. After 10 rounds → the summary screen. |
| **Summary** | Shows the **Winner** and their score, with a **BACK TO MENU** button that returns to the main menu. |

---

## 🎮 Game rules

- **Side selection**: the player's longitude is compared to the reference meridian
  `34.817549168324334`. East of the line → East side, otherwise → West side.
- **Card strength** = card value: `2..10`, `J=11`, `Q=12`, `K=13`, `A=14` (Ace high).
- Each round draws two cards. The stronger card scores a point for its owner.
- **A tie between the two cards** → no one scores (ignored).
- **A tie at the end of the game** → the house (PC) wins.
- The game cannot run without **both a location and a name**.

---

## ✨ Features

- **Location-based sides** — your longitude versus the reference meridian decides
  whether you play East or West.
- **Persistent player name** — saved in `UserDefaults` and remembered across launches.
- **Automatic gameplay** — ten timed rounds with live scoring and card-flip animations.
- **Light & dark mode** — text and background use dynamic system colors, and the
  menu globes switch to night images.
- **Portrait & landscape** — every screen is laid out with Auto Layout and adapts
  to both orientations.
- **Audio** — looping background music during the game, a sound on every card flip,
  and a victory sound on the summary screen. The music stops when the game stops.
- **Lifecycle-aware** — the round timer and music pause when the app is backgrounded
  and resume when it returns to the foreground.

---

## 🏗 Architecture

```
CardGame/
├── Models/
│   ├── Card.swift          // a single card: suit, rank, strength, asset name
│   ├── Deck.swift          // the card pool + drawing two cards
│   └── Side.swift          // enum: west / east
├── Game/
│   └── GameEngine.swift    // pure game logic (no UIKit) - covered by unit tests
├── Location/
│   └── LocationService.swift // CLLocationManager wrapper + side from longitude
├── Audio/
│   └── SoundManager.swift  // AVAudioPlayer: looping music + flip / win effects
├── ViewControllers/
│   ├── MenuViewController.swift
│   ├── GameViewController.swift
│   └── SummaryViewController.swift
├── Sounds/                 // bg_music.mp3, card_flip.mp3, win_game.mp3
├── Base.lproj/Main.storyboard  // the UI: Navigation Controller + 3 scenes
└── Assets.xcassets/            // 26 cards + 2 card backs + day/night globes
```

**Separation of concerns:** the game logic (`GameEngine`) and side selection
(`LocationService.side(forLongitude:)`) are kept independent of UIKit so they can
be unit tested on their own.

**Navigation:** `UINavigationController` (hidden bar) → Menu → (segue `toGame`) →
Game → (segue `toSummary`) → Summary → `popToRootViewController` back to the menu.

---

## 🎨 UI — built in Storyboard

The entire interface is laid out **visually in `Base.lproj/Main.storyboard`**
(Interface Builder): a `UINavigationController` plus the three scenes, all
positioned with **Auto Layout** constraints. Views are wired to their
controllers through **`@IBOutlet` / `@IBAction`**, and screen transitions use
storyboard **segues**. The Swift files hold only behaviour — there is no
programmatic view building.

---

## 🃏 Card assets

- A pool of **26 cards**: clubs A–K and diamonds A–K - the two complete suits.
- Two card backs: red (`card_back_red`) and black (`card_back_black`).
- Imageset names follow the `<suit>_<rank>` format (e.g. `clubs_13`, `diamonds_14`),
  so `Card.assetName` maps directly to an image.

---

## ▶️ Build & run

**Requirements:** Xcode 16.2+, iOS 18.2+ (simulator or device). Works in both
**portrait and landscape**, and supports **light and dark** appearance.

```bash
git clone https://github.com/tomerfeldon/CardGame
cd CardGame
open CardGame.xcodeproj
```

In Xcode: pick a simulator and press **Run** (`Cmd+R`).

### Simulating a location in the simulator
The game needs a location. In the simulator:
**Features → Location → Custom Location…**
- `longitude` greater than `34.8175` → **East** side
- `longitude` less than `34.8175` → **West** side

> If no location is set, a message explains that the game requires a location.

---

## ✅ Tests

Unit tests for `GameEngine` and side selection live in
`CardGameTests/CardGameTests.swift` (Swift Testing). Run them with **`Cmd+U`** in Xcode.

Covered: card-strength comparison and scoring, skipping on a tie, the game ending
after 10 rounds, an end-of-game tie going to PC, and side selection from longitude.

---

## 🔐 Permissions

`NSLocationWhenInUseUsageDescription` is set in `Info.plist` - required to obtain
the location while the app is in use.
