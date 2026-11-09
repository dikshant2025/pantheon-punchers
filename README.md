# Pantheon Punchers

A local multiplayer brawler for 1–4 players, built in **Godot 4.4** with **GDScript**. Players fight as gods from Greek mythology (Zeus, Poseidon, Hades) across mythological stages.

Built as a team project for a game development course at Jacksonville State University. **I wrote the game's code (GDScript).**

## Features
- **1–4 players with controllers.** Each controller is bound to its own fighter at runtime.
- **Hitbox/hurtbox combat** with attack cooldowns, damage and floating health bars
- **Enemy AI** that tracks and attacks the nearest player
- **Dynamic camera** that follows and frames every active player
- Main menu, settings, character select, win and game-over screens
- Music and UI sound managers

## How the code is organized
| Script | What it does |
|---|---|
| `InputRouter.gd` (autoload) | Maps each controller's `device_id` to its player and forwards that controller's input only to that player |
| `EventBus.gd` (autoload) | Global signals (`player_joined`, `player_died`, `big_hit` …) so systems talk to each other without hard references |
| `PlayerRegistry.gd` (autoload) | Tracks which players have joined |
| `Hitbox.gd` / `Hurtbox.gd` / `IDamageable.gd` | Reusable damage system shared by players and enemies |
| `CameraRig.gd` | Camera that keeps all players on screen |
| `Player.gd`, `Enemy.gd`, `Level.gd` | Fighter movement and attacks, enemy behavior, level setup |

## Run it
1. Install [Godot 4.4](https://godotengine.org/download).
2. Clone this repo, open Godot, click **Import**, and select `project.godot`.
3. Press **F5**. Connect controllers for multiplayer.
