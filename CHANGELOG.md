# Changelog

## 0.1.2 — 2026-08-22

This release packages the corrected engine-authored preset formatting in a higher version so a launcher installation of the earlier 0.1.1 build can update normally. Its functional behavior is the corrected preset behavior documented below.

## 0.1.1 — 2026-08-22

This corrected release explicitly covers the engine-authored initial player-name presets on the Gold and Silver name-selection menu. They now use the same readable title case as other static UI text: `Gold`, `Hiro`, `Taylor`, and `Karl` in Gold, with the equivalent Silver presets formatted the same way.

The preset menu is not treated as user-entered data. The existing save-backed protection remains limited to actual player/rival names, Pokémon nicknames, custom box labels, and Day-Care names after they exist in the save.

## 0.1.0 — 2026-08-21

This initial public release adds **Gold/Silver Case Style** for the Gold and Silver builds of Gen1Recomp. It applies a presentation-only sentence-style formatter to engine-authored all-caps text at the shared Generation II font encoding boundary.

The release preserves player and rival names, party and boxed Pokémon nicknames, custom box names, and Day-Care names exactly as entered. It keeps common interface abbreviations such as HP, PP, TM, HM, EXP, ID, TV, CD, and KO uppercase, while normalizing native franchise terms including Pokémon, Pokédex, Pokégear, and Exp. All.

The package declares Generation II scope, uses `GameVersion.generation(playing) == 2` as a second runtime guard, and includes a standalone regression suite covering formatting, user-name protection, no-save-mutation behavior, and hot reload safety.
