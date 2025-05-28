
local Card = dofile(getMudletHomeDir() .. "/Achaean System/combat/card.lua")

local Hermit = setmetatable({}, Card)
Hermit.__index = Hermit

function Hermit:new()
    local self = setmetatable(Card:new("hermit", {
      syntax = "FLING HERMIT AT GROUND / ACTIVATE",
      cooldown = 3.0,
      targetType = { "self", "room" },
      notes = "Teleports to a stored location or sets one.",
      category = "utility"
    }), Hermit)
    return self
 end

function resetHermitValues()
  TAROT.state = TAROT.state or {}
  TAROT.state.taggedHermits = {}
  TAROT.state.hermit = {
    location = "",
    environment = "",
    exits = {},
    area = "",
    coord = "",
    room = "",
  }
end


function updateHermitFile()
  TAROT.DECK.CARDS["hermit"] = dofile(getMudletHomeDir() .. "/Achaean System/combat/cards/hermit.lua")
  cecho("\n<green>[TAROT] Hermit card reloaded.")
  updateTarotFile()
  --resetHermitValues()
end

	function Hermit:parseOutput(tag, id, loc)
		TAROT.state = TAROT.state or {}
		TAROT.state.taggedHermits = TAROT.state.taggedHermits or {}

		tag = tostring(tag):match("^%s*(.-)%s*$")
		loc = tostring(loc):match("^%s*(.-)%s*$")

		if tag and id and loc then
		  TAROT.state.taggedHermits[tag] = {
			id = tonumber(id),
			location = loc
		  }
		  --cecho(string.format("\n<green>[Hermit] Loaded tag [%s] → %s (ID: %s)", tag, loc, id))
		else
		  cecho("\n<red>[Hermit] Incomplete tag data.")
		end
	end

  function Hermit:clearAllTags()
    TAROT.state = TAROT.state or {}
    TAROT.state.taggedHermits = {}
    TAROT.state.hermit = {
      location = "",
      environment = "",
      exits = {},
      area = "",
      coord = "",
      room = "",
    }
    cecho("\n<yellow>[Hermit] All Hermit tags and anchor cleared.")
  end
  
	function TAROT:getNextHermitTag()
	  TAROT.state = TAROT.state or {}
	  TAROT.state.taggedHermits = TAROT.state.taggedHermits or {}

	  for i = 1, 20 do --far right number is total number of hermit cards we want to be able to put down.
		local tag = tostring(i)
		if not TAROT.state.taggedHermits[tag] then
		  return tag
		end
	  end

	  return nil -- all slots used
	end
  

	function Hermit:use(tag)
	  tag = tostring(tag or "0"):match("^%s*(.-)%s*$")
	  TAROT.state = TAROT.state or {}
	  TAROT.state.taggedHermits = TAROT.state.taggedHermits or {}

	  local room = gmcp and gmcp.Room and gmcp.Room.Info
	  if not room or not room.num then
		cecho("\n<red>[Hermit] Cannot read room info yet.")
		return
	  end

	  local currentRoomID = tonumber(room.num)
	  local anchor = TAROT.state.taggedHermits[tag]

	  -- 🧱 BLOCK: Room already anchored under *another* tag
	  for existingTag, data in pairs(TAROT.state.taggedHermits) do
		if existingTag ~= tag and tonumber(data.id) == currentRoomID then
		  cecho(string.format("\n<red>[Hermit] Room already anchored under tag [%s].", existingTag))
		  return
		end
	  end

	  -- 🧱 BLOCK: Monolith
	  if table.contains(inv_room or {}, "a monolith sigil") then
		cecho("\n<red>[Hermit] Cannot use Hermit — Monolith present.")
		return
	  end

	  -- 🧱 BLOCK: Off balance or equilibrium
	  if vitals and ((vitals.balance == "0") or (vitals.eq == "0")) then
		cecho("\n<red>[Hermit] You are off balance or equilibrium.")
		return
	  end

	  -- 🧠 If tag already exists
	  if anchor then
	  cecho(string.format("\n<blue>[Hermit DEBUG] anchor.id = %s | currentRoomID = %s", tostring(anchor.id), tostring(currentRoomID)))

		if tonumber(anchor.id) == tonumber(currentRoomID) then
		  cecho(string.format("\n<cyan>[Hermit] Already in anchored room [%s] — skipping commands.", tag))
		  return
		else
		  cecho(string.format("\n<yellow>[Hermit] Flinging to tag [%s].", tag))
		  send("fling hermit at ground " .. tag)
		  tempTimer(0.5, function()
			TAROT.state.taggedHermits[tag] = nil
			cecho(string.format("\n<yellow>[Hermit] Tag [%s] removed after use.", tag))
		  end)
		  return
		end
	  end

	  -- 🆕 Create new anchor
	  TAROT.state.taggedHermits[tag] = {
		id = currentRoomID,
		location = room.name or "<unknown>"
	  }

	  TAROT.state.hermit = {
		location = (room.name or ""):lower(),
		environment = (room.environment or ""):lower(),
		exits = room.exits or {},
		area = (room.area or ""):lower(),
		coord = room.coords,
		room = currentRoomID,
	  }

	  cecho(string.format("\n<green>[Hermit] Anchor set as [%s] → %s", tag, room.name or "?"))
	  send("queue addclear eqbal outd hermit;activate hermit " .. tag)
	end

return (function()
  return Hermit:new()
end)()
