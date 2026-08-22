# Changelog

## 0.1.0 — 2026-08-21

This initial public release adds **Gold/Silver Case Style** for the Gold and Silver builds of Gen1Recomp. It applies a presentation-only sentence-style formatter to engine-authored all-caps text at the shared Generation II font encoding boundary.

The release preserves player and rival names, party and boxed Pokémon nicknames, custom box names, and Day-Care names exactly as entered. It keeps common interface abbreviations such as HP, PP, TM, HM, EXP, ID, TV, CD, and KO uppercase, while normalizing native franchise terms including Pokémon, Pokédex, Pokégear, and Exp. All.

The package declares Generation II scope, uses `GameVersion.generation(playing) == 2` as a second runtime guard, and includes a standalone regression suite covering formatting, user-name protection, no-save-mutation behavior, and hot reload safety.
