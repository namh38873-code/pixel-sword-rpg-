# Emberwood: Moon Shrine — Pixel Sword RPG

A short, complete-loop **2D top-down action RPG** for **Godot 4.7.2**.

## Play on GitHub Pages

https://namh38873-code.github.io/pixel-sword-rpg-/

Build: .github/workflows/web-pages.yml (Godot 4.7.2, HTML5 single-threaded).

## How to play

- **On Android:** d-pad left side, ATK + DASH + potion buttons right side.
- **On desktop:** WASD / arrow keys to move; **J / Space** attack; **K / Shift** dash; **H / E** drink.
- **Quest:** Defeat 8 wandering slimes. Then follow the golden trail to the **Moon Shrine** to battle the guardian.
- **Rewards:** Each slime gives XP. Level up to increase damage and max HP; find healing potions along the trail.
- **Complete game loop:** win screen after the guardian falls; retry after winning or losing.

## Art direction

The world, cabin, ancient ruins, plants, rocks, stonework, hero and monsters are drawn using original GDScript pixel-style canvas primitives. No external art is redistributed. This intentionally makes the project self-contained and license-safe.

## Source

- `scripts/world.gd` - hand-crafted tile-based fantasy forest, road, obstacles and camp
- `scripts/game.gd` - player, NPC enemy AI, sword combat, dash, XP, boss and win/lose states
- `scripts/ui.gd` - mobile multi-touch UI, HUD, quest text
- `scenes/main.tscn` - scene and camera
- `export_presets.cfg` - Godot Web export
- `.github/workflows/web-pages.yml` - build + deploy via Pages

## Project scope

This is a **small playable RPG** and not yet a production-complete commercial game. It lacks sound effects, animations from asset sheets, level selection, equipment and save slots.
