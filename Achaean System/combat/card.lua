-- card.lua
TAROT = TAROT or {}
local Card = {}
Card.__index = Card

function Card:new(name, data)
    local self = setmetatable({}, Card)
    self.name = name or "unknown"
    self.cooldown = data.cooldown or 0
    self.syntax = data.syntax or ""
    self.notes = data.notes or ""
    self.targetType = data.targetType or {}
    return self
end

function Card:describe()
    cecho(string.format(
        "\n<green>[CARD] %s\n<cyan>Cooldown: %.1f\nSyntax: %s\nNotes: %s\n",
        self.name, self.cooldown, self.syntax, self.notes
    ))
end

-- Add more behavior later like Card:use(), Card:isValidTarget(), etc.


function Card:resetCardValues()
	
end




function updateCardFile()
  dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")
  -- Adjust the path as needed
  --Card:resetCardValues()
  updateTarotFile()

  
end

return Card