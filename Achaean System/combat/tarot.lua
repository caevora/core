-- Create the main namespace
TAROT = TAROT or {}

-- Load class files
local Deck = dofile(getMudletHomeDir() .. "/Achaean System/combat/deck.lua")
local Card = dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")

TAROT.DECK = Deck:new()
TAROT.DECK.CARDS = TAROT.DECK.CARDS or {}

TAROT_CATEGORIES = {
    ground = {
      syntax = "FLING <card> AT GROUND",
      targetType = { "room" },
      cooldown = 3.0,
      cards = { "sun", "tower", "wheel", "devil" },
      notes = "Room-based cards that affect the environment."
    },
    adventurer = {
      syntax = function(card, target, affliction)
        if card == "moon" and affliction then
          return string.format("FLING MOON AT %s [%s]", target, affliction)
        else
          return string.format("FLING %s AT %s", card:upper(), target)
        end
      end,
      targetType = { "adventurer", "self" },
      cooldown = 3.0,
      cards = {
        "fool", "star", "magician", "justice", "moon", "lust", "priestess",
        "hangedman", "lovers", "heretic", "empress", "emperor", "aeon","death"
      },
      notes = "Cards that typically target a player or self."
    },
    utility = {
      syntax = "FLING <card> AT GROUND / TOUCH / BOARD / ACTIVATE",
      targetType = { "self", "room" },
      cooldown = 3.0,
      cards = { "hermit", "chariot", "universe", "creator" },
      notes = "Teleportation, illusions, anchors, etc."
    }
  }

function TAROT:normalize(name)
  return name and name:lower() or ""
end

-- Define reusable loader
function TAROT:loadTarotCard(name)
  local ok, result = pcall(dofile, getMudletHomeDir() .. "/Achaean System/combat/cards/" .. name .. ".lua")
  if ok and result and type(result.use) == "function" then
    TAROT.DECK.CARDS[name] = result
    cecho(string.format("\n<green>[TAROT] Loaded card: %s", name))
  else
    cecho(string.format("\n<red>[TAROT] Failed to load card: %s or it returned an invalid object", name))
  end
end

-- Reset/initialize system state and card definitions
function TAROT:resetTarotValues()
  self.state = {
    taggedHermits = {},
    hermit = {}
  }

  -- Load default stub definitions
  for category, data in pairs(TAROT_CATEGORIES) do
    for _, cardName in ipairs(data.cards) do
		if not self.DECK.CARDS[cardName] then
		  self.DECK.CARDS[cardName] = Card:new(cardName, {
			syntax = type(data.syntax) == "string" and data.syntax or "",
			cooldown = data.cooldown,
			targetType = data.targetType,
			notes = data.notes,
			category = category
		  })
		end
    end
  end

	  -- Use TAROT explicitly
	  TAROT:loadTarotCard("fool")
	  TAROT:loadTarotCard("hermit")
	  TAROT:loadTarotCard("chariot")
	  
end



function TAROT:flingCard(name, tag)
  name = self:normalize(name)
  tag = tag and tag:match("^%s*(.-)%s*$") or nil


  -- Generic fallback based on category tables
  local groundCards = {
    sun = true, tower = true, wheel = true, devil = true, chariot = true,
  }

  local targetCards = {
    fool = true, aeon = true, magician = true, priestess = true,
    emperor = true, empress = true, hangedman = true, justice = true,
    lovers = true, lust = true, star = true,
  }


  if flying and (tag == "ground" or table.contains(groundCards, name)) then return "CANT FLING TO GROUND WHEN FLYING" end

  -- Special targeting defaults
  if name == "fool" and not tag then
    tag = "me"
  elseif name == "hermit" and not tag then
    tag = self:getNextHermitTag()
    if not tag then
      cecho("\n<red>[Hermit] All 20 Hermit slots are full. Clear one before adding another.")
      return
    end
    self.DECK.CARDS.hermit:use(tag)
    return
  end

  -- Use custom card class (like Fool/Hermit)
  local card = self.DECK.CARDS[name]
  if card and type(card.use) == "function" then
    card:use(tag)
    return
  end

  if groundCards[name] then
    self:useCard(name, nil)
    return
  end

  if targetCards[name] then
    if not tag then
      cecho(string.format("\n<red>[TAROT] You must specify a target for %s.", name))
      return
    end
    self:useCard(name, tag)
    return
  end

  -- Unknown fallback
  cecho(string.format("\n<red>[TAROT] Unknown or unsupported card: %s", name))
end


-- Generic fallback useCard if no object-based `use()` is present
function TAROT:useCard(cardName, target)
  cardName = self:normalize(cardName)
  local card = TAROT.DECK.CARDS[cardName]

  if not card then
    cecho("\n<red>[TAROT] Unknown card: " .. cardName)
    return
  end

  if self.DECK:get(cardName) <= 0 then
    cecho("\n<red>[TAROT] No " .. cardName .. " cards left!")
    return
  end

  local cmd
  if not target or target == "ground" or target == false then
    cmd = "fling " .. cardName .. " at ground"
  else
    cmd = "fling " .. cardName .. " at " .. target
  end

  send(cmd:lower())
  self.DECK:remove(cardName, 1)
end

function TAROT:showCardList()
  cecho("\n<white>[TAROT] Available Tarot Cards:\n")

  local tarotCards = {
    "aeon", "chariot", "creator", "death", "devil", "emperor", "empress", "fool",
    "hangedman", "justice", "lovers", "lust", "magician", "moon", "priestess", "star",
    "sun", "tower", "universe", "wheel", "hermit"
  }

  for _, card in ipairs(tarotCards) do
    local display = card:gsub("^%l", string.upper)

    cechoLink(
      "(AB) ",
      string.format("send('ab %s')", card),
      string.format("Auto-bind %s", display)
    )

    cechoLink(
      string.format("<cyan>%s", display),
      string.format("TAROT:showCardInfo('%s')", card),
      string.format("View info on %s", display)
    )

    cecho("\n")
  end
end


function TAROT:showCardInfo(cardName)
  cardName = self:normalize(cardName)
  local found = false

  for category, data in pairs(TAROT_CATEGORIES) do
    for _, name in ipairs(data.cards) do
      if name == cardName then
        found = true
        cecho("\n<white>══════════════════════════════════════════════")
        cecho(string.format("\n<yellow><b>Tarot Card: <cyan>%s", cardName:upper()))
        cecho(string.format("\n<yellow>Category: <green>%s", category))
        cecho(string.format("\n<yellow>Cooldown: <white>%ss", data.cooldown))
        cecho(string.format("\n<yellow>Targets: <white>%s", table.concat(data.targetType or {}, ", ")))

        -- Syntax (if dynamic or static)
		-- Syntax display
		local syntaxType = type(data.syntax)

		if syntaxType == "function" then
		  -- Only Moon is truly dynamic
		  if cardName == "moon" then
			cecho("\n<yellow>Syntax: <white>FLING MOON AT <target> [affliction]")
		  else
			-- fallback in case others ever use dynamic syntax
			cecho("\n<yellow>Syntax: <white>FLING <card> AT <target>")
		  end
		elseif syntaxType == "string" then
		  cecho(string.format("\n<yellow>Syntax: <white>%s", data.syntax))
		else
		  cecho("\n<yellow>Syntax: <white>Unknown or undefined.")
		end



        cecho(string.format("\n<yellow>Notes: <gray>%s", data.notes or "None"))
        cecho("\n<white>══════════════════════════════════════════════")
        return
      end
    end
  end

  if not found then
    cecho(string.format("\n<red>[TAROT] No info found for card: %s", cardName))
  end
end

function TAROT:shouldPreemptiveSip()
  local current = tonumber(vitals.mana.current)
  local max = tonumber(vitals.mana.max)

  if not current or not max or max == 0 then
    return false -- can't determine, so don't sip
  end

  local percent = (current / max) * 100
  return percent < 97
end

function TAROT:prepDeckRefresh()
  -- Check for sip balance first
  if balance_data and balance_data.mana and balance_data.mana.in_use then
    tempTimer(3.5, function() self:prepDeckRefresh() end)
    return
  end

  -- Preemptive sip if mana is low
  if self:shouldPreemptiveSip() then
    send("sip mana")
  end

  expandAlias("dl")
  expandAlias("ideck")
end

function TAROT:emergencyCardFling()
  if not balance_data or balance_data.balance.in_use or balance_data.equilibrium.in_use then
    return
  end

  local hpMissing = vitals.health.max - vitals.health.current
  local mpMissing = vitals.mana.max - vitals.mana.current

  if hpMissing < 100 and mpMissing < 100 then
    return -- Skip if you're mostly topped up
  end

  local card
  if hpMissing > mpMissing then
    card = "priestess"
  else
    card = "magician"
  end

  if self.DECK:get(card) > 0 then
    self:useCard(card, "me")
  end
end


function TAROT:hasHermitAnchor(tag)
  tag = tag or "1"
  return self.state.taggedHermits[tag] == true
end


function TAROT:updateCardCount(cardName, count)
  if cardName and count then
    local name = cardName:trim():lower()
    TAROT.DECK.cards[name] = tonumber(count)
  end
end


--function TAROT:testDeckJSON()
  --if not self or not self.DECK or not self.DECK.cards then
   -- cecho("<red>TAROT deck not initialized.\n")
   -- return
  --end

  --cecho("<yellow>Current Tarot Deck:\n")
  --for name, count in pairs(self.DECK.cards) do
  --  cecho(string.format("  - %s: %s\n", name, count))
 -- end

 -- local dkjsonPath = getMudletHomeDir() .. "/Achaean System/system/libs/dkjson.lua"
  --if fileExists(dkjsonPath) then
 --   cecho("\n<green>json library exists at: " .. dkjsonPath .. "\n")
 -- else
 --   cecho("\n<red>json library not found at: " .. dkjsonPath .. "\n")
 -- end
--end

function TAROT:saveDeckToJSON()
  -- Safety checks
  if not dkjson then
    cecho("<red>Cannot save deck: dkjson is not loaded.\n")
    return
  end

  if not self or not self.DECK or not self.DECK.cards then
    cecho("<red>Cannot save deck: TAROT.DECK.cards not initialized.\n")
    return
  end

  -- Check if any card has a count > 0
  local hasCards = false
  --for _, count in pairs(self.DECK.cards) do
   -- if tonumber(count) and count > 0 then
    --  hasCards = true
	--  cecho("<green>Saving deck: TAROT.DECK.cards initialized.\n")
    --  break
    --end
  --end

  --if not hasCards then
  --  cecho("<yellow>No cards to save — all counts are 0.\n")
   -- return
 -- end

  -- Define the file path
  local deckPath = getMudletHomeDir() .. "/Achaean System/system/libs/deck.json"
  local jsonString = dkjson.encode(self.DECK.cards, { indent = true })

  -- Try to write to the file
  local file, err = io.open(deckPath, "w")
  if not file then
    cecho("<red>Error opening file for write: " .. (err or "unknown") .. "\n")
    return
  end

  file:write(jsonString)
  file:close()

  --cecho("<green>Tarot deck saved to: " .. deckPath .. "\n")
end


function TAROT:loadDeckFromJSON()
  -- Ensure dkjson is loaded
  if not dkjson then
    cecho("<red>Cannot load deck: dkjson is not loaded.\n")
    return
  end

  -- Ensure deck table exists
  if not self or not self.DECK then
    cecho("<red>Cannot load deck: TAROT.DECK not initialized.\n")
    return
  end

  -- Define the path
  local deckPath = getMudletHomeDir() .. "/Achaean System/system/libs/deck.json"

  if not fileExists(deckPath) then
    cecho("<red>Deck file not found at: " .. deckPath .. "\n")
    return
  end

  -- Read and decode JSON
  local file = io.open(deckPath, "r")
  if not file then
    cecho("<red>Failed to open deck file.\n")
    return
  end

  local contents = file:read("*a")
  file:close()

  local decoded, _, err = dkjson.decode(contents, 1, nil)
  if err then
    cecho("<red>Error decoding deck.json: " .. err .. "\n")
    return
  end

  if type(decoded) ~= "table" then
    cecho("<red>Invalid deck data in JSON.\n")
    return
  end

  -- Set the deck values
  self.DECK.cards = decoded
  cecho("<green>Tarot deck loaded from JSON successfully.\n")
end

--[[
🔁 Recap of Proper Order
If you're wondering what order to call things, this is best practice:

dofile(getMudletHomeDir() .. "/Achaean System/combat/tarot.lua") -- load main file
TAROT:loadDeckFromJSON()                                         -- restore card counts
TAROT.DECK = Deck:new(TAROT.DECK)                                -- reinitialize safely
TAROT:resetTarotValues()                                         -- initialize CARDS logic
✅ That ensures:

-cards are preserved ✅

-CARDS get built ✅

-JSON data isn’t overwritten ✅
]]

-- Trigger this when reloading from file
function updateTarotFile()
  dofile(getMudletHomeDir() .. "/Achaean System/combat/tarot.lua")
  TAROT:loadDeckFromJSON()           -- ✅ Load the saved deck BEFORE resetting stubs
  TAROT:resetTarotValues()           -- ✅ This now only fills in *missing* card objects
  cecho("\n<green>Tarot system loaded.\n")
end

