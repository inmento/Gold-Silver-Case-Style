local root = arg[1] or "."

local checks = 0
local function expect(actual, expected, label)
  checks = checks + 1
  if actual ~= expected then
    error((label or "assertion") .. "\nexpected: " .. tostring(expected)
      .. "\nactual:   " .. tostring(actual), 2)
  end
end

local function copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for key, item in pairs(value) do out[key] = copy(item) end
  return out
end

local function equal(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for key, value in pairs(a) do if not equal(value, b[key]) then return false end end
  for key in pairs(b) do if a[key] == nil then return false end end
  return true
end

local function loadMod(version, save, isGen2)
  if isGen2 == nil then isGen2 = true end
  local Font = {
    encode = function(text) return text end,
    width = function(text) return #text * 8 end,
    draw = function(text) return text end,
  }

  package.loaded["src.core.GameVersion"] = nil
  package.loaded["src.render.Font"] = nil
  package.preload["src.core.GameVersion"] = function()
    return {
      get = function() return version end,
      generation = function() return isGen2 and 2 or 1 end,
    }
  end
  package.preload["src.render.Font"] = function() return Font end

  local listeners = {}
  local mod = {
    events = { on = function(_, name, callback) listeners[name] = callback end },
    log = { info = function() end },
  }
  local entry = assert(loadfile(root .. "/main.lua"))
  entry()(mod)
  if listeners["save.created"] then listeners["save.created"]({ save = save }) end
  mod.listeners = listeners
  return Font, mod, entry
end

local save = {
  player = { name = "ASH", rival = "RIVAL" },
  party = { { nickname = "SPARK" } },
  boxes = { { { nickname = "BOXMON" } } },
  boxNames = { "BOX ONE" },
  dayCare = {
    egg = { nickname = "EGGNAME" },
    man = { mon = { nickname = "DAYMON" } },
    lady = { mon = { nickname = "LADYMON" } },
  },
}

local before = copy(save)
local Font, mod, entry = loadMod("gold", save)
expect(Font.encode("PLAYER used POTION!"), "Player used Potion!", "ordinary engine text")
expect(Font.encode("POKéMON POKéDEX POKéGEAR"), "Pokémon Pokédex Pokégear", "native franchise spellings")
expect(Font.encode("HP PP PC TM12 HM07 EXP ID TV CD KO"),
  "HP PP PC TM12 HM07 EXP ID TV CD KO", "protected abbreviations")
expect(Font.encode("EXP. ALL S.S. AQUA"), "Exp. All S.S. Aqua", "styled phrases")
expect(Font.encode("FARFETCH'D and HO-OH"), "Farfetch'd and Ho-oh", "apostrophe and hyphen words")
expect(Font.encode("GOLD HIRO TAYLOR KARL"), "Gold Hiro Taylor Karl",
  "engine-authored initial player-name presets are formatted")
expect(Font.encode("ASH RIVAL SPARK BOXMON BOX ONE EGGNAME DAYMON LADYMON"),
  "ASH RIVAL SPARK BOXMON BOX ONE EGGNAME DAYMON LADYMON", "user-entered names preserved")
expect(Font.encode("ASHLEY uses POTION"), "Ashley uses Potion", "name matching is token bounded")
expect(Font.encode("Already MixedCase text stays MixedCase"),
  "Already MixedCase text stays MixedCase", "mixed case preserved")
expect(Font.encode("<PK><MN> ITEM"), "<PK><MN> Item", "font macro fragments preserved")
expect(Font.encode("{PLAYER} used <MOVE>!"), "{PLAYER} used <MOVE>!", "placeholders preserved")
expect(Font.encode(string.char(1) .. "POTION" .. string.char(2)),
  string.char(1) .. "Potion" .. string.char(2), "text control bytes preserved")
expect(equal(save, before), true, "formatting never mutates save data")

local encoderAfterFirstLoad = Font.encode
local newSave = { player = { name = "JOE", rival = "BILL" } }
local replacementListeners = {}
local replacementMod = {
  events = { on = function(_, name, callback) replacementListeners[name] = callback end },
  log = { info = function() end },
}
entry()(replacementMod)
replacementListeners["save.loaded"]({ save = newSave })
expect(Font.encode, encoderAfterFirstLoad, "hot reload does not stack wrappers")
expect(Font.encode("ASH JOE POTION"), "Ash JOE Potion", "hot reload updates active save context")

local CrystalFont = loadMod("crystal", save)
expect(CrystalFont.encode("PLAYER used POTION!"), "Player used Potion!",
  "Crystal receives the Gen 2 text formatter")
expect(CrystalFont._goldSilverCaseStyle ~= nil, true,
  "Crystal installs the existing stable renderer marker")

local Gen1Font = loadMod("red", save, false)
expect(Gen1Font.encode("PLAYER used POTION!"), "PLAYER used POTION!", "Generation I is not modified")
expect(Gen1Font._goldSilverCaseStyle, nil, "Generation I installs no renderer wrapper")

print(("ok - %d assertions"):format(checks))
