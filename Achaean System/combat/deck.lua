-- deck.lua

local Deck = {}
Deck.__index = Deck

function Deck:new(existing)
    local self = setmetatable({}, Deck)

    self.THRESHOLD = THRESHOLD or 5000

    -- Use existing cards if provided, otherwise default to fresh table
    self.cards = existing and existing.cards or { blank = 0 }

    -- Ensure all card types exist (in case some are missing in JSON)
    local cardNames = {
        "blank","aeon","chariot","creator","death","devil","emperor","empress",
        "fool","hermit","hangedman","justice","lovers","lust","magician","moon",
        "priestess","star","sun","tower","universe","wheel"
    }

    for _, name in ipairs(cardNames) do
        self.cards[name] = self.cards[name] or 0
    end

    -- Retain vars and cache if provided
    self.vars = existing and existing.vars or { last = 0, count = 0 }
    self.cache = existing and existing.cache or { lowCards = {}, timestamp = 0 }

    return self
end


function Deck:normalize(name)
    return name and name:lower() or ""
end

function Deck:add(cardName, amount)
    cardName = self:normalize(cardName)
    if self.cards[cardName] then
        self.cards[cardName] = self.cards[cardName] + amount
        self.cards.blank = self.cards.blank - amount
        self.vars.count = amount
        self.vars.last = cardName
    end
end

function Deck:remove(cardName, amount)
    cardName = self:normalize(cardName)
    if self.cards[cardName] and self.cards[cardName] >= amount then
        self.cards[cardName] = self.cards[cardName] - amount
    end
end

function Deck:set(cardName, count)
    cardName = self:normalize(cardName)
    if self.cards[cardName] then
        self.cards[cardName] = count
    end
end

function Deck:get(cardName)
    cardName = self:normalize(cardName)
    return self.cards[cardName] or 0
end

function Deck:list()
    cecho("<white>Your Tarot Card Counts:\n")
    local names = {}
    for name in pairs(self.cards) do table.insert(names, name) end
    table.sort(names)
    for _, name in ipairs(names) do
        cecho(string.format("\n - <cyan>%s<reset>: %d", name, self.cards[name]))
    end
    echo"\n"
    self:lowCards(self.THRESHOLD)
end

function Deck:lowCards(threshold)
    threshold = THRESHOLD or self.THRESHOLD
    local found = false
    local total = 0
    local missingTotal = 0
    local totalBlankCards = self.cards.blank or 0

    cecho(string.format("\n<orange>Cards below threshold (%d)<white>: ", threshold))
    for name, count in pairs(self.cards) do
        if name ~= "blank" then
            total = total + count
            if count < threshold then
                found = true
                local toMake = threshold - count
                missingTotal = missingTotal + toMake
                cecho(string.format("\n - <yellow>%s<reset>: %d (need %d more)", name, count, toMake))
            end
        end
    end

    if not found then
        cecho("<white>0\n")
    else
        local netMissing = math.max(0, missingTotal - totalBlankCards)
        cecho(string.format("\n<white>Total cards in deck (excluding blanks): <green>%d<reset>", total))
        cecho(string.format("\n<white>Total cards needed to refill deck: <red>%d<reset>", missingTotal))
        cecho(string.format("\n<white>After blanks applied, still missing: <red>%d<reset>", netMissing))
    end
end

function Deck:updateLowCardCache()
    local now = os.time()
    if now == self.cache.timestamp then return end

    self.cache.lowCards = {}
    for name, count in pairs(self.cards) do
        if name ~= "blank" and count < self.THRESHOLD then
            table.insert(self.cache.lowCards, { name = name, count = count, needed = self.THRESHOLD - count })
        end
    end
    table.sort(self.cache.lowCards, function(a, b) return a.count < b.count end)
    self.cache.timestamp = now
end

function Deck:getLowestCardBelowThreshold()
    self:updateLowCardCache()
    return self.cache.lowCards[1] or nil
end

function Deck:canInscribe()
    local mana = vitals.mana.current
    local hasMana = tonumber(mana) >= math.floor(vitals.mana.max * 0.10)
    local hasBlanks = self.cards.blank and self.cards.blank > 0
    return hasMana and hasBlanks, hasMana, hasBlanks
end

function Deck:inscribe(cardName)
    local canInscribe, hasMana, hasBlanks = self:canInscribe()
    if not canInscribe then return end

    cardName = self:normalize(cardName)
    local current = self.cards[cardName] or 0
    local needed = self.THRESHOLD - current
    local count = math.min(needed, self.cards.blank)

    if count <= 0 then return end

    send("INSCRIBE BLANK WITH " .. count .. " " .. cardName)
    self:add(cardName, count)
end

function Deck:autoInscribeLowCards()
  cecho("\n<gray>[DEBUG] Starting autoInscribeLowCards...")

  local manaData = PLAYER:getResourceData("mana")
  if not manaData then
    cecho("\n<red>[DEBUG] Failed to get mana data from PLAYER.")
    return
  end

  cecho(string.format("\n<gray>[DEBUG] Current Mana: %s / %s", manaData.current, manaData.total))

  local requiredMana = math.floor(manaData.total * 0.10)
  cecho(string.format("\n<gray>[DEBUG] Required Mana to inscribe: %s", requiredMana))

  if tonumber(manaData.current) < requiredMana then
    cecho("\n<orange>[DEBUG] Not enough mana to inscribe.")
    return
  end

  local blanks = self.cards.blank or 0
  cecho(string.format("\n<gray>[DEBUG] Blank cards available: %d", blanks))

  if blanks <= 0 then
    cecho("\n<orange>[DEBUG] No blank cards available.")
    return
  end

  local lowest = self:getLowestCardBelowThreshold()
  if not lowest then
    cecho("\n<green>[DEBUG] No cards below threshold. Nothing to inscribe.")
    return
  end

  --cecho(string.format("\n<gray>[DEBUG] Lowest card: %s (%d), needs %d more", lowest.name, lowest.count, lowest.needed))

  local toInscribe = math.min(lowest.needed, blanks, 20)
  --cecho(string.format("\n<white>[DEBUG] Will inscribe %d %s card(s)", toInscribe, lowest.name))

  local cmd = string.format("INSCRIBE BLANK WITH %d %s", toInscribe, lowest.name)
  --cecho(string.format("\n<green>[DEBUG] Sending command: %s", cmd))
  send(cmd)

  self:add(lowest.name, toInscribe)
  --cecho("\n<green>[DEBUG] Updated internal deck count.")

  --cecho("\n<gray>[DEBUG] Finished autoInscribeLowCards.")
end




function updateDeckFile()
  dofile(getMudletHomeDir() .. "/Achaean System/combat/deck.lua")
  updateTarotFile()

end


return Deck