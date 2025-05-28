local Card = dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")

local Fool = setmetatable({}, Card)
Fool.__index = Fool

function Fool:new()
	local self = setmetatable(Card:new("fool", {
		syntax = "FLING FOOL AT <target>",
		cooldown = 3.0,
		targetType = { "self", "adventurer" },
		notes = "Cures 3 afflictions from self.",
		category = "adventurer"
	}), Fool)
	return self
end

function Fool:use(target)
	target = target or "me"
	cecho("\n<cyan>[DEBUG] Fool card used on " .. target)
	send("fling fool at " .. target)
end

function resetFoolValues()
  
end



function updateFoolFile()
  TAROT.DECK.CARDS["fool"] = dofile(getMudletHomeDir() .. "/Achaean System/combat/cards/fool.lua")
  cecho("\n<green>[TAROT] Fool card updated.")
  updateTarotFile()
  resetFoolValues()


  
end



return (function()
    return Fool:new()
end)()

