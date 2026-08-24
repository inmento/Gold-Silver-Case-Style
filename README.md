# Gen 2 Case Style

**Gen 2 Case Style** is a presentation-only quality-of-life mod for the Gold, Silver, and Crystal builds of Gen1Recomp. It converts engine-authored all-caps English text into a more readable title/mixed-case style while preserving player-entered names.

| Package detail | Value |
|---|---|
| Supported games | Gold, Silver, and Crystal |
| Required Gen1Recomp version | `0.2.24` or newer |
| Mod API | `2` |
| Save-data changes | None |
| Link compatibility | Unaffected |

## What it changes

The mod changes only the text passed to the common Generation II font renderer. It does not edit ROM-derived data, item data, battle rules, scripts, saves, or Pokémon data.

| Native display text | Styled display text |
|---|---|
| `PLAYER used POTION!` | `Player used Potion!` |
| `POKéMON` | `Pokémon` |
| `POKéDEX` | `Pokédex` |
| `EXP. ALL` | `Exp. All` |
| `S.S. AQUA` | `S.S. Aqua` |

Common technical labels deliberately stay uppercase, including `HP`, `PP`, `PC`, `TM`, `HM`, `EXP`, `ID`, `TV`, `CD`, and `KO`. Native font macro fragments are also left intact.

## Name protection

The default behavior respects user-created content. The formatter tracks the active save through the engine’s save-created and save-loaded lifecycle events, then leaves these values exactly as entered:

- Player and rival names.
- Party Pokémon nicknames.
- Boxed Pokémon nicknames and custom box names.
- Day-Care Pokémon and egg nicknames.

This makes it safe to use an all-caps nickname such as `SPARK`, a mixed-case player name, or a custom box label without the mod rewriting it.

## Installation

Download the release ZIP and import it through Gen1Recomp’s mod manager. The ZIP contains a `Gold-Silver-Case-Style` folder at its root; do not extract individual files out of that folder. Enable the mod for a Gold, Silver, or Crystal installation and launch normally.

> The manifest advertises the Generation II package scope, and the code performs a second runtime guard using `GameVersion.generation(playing) == 2`. It will not install its text wrapper on Generation I.

## Compatibility

Because the mod affects only final text presentation, it is compatible in principle with gameplay, encounter, sprite, audio, and save-data mods. A different mod that replaces or independently wraps the same shared font encoder can control the final order of presentation changes; load-order testing is recommended for any other text, translation, or font mod.

## Development and provenance

This is a new implementation written against the current Gen 2 renderer. It was behaviorally informed by FelizNavidad-D’s **Decapitalization 1.0.3** release, but does not include or copy its code. The code is intentionally organized around a distinct live-name protection model and a single font-encoding wrapper.

Run the regression suite with:

```bash
lua tests/test_main.lua .
```

The suite validates Gold and Crystal through the Generation II gate, native casing conversions, technical abbreviations, custom-name preservation, placeholder and control-byte handling, no-save-mutation behavior, and safe hot reload.

## License

This project is released under the MIT License. It is an unofficial community mod and is not affiliated with Nintendo, Game Freak, The Pokémon Company, LÖVE, or Gen1Recomp.
