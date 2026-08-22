-- Gold/Silver Case Style
--
-- Presentation-only formatting for Generation II's engine-authored ALL-CAPS
-- text.  This module intentionally keeps player-created names byte-for-byte
-- unchanged and does not write to saves or game data.

return function(mod)
  local GameVersion = require("src.core.GameVersion")
  local playing = GameVersion.get()
  if GameVersion.generation(playing) ~= 2 then return end

  local Font = require("src.render.Font")
  local NamePick = require("src.ui.gen2.NamePick")
  local marker = "_goldSilverCaseStyle"
  local state = Font[marker] or { mod = mod, save = nil, pendingNames = {} }
  state.mod = mod

  local KEEP_UPPER = {
    CD = true, EXP = true, HM = true, HP = true, ID = true, KO = true,
    MN = true, PC = true, PK = true, PP = true, SS = true, TM = true,
    TV = true, VHS = true,
  }

  local WORD_STYLE = {
    POKEMON = "Pokémon",
    POKEDEX = "Pokédex",
    POKEGEAR = "Pokégear",
    POKEMANIAC = "Pokémaniac",
    POKECOM = "PokéCom",
    TMS = "TMs",
    HMS = "HMs",
  }

  local PHRASE_STYLE = {
    ["EXP. ALL"] = "Exp. All",
    ["S.S. AQUA"] = "S.S. Aqua",
    ["S.S. ANNE"] = "S.S. Anne",
  }

  local function escapePattern(text)
    return (text:gsub("([^%w])", "%%%1"))
  end

  local function addName(names, seen, value)
    if type(value) ~= "string" or value == "" or seen[value] then return end
    seen[value] = true
    names[#names + 1] = value
  end

  local function addMonName(names, seen, mon)
    if type(mon) == "table" then addName(names, seen, mon.nickname) end
  end

  local function namesFromSave()
    local names, seen = {}, {}
    for _, name in ipairs(state.pendingNames or {}) do addName(names, seen, name) end

    local save = state.save
    if type(save) ~= "table" then return names end

    local player = type(save.player) == "table" and save.player or {}
    addName(names, seen, player.name)
    addName(names, seen, player.rival)

    for _, mon in ipairs(save.party or {}) do addMonName(names, seen, mon) end
    for _, box in pairs(save.boxes or {}) do
      if type(box) == "table" then
        for _, mon in ipairs(box) do addMonName(names, seen, mon) end
      end
    end
    for _, boxName in pairs(save.boxNames or {}) do addName(names, seen, boxName) end

    local dayCare = save.dayCare
    if type(dayCare) == "table" then
      addMonName(names, seen, dayCare.egg)
      for _, side in ipairs({ dayCare.man, dayCare.lady }) do
        if type(side) == "table" then addMonName(names, seen, side.mon) end
      end
    end

    table.sort(names, function(a, b) return #a > #b end)
    return names
  end

  local function maskUserNames(text)
    local replacements, serial = {}, 0
    local function protect(value)
      serial = serial + 1
      local marker = string.char(1) .. "keep" .. tostring(serial) .. string.char(2)
      replacements[marker] = value
      return marker
    end

    for _, name in ipairs(namesFromSave()) do
      local startsWord = name:match("^%w") ~= nil
      local endsWord = name:match("%w$") ~= nil
      local pattern = (startsWord and "%f[%w]" or "")
        .. escapePattern(name)
        .. (endsWord and "%f[^%w]" or "")
      text = text:gsub(pattern, protect)
    end

    -- Preserve dynamic placeholders and font command tokens exactly.  They may
    -- be expanded after a string is first prepared, so changing their spelling
    -- here would make the renderer miss them entirely.
    text = text:gsub("{[^}\n]+}", protect)
    text = text:gsub("<[^>\n]+>", protect)
    return text, replacements
  end

  local function restoreUserNames(text, replacements)
    for marker, name in pairs(replacements) do
      text = text:gsub(escapePattern(marker), function() return name end)
    end
    return text
  end

  local function formatText(text)
    if type(text) ~= "string" or text == "" then return text end

    local masked, replacements = maskUserNames(text)
    for raw, styled in pairs(PHRASE_STYLE) do
      masked = masked:gsub(escapePattern(raw), styled)
    end
    -- Gold/Silver's native spelling already carries a lowercase accented e;
    -- normalize only the surrounding caps before generic word handling.
    masked = masked:gsub("POKéMON", "Pokémon")
    masked = masked:gsub("POKéDEX", "Pokédex")
    masked = masked:gsub("POKéGEAR", "Pokégear")
    masked = masked:gsub("POKÉMON", "Pokémon")
    masked = masked:gsub("POKÉDEX", "Pokédex")
    masked = masked:gsub("POKÉGEAR", "Pokégear")

    masked = masked:gsub("%u[%u%d'%-]*", function(token)
      if KEEP_UPPER[token] or token:match("^[TH]M%d+$") then return token end
      local styled = WORD_STYLE[token]
      if styled then return styled end
      return token:sub(1, 1) .. token:sub(2):lower()
    end)

    return restoreUserNames(masked, replacements)
  end

  -- The active save is intentionally received through the documented lifecycle
  -- events.  The mod facade does not expose a mutable global game object.
  local function observeSave(payload)
    if type(payload) == "table" and type(payload.save) == "table" then
      state.save = payload.save
    end
  end
  mod.events:on("save.created", observeSave)
  mod.events:on("save.loaded", observeSave)

  -- NamePick calls its onDone callback before the Gold/Silver new-game flow
  -- commits the selected name into save.player. The default GOLD therefore
  -- reached Font.encode once without a save-backed name to protect. Track the
  -- chosen name at that handoff; it is presentation-only state and never
  -- writes to the save.
  if not NamePick[marker] then
    local nativeChoose = NamePick.choose
    NamePick.choose = function(self, name, ...)
      if type(name) == "string" and name ~= "" then
        state.pendingNames = state.pendingNames or {}
        local seen = false
        for _, existing in ipairs(state.pendingNames) do
          if existing == name then seen = true break end
        end
        if not seen then state.pendingNames[#state.pendingNames + 1] = name end
      end
      return nativeChoose(self, name, ...)
    end
    NamePick[marker] = true
  end

  -- Font.draw and Font.width both enter through Font.encode in the current
  -- renderer. Wrapping that one presentation boundary keeps measurement, text
  -- typing, static menus, and final drawing in agreement.
  if Font[marker] then return end

  local nativeEncode = Font.encode
  Font[marker] = state
  state.nativeEncode = nativeEncode
  Font.encode = function(text, ...)
    return nativeEncode(formatText(text), ...)
  end

  if mod.log and type(mod.log.info) == "function" then
    mod.log:info("Gold/Silver Case Style active for %s.", playing)
  end
end
