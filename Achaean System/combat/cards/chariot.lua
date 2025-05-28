local Card = dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")

local Chariot = setmetatable({}, Card)
Chariot.__index = Chariot


function Chariot:new()
	local self = setmetatable(Card:new("chariot", {
		syntax = "FLING CHARIOT AT GROUND / BOARD CHARIOT / SPUR CHARIOT SKYWARDS / LAND / DISMOUNT",
		cooldown = 3.0,
		targetType = { "ground" },
		notes = "The Chariot will create an infernal chariot upon which you may ride.",
		category = "adventurer"
	}), Chariot)
	return self
end

local Card = dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")

local Chariot = setmetatable({}, Card)
Chariot.__index = Chariot


function Chariot:new()
  local self = setmetatable(Card:new("chariot", {
    syntax = "FLING CHARIOT AT GROUND / BOARD / SPUR / LAND",
    cooldown = 3.0,
    targetType = { "self", "room" },
    notes = "Summons and rides a flying chariot.",
    category = "utility"
  }), Chariot)
  return self
end

function Chariot:use()
  -- Initialize if missing
  TAROT.state.chariotStage = TAROT.state.chariotStage or 1
  local state = TAROT.state.chariotStage
  
   cecho(string.format("\n<yellow>[TAROT] Chariot stage: %d | Flying: %s", state, tostring(flying)))

  if state == 1 then
    send("fling chariot at ground")
    send("queue addclear eqbal board chariot")
  elseif state == 2 then
    send("queue addclear eqbal spur chariot skywards")
  elseif state == 3 then
    send("queue addclear eqbal land")
  elseif state == 4 then
	if not(flying) then
		send("queue addclear eqbal spur chariot skywards")
	end
	
    
  end
  -- Cycle to next stage
  --TAROT.state.chariotStage = state % 3 + 1
end

function TAROT:resetChariotState()
  self.state.chariotStage = 1
  cecho("\n<green>[TAROT] Chariot state reset to 1 (ground summoning).")
end

function TAROT:setChariotState(state)
  state = tonumber(state)
  if state and state >= 1 and state <= 4 then
    self.state.chariotStage = state
    cecho(string.format("\n<green>[TAROT] Chariot state set to %d.", state))
  else
    cecho("\n<red>[TAROT] Invalid chariot state. Must be 1, 2, 3, or 4.")
  end
end



function updateChariotFile()
  TAROT.DECK.CARDS["chariot"] = dofile(getMudletHomeDir() .. "/Achaean System/combat/cards/chariot.lua")
  cecho("\n<green>[TAROT] Chariot card updated.")
  updateTarotFile()



  
end

return (function()
  return Chariot:new()
end)()










