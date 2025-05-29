function huntToggle()
  hunting = hunting or false
  if not hunting then
    hunting = true
    defenses.hiding.keepup=false
    if myclass() == "serpent" then send("emerge") end
	GUI.datawindow:activateTab("Room")
    huntStart()
    cecho("\n<white>(<gold>Hunt<white>):<green> Hunting Enabled")
  elseif hunting then
    hunting = false
    defenses.hiding.keepup=true
    cecho("\n<white>(<gold>Hunt<white>):<red> Hunting Disabled")
  end
end

function autoHuntToggle()
  autohunting = autohunting or false
  if not autohunting then
    autohunting = true
    cecho("\n<white>(<gold>Hunt<white>):<green> Auto Hunting Enabled")
    send("look")
  elseif autohunting then
    autohunting = false
    cecho("\n<white>(<gold>Hunt<white>):<red> Auto Hunting Disabled")
  end
end

-- Check if the character is alone in the room.

function isAloneInRoom()
	if not table.contains(myaffs, "blackout") then
	   if #gmcp.Room.Players == 1 then
		  return true
	   else
		  return false
	   end
	end
end

function moveToNextRoom()
  if routedb[selectedroute] and not table.is_empty(routedb) then
    if huntingpointer > #routedb[selectedroute] or routedb[selectedroute][huntingpointer] == nil then
      --disable hunting at end of route.
      if hunting then
        huntToggle()
        autoHuntToggle()
      end
      --used for auto moving between pre-set selected routes.
      --selectNextRoute()
    else
      --move to next room in currently selected route.
      lasthunttarget = ""
      expandAlias("hunt step")
    end
  end
end

function isTargetAlive(target)
  return findkey(roomstufflist, target)
end

function findNextHuntTarget()
  local target = lasthunttarget or ""
  local targetimportance = 99
  for k, v in pairs(extermlist) do
    if findkey(roomstufflist, k) then
      local denizenPriority = targetPriorityList[v[1]]
      if
        type(denizenPriority) == "number" or
        (type(denizenPriority) == "string" and denizenPriority ~= "ignored")
      then
        if k == lasthunttarget then
          target = lasthunttarget
          targetimportance = -1000
        end
        local numericPriority = tonumber(denizenPriority) or 99
        -- default to 99 if not a number
        if numericPriority < targetimportance then
          target = k
          targetimportance = numericPriority
        end
      end
    end
  end
  return target
end


function hasMoreHuntTargets(target)
  local hasMoreTargets = not (target == "") and not (table.is_empty(roomstufflist))
  myDebugEcho("white", string.format("Has more hunt targets: %s", tostring(hasMoreTargets)))
  return hasMoreTargets
end

function handleTargetsAndAttacks()
 
  local target = ""
 
  if findNextHuntTarget() ~= "" then
	  --hunttarget = hunttarget or ""
	  --if target ~= findNextHuntTarget() and hunttarget ~= target then
	  if target ~= findNextHuntTarget() then
	    target = findNextHuntTarget()
		send("settarget "..target)
		hunttarget = target
		updateWhoHere()
	  end
  
  end
  
  if not (systemLoaded) then
    return
  end
  
  if systemPaused then
    return
  end

  --if inslowcuringmode() then 
    --return 
  --end

  if balance_data.stunned.in_use then
    return
  end

  if target ~= "" then
    if hasMoreHuntTargets(target) then
      if shielded then
		handleShieldAttacks(target)
      else
	
        handleRegularAttacks(target)
        handleBattlerageAttacks(target)
      end
    else
      --myEcho("green", "Room Empty")
      if autohunting then
        moveToNextRoom()
        myDebugEcho("white", "Moving to next room")
      end
    end
  else
    --myEcho("green", "Room Empty")
    if autohunting then
      moveToNextRoom()
      myDebugEcho("white", "Moving to next room (no target found)")
    end
  end
end







function handleShieldAttacks(target)
    local class = myclass()
    local maxShieldAttackRetries = 10
    local shieldAttackCounter = 1 -- simple protection

    if class == "dragon" then
        class = string.match(gmcp.Char.Status.race, "%a+"):lower() .. " dragon"
    end

    if shieldAttackCounter > maxShieldAttackRetries then
        if DEBUG_MODE then cecho("\n<orange>Error: Shield attack function exceeded max retries.") end
        return
    end

    if not huntSettingsData[class] then
        if DEBUG_MODE then cecho("\n<orange>Error: Class not found in huntSettingsData: " .. class) end
        return
    end

    -- ✅ BATTLE RAGE SHIELD BREAK (pure send)
    if huntSettingsData[class]["rage shield break"] then
        for skill, data in pairs(bragelist[class]) do
            if data.enabled and data.type == "shield break" and battlerage() >= data.rage then
                if not balance_data.balance.in_use then
                    local targetCommand = data.command:gsub("@tar", target)
                    send(targetCommand)
                    if DEBUG_MODE then cecho("\n<green>[BRAGE] Sent pure shield break: " .. targetCommand) end
                else
                    if DEBUG_MODE then cecho("\n<yellow>[BRAGE] Balance not ready for rage shield break.") end
                end
                return
            end
        end
    end

    -- ✅ REGULAR SHIELD BREAKS (queued, keep existing logic)
    send("clearqueue eq")
    local regularCmd = huntSettingsData[class]["regular shield break"]

    if myclass() == "occultist" then
        local targetCommand = "queue add eq " .. regularCmd:gsub("@tar", target)
        commandSent = true
        addToQueue("eq", targetCommand)
        processQueue("eq")
        if DEBUG_MODE then cecho("\n<green>[BRAGE] Regular shield break added to queue: " .. targetCommand) end
    else
        local targetCommand = "queue add eqbal " .. regularCmd:gsub("@tar", target)
        commandSent = true
        addToQueue("eqbal", targetCommand)
        processQueue("eqbal")
        if DEBUG_MODE then cecho("\n<green>[BRAGE] Regular shield break added to queue: " .. targetCommand) end
    end

    shieldAttackCounter = 0
    return
end



function handleBattlerageAttacks(target)
    if shielded then
        if DEBUG_MODE then cecho("\n<yellow>[BRAGE] Target is shielded — not sending rage attack.") end
        return
    end

    local class = myclass()
    if class == "dragon" then
        class = string.match(gmcp.Char.Status.race, "%a+"):lower() .. " dragon"
    end

    if not bragelist[class] then return end

    local sortedSkills = {}

    for skill, data in pairs(bragelist[class]) do
        if data.enabled and type(data.type) == "number" and battlerage() >= data.rage then
            table.insert(sortedSkills, {
                priority = data.type,
                skill = skill,
                rage = data.rage,
                command = data.command,
            })
        end
    end

    table.sort(sortedSkills, function(a, b)
        if a.priority == b.priority then return a.rage > b.rage end
        return a.priority < b.priority
    end)

    for _, data in ipairs(sortedSkills) do
        if data.command and not balance_data.balance.in_use then
            local targetCommand = data.command:gsub("@tar", target)
            send(targetCommand)
            if DEBUG_MODE then cecho("\n<green>[BRAGE] Sent rage skill: " .. targetCommand) end
            return
        end
    end
end







-- Main function to handle regular hunting attacks.
function handleRegularAttacks(target)
    local class = myclass()
    local targetCommand = ""

    if class == "dragon" then
        class = string.match(gmcp.Char.Status.race, "%a+"):lower() .. " dragon"
    end

    -- Debugging and safeguard
    if not huntSettingsData[class] then
        if DEBUG_MODE then cecho("\n<red>Error: Class not found in huntSettingsData: "..class) end
        return
    end

    --send("clearqueue eqbal")

    -- Validate regular attack configuration
    if huntSettingsData[class]["regular attack"] then
		expandAlias("mstop")
        targetCommand = "queue add eqbal " .. huntSettingsData[class]["regular attack"]
		
    else
        cecho("\n<cyan>Configure Regular Hunt Attack (hunt configure)")
        return
    end

    -- Substitute target placeholder and check queue

    -- Check if the command has already been sent
    if commandSent then
      --  if DEBUG_MODE then cecho("\n<yellow>Command already sent, waiting for balance...") end
        return  -- Exit function to prevent sending the command again
    end

    -- Implement queue check
    if targetCommand and not isCommandInQueue("eqbal", targetCommand) then

        -- Mark the command as sent
        commandSent = true

        -- Add the command to the queue and process it
        addToQueue("eqbal", targetCommand)
        processQueue("eqbal")



        if DEBUG_MODE then cecho("\n<green>Command added to queue: "..targetCommand) end
    else
        if DEBUG_MODE then cecho("\n<yellow>Command already in queue or invalid: ".. targetCommand) end
    end

    return
end

 local hp = PLAYER:healthData()
 local mp = PLAYER:manaData()
 local hpPercent = hp.current / hp.total
 local mpPercent = mp.current / mp.total

 -- Recovery casting
  if huntRecovering --[[and not retreatCooldown]] then
    if not isOffBalance and (hpPercent < 0.95 or mpPercent < 0.95) then
      if hpPercent < mpPercent then
        cecho("\n<green>[RECOVERY] Flinging Magician for health during retreat.")
        TAROT:flingCard("magician", "me")
      else
        cecho("\n<cyan>[RECOVERY] Flinging Priestess for mana during retreat.")
        TAROT:flingCard("priestess", "me")
      end
    end
  end

registerAnonymousEventHandler("mmapper arrived", function()
  if not (huntRecovering and shouldRecover and hunting and autohunting) then return end

  local route = routedb[selectedroute]
  if not route or huntingpointer > #route then
    cecho("<gray>[WARN] Invalid route or huntingpointer beyond bounds. Aborting arrival logic.")
    return
  end

  local currentRoom = tonumber(gmcp.Room.Info.num)
  local expectedStep = route[huntingpointer]
  local expectedRoom = expectedStep and tonumber(expectedStep[2])

  if currentRoom == expectedRoom then
    cecho("\n<green>[HUNT] Mapper has arrived at correct recovery target.")

    huntRecovering = false
    justmoved = ""
    requestedhuntstep = false
    hunttarget = ""
    commandSent = false

    tempTimer(0.2, function()
      huntNext()
    end)
  else
    if expectedRoom and currentRoom then
      if isPrompt() then
        cecho(string.format("\n<orange>[WARN] Mapper arrived, but not in expected room (%s). Current: %s", expectedRoom, currentRoom))
      end
    else
      if isPrompt() then
        cecho("\n<orange>[WARN] Mapper arrived, but expectedRoom or currentRoom was nil.")
      end
    end
  end
end)




function huntNext()
  if not hunting then return end

  local currentRoom = tonumber(gmcp.Room.Info.num)
  local nextStep = routedb[selectedroute] and routedb[selectedroute][huntingpointer]
  local expectedRoom = nextStep and tonumber(nextStep[2])

  -- Pointer sanity check
  --if expectedRoom and currentRoom == expectedRoom then
    --cecho(string.format("\n<gray>[DEBUG] Already at hunting target room (%s). Advancing pointer.", currentRoom))
    --huntingpointer = huntingpointer + 1
    --tempTimer(0.2, function()
    --  huntNext()
   -- end)
    --return
  --end

  -- Normal flow
  if not isAloneInRoom() then
    if not(table.contains(myaffs, "blackout")) then
      myEcho("red", "People Here - Move to Next Room")

      if autohunting then
        moveToNextRoom()
        if DEBUG_MODE then myDebugEcho("white", "Moving to next room") end
      end
    end
  else
    if not huntResuming then
      huntResuming = true

      tempTimer(0.2, function()
        handleTargetsAndAttacks()
        huntResuming = false
      end)
    end

    myDebugEcho("white", "Handling targets and attacks")
  end
end



-- Function to handle the end of a hunting route
function endHuntingRoute(route)
  hunting = false
  cecho("\n<white>(<gold>Hunt<white>):<red> Hunting Disabled")
  autohunting = false
  cecho("\n<white>(<gold>Hunt<white>):<red> Auto Hunting Disabled")
  cecho("\n<yellow>hunt route " .. route .. " ended")
end


-- Function to print denizen priority list
function printDenizenPriorityList(area)
  local area = area or gmcp.Room.Info.area
  currentPriorityArea = area -- Set the current priority area
  cecho("\n<green>" .. area .. " - Priority List")
  cechoLink(
    " <red>(i) ",
    function()
      printAreaHuntList()
    end,
    "Show Area Ignore List",
    true
  )
  echo("\n")
  local denizens = targetMasterList[area] or {}
  -- Create a table to store denizens sorted by priority and name
  local sortedDenizens = {}
  local ignoredDenizens = {}
  for denizen, priority in pairs(denizens) do
    if priority == "ignored" then
      table.insert(ignoredDenizens, denizen)
    elseif priority ~= "hidden" then
      -- Exclude denizens with priority "hidden"
      table.insert(sortedDenizens, {name = denizen, priority = tonumber(priority)})
    end
  end
  -- Sort the denizens by priority and name
  table.sort(
    sortedDenizens,
    function(a, b)
      if a.priority == b.priority then
        return a.name < b.name
      else
        return a.priority < b.priority
      end
    end
  )
  -- Print the sorted list
  for _, denizenData in ipairs(sortedDenizens) do
    local denizen = denizenData.name
    local priority = denizenData.priority
    cechoLink(
      " <cyan>(+) ",
      function()
        setDenizenPriority(denizen, "raise")
      end,
      "Raise Priority",
      true
    )
    cechoLink(
      " <cyan>(-) ",
      function()
        setDenizenPriority(denizen, "lower")
      end,
      "Lower Priority",
      true
    )
    cechoLink(
      " <red>(i) ",
      function()
        setDenizenPriority(denizen, "ignore")
      end,
      "Set to Ignore",
      true
    )
    if priority then
      cecho(" <white>[<green>" .. priority .. "<white>] " .. denizen .. "\n")
    else
      cecho(" " .. denizen .. "\n")
    end
  end
  -- Print ignored denizens last
  for _, denizen in ipairs(ignoredDenizens) do
    cechoLink(
      " <cyan>(+) ",
      function()
        setDenizenPriority(denizen, "raise")
      end,
      "Raise Priority",
      true
    )
    cechoLink(
      " <cyan>(-) ",
      function()
        setDenizenPriority(denizen, "lower")
      end,
      "Lower Priority",
      true
    )
    cechoLink(
      " <red>(i) ",
      function()
        setDenizenPriority(denizen, "ignore")
      end,
      "Set to Ignore",
      true
    )
    cecho(" <white>[<red>i<white>] " .. denizen .. "\n")
  end
end




function printAreaHuntList()
  -- Create a sorted list of areas
  local sortedAreas = {}
  for area, _ in pairs(targetMasterList) do
    table.insert(sortedAreas, area)
  end
  table.sort(sortedAreas)

  echo("\n")
  cecho("<green>Area Hunt List (click to ignore)\n")

  -- Iterate through sorted areas
  for _, area in ipairs(sortedAreas) do
    local isIgnored = table.contains(areaIgnoreList, area)
    if not isIgnored then
      cechoLink(
        " <green>(i) ",
        function()
          toggleIgnoreArea(area)
        end,
        "Ignore " .. area,
        true
      )
    else
      cechoLink(
        " <red>(i) ",
        function()
          toggleIgnoreArea(area)
        end,
        "Ignore " .. area,
        true
      )
    end
    --open area by area name, so we can toggle to ignore prios
    cechoLink(
      "<white>(+) ",
      function()
        printDenizenPriorityList(area)
      end,
      "Open list for " .. area,
      true
    )
    cecho("<green>" .. area:title() .. "\n")
  end
end


-- Function to toggle ignore status for an area

function toggleIgnoreArea(area)
  if table.contains(areaIgnoreList, area) then
    -- Remove from ignore list
    --table.remove(areaIgnoreList, table.index_of(areaIgnoreList, area))
    removeElement(areaIgnoreList, area)
    myEcho("red","Removed from Hunt Ignore list: "..area)
  else
    -- Add to ignore list
    --table.insert(areaIgnoreList, area)
    setIgnoreArea(area)
    myEcho("green","Added to Hunt Ignore list: "..area)
  end
  -- Save areaIgnoreList
  saveAreaIgnoreList()
  -- Refresh the area list
  -- printAreaHuntList()
  -- Print denizen priority list
  -- printDenizenPriorityList()
end

-- Function to set area to ignore

function setIgnoreArea(area)
  -- If area not already in the list
  if not table.contains(areaIgnoreList, area) then
    -- Add area to ignore list
    table.insert(areaIgnoreList, area)
  end
  
end

function setDenizenPriority(denizen, action)
  local area = gmcp.Room.Info.area

  -- Check if the area matches the current priority area
  if area ~= currentPriorityArea then
    cecho("<red>Error: You are not currently in the area for this priority list.\n")
    return
  end

  targetMasterList[area] = targetMasterList[area] or {}
  if action == "raise" then
    if targetMasterList[area][denizen] == "ignored" then
      local lowestPriority = getLowestPriority(targetMasterList[area]) + 1
      targetMasterList[area][denizen] = tostring(lowestPriority)
    else
      targetMasterList[area][denizen] =
        math.max(tonumber(targetMasterList[area][denizen] or 1) - 1, 1)
    end
  elseif action == "lower" then
    if targetMasterList[area][denizen] == "ignored" then
      local lowestPriority = getLowestPriority(targetMasterList[area]) + 1
      targetMasterList[area][denizen] = tostring(lowestPriority)
    else
      targetMasterList[area][denizen] = tostring(tonumber(targetMasterList[area][denizen] or 0) + 1)
    end
  elseif action == "ignore" then
    if targetMasterList[area][denizen] == "ignored" then
      targetMasterList[area][denizen] = "hidden"
    else
      targetMasterList[area][denizen] = "ignored"
    end
  end

  saveTargetMasterList()
  updateDenizenPriorities()
  echo("\n\n")
  printDenizenPriorityList()
end




-- Function to find the lowest priority in a given area

function getLowestPriority(areaList)
  local lowestPriority = math.huge
  for _, priority in pairs(areaList) do
    if type(priority) == "number" then
      lowestPriority = math.min(lowestPriority, priority)
    end
  end
  return lowestPriority
end

-- Function to get the lowest priority in the targetMasterList

function getLowestPriority(targetList)
  local lowestPriority = math.huge
  for _, priority in pairs(targetList) do
    if type(priority) == "number" then
      lowestPriority = math.min(lowestPriority, priority)
    end
  end
  -- If lowestPriority is still set to math.huge, return 1 as the default
  return lowestPriority ~= math.huge and lowestPriority or 1
end

-- Update your local targetPriorityList based on the updated targetMasterList

function updateDenizenPriorities()
  -- Load targetMasterList
  loadTargetMasterList()
  -- Set values for the current area to targetPriorityList
  targetPriorityList = targetMasterList[gmcp.Room.Info.area] or {}
  
  if table.is_empty(targetPriorityList) then
    setTargetMasterList()
  end
end



function setHuntSettings(type, cmd)
  -- Script body
  local command = cmd
  local class = gmcp.Char.Status.class:lower():trim()
  -- Ensure lowercase for consistency
  --if string.match(gmcp.Char.Status.race, "Dragon") then
  -- class = "Dragon"
  --end
  -- Check if the class entry exists, if not, initialize it
  if not huntSettingsData[class] then
    huntSettingsData[class] = {}
  end
  -- Check if @tar is at the end of the string
  if string.match(command, "@tar$") then
    -- Replace @tar with "..target"
    attackCommand = string.gsub(command, "@tar$", '" .. target')
  else
    -- Replace @tar with "..target.." if it's followed by more characters
    attackCommand = string.gsub(command, "@tar", '" .. target .. "')
  end
  -- Update the huntSettingsData
  if type == "regular attack" then
    huntSettingsData[class]["regular attack"] = command
    cecho("\n<green>You set your regular attack command succesfully")
  end
  if type == "regular shield break" then
    myDebugEcho("white", class)
    myDebugEcho("white", command)
    huntSettingsData[class]["regular shield break"] = command
    cecho("\n<green>You set your regular shield break command succesfully")
  end
  if type == "rage shield break" then
    if command == "yes" then
      huntSettingsData[class]["rage shield break"] = true
    else
      huntSettingsData[class]["rage shield break"] = false
    end
    cecho("\n<green>You set your hunt rage shield command succesfully")
  end
  saveHuntSettings()
end

function setHuntSettingsData()

	local class = myclass()
	if class == "dragon" then
		class = string.match(gmcp.Char.Status.race, "%a+"):lower() .. " dragon"
	end

	-- Append the command to the command line for easy user configuration.
	-- appendCmdLine(text)
	cecho("\n<green>Hunt Settings\n")

	-- Configure regular attack
	cechoLink(
	  " <cyan>(+) ",
	  function()
		clearCmdLine()
		appendCmdLine("hunt regular attack")
	  end,
	  "click to set regular hunt attack",
	  true
	)
	local regularAttack = (huntSettingsData[class] and huntSettingsData[class]["regular attack"]) or "<red>{setup regular attack}"
	cecho("Configure regular attack") 
	cecho("<white> - Current: <cyan>" .. regularAttack .. "\n")

	-- Configure regular shield break
	cechoLink(
	  " <cyan>(+) ",
	  function()
		clearCmdLine()
		appendCmdLine("hunt regular shield break")
	  end,
	  "click to set regular shield break",
	  true
	)
	local regularShieldBreak = (huntSettingsData[class] and huntSettingsData[class]["regular shield break"]) or "<red>{setup shield break}"
	cecho("Configure regular shield break")
	cecho("<white> - Current: <cyan>" .. regularShieldBreak .. "\n")

	-- Configure rage shield break
	cechoLink(
	  " <cyan>(+) ",
	  function()
		clearCmdLine()
		appendCmdLine("hunt rage shield break")
	  end,
	  "click to set shield break with rage",
	  true
	)
	local rageShieldBreak = (huntSettingsData[class] and huntSettingsData[class]["rage shield break"]) and "<green>Yes." or "<red>No."
	cecho("Configure rage shield break (yes or no)")
	cecho("<white> - Current: " .. rageShieldBreak .. "\n")

	echo("\n")
end


--return battlerage

function battlerage()
  return tonumber(string.match(gmcp.Char.Vitals.charstats[2], "%d+"))
end

function huntStart()
  hunting = true
  autohunting = autohunting or false
  systemLoaded = true
  systemPaused = false
  lasthunttarget = ""
  requestedhuntstep = false
  send("put gold in pack")
  if myclass() == "serpent" then
    send("summon treesnake inventory")
  end
  expandAlias("inra")
  if autohunting then
    huntNext()
  end
end

-- Save targetMasterList to a file

function saveTargetMasterList()
	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
    local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "huntmasterlist.lua"
	ensureFileExists(baseDir, filename, "save", targetMasterList)
end

-- Load targetMasterList from a file

function loadTargetMasterList()
    local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
	local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "huntmasterlist.lua"
	ensureFileExists(baseDir, filename, "load", targetMasterList)
end

-- Save areaIgnoreList to a file

function saveAreaIgnoreList()
    local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
	local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "areaignorelist.lua"
	ensureFileExists(baseDir, filename, "save", targetMasterList)
end

-- Load areaIgnoreList from a file

function loadAreaIgnoreList()
    local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
	local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "areaignorelist.lua"
	ensureFileExists(baseDir, filename, "load", targetMasterList)
end

-- Save huntSettingsData to a file

function saveHuntSettings()
    local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
	local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "huntsettings.lua"
	ensureFileExists(baseDir, filename, "save", targetMasterList)
end

-- Load huntSettingsData from a file

function loadHuntSettings()
    local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
	local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
	local filename = "huntsettings.lua"
	ensureFileExists(baseDir, filename, "load", targetMasterList)
end

function setTargetMasterList()
if not targetMasterList or targetMasterList == "" or table.is_empty(targetMasterList) then
targetMasterList =  
  {
    Ashtan = {},
    Cyrene = {},
    Targossas = {},
    Mhaldor = {},
    Eleusis = {},
    Hashan = {},
    Annwyn =
      {
        ["Balorr, Chieftain of the Fomori"] = "ignored",
        ["Faylinn, Lady of Unsidhe Court"] = "ignored",
        ["Gwyllion, the Swamp Crone"] = "ignored",
        ["a Fomori of Unsidhe"] = "ignored",
        ["a crazed kelpie"] = "ignored",
        ["a fairy Knight of Sidhe"] = "ignored",
        ["a fairy Lady of Sidhe"] = "ignored",
        ["a fairy mistress"] = "ignored",
        ["a fiendish nightmare"] = "ignored",
        ["a frenzied bloodworm"] = "ignored",
        ["a lake fairy"] = "ignored",
        ["a swamp dweller"] = "ignored",
        ["a wild kelpie"] = "ignored",
        ["an Unsidhe Banshee"] = "ignored",
      },
    ["Brarra, the mighty volcano"] =
      {["a greater fire elemental"] = "ignored", ["a lesser firestorm elemental"] = "ignored"},
    ["Brurra, the southern volcano"] = {["a fiery ashhawk"] = "ignored"},
    ["Clockwork Isle"] =
      {
        ["Tick, the clockwork man"] = "ignored",
        ["a drudge goon"] = "ignored",
        ["a suit of guardian armour"] = "ignored",
        ["a wire-frame man"] = "ignored",
        ["an animated porcelain doll"] = "ignored",
      },
    Colchis =
      {
        ["Frewynne, the Warrior Chieftess"] = "ignored",
        ["Siathana, the Healer"] = "ignored",
        ["Thorlis, the Warrior Chieftain"] = "ignored",
        ["Vray, a fortress servant"] = "ignored",
        ["a Colchian warrior"] = "ignored",
        ["a Colchian warrioress"] = "ignored",
        ["a cloaked assassin"] = "ignored",
      },
    ["Cor Triphyn"] =
      {
        ["a clattering skeleton"] = "ignored",
        ["a colossal, hulking ghoul"] = "ignored",
        ["a horrendous ghoul"] = "ignored",
        ["a luminescent ghost"] = "ignored",
        ["a rotting zombie"] = "ignored",
        ["a smoke-wreathed ictheli"] = "ignored",
        ["a transparent, glowing wight"] = "ignored",
        ["an Elite Death Knight"] = "ignored",
        ["an intensely bright wisp"] = "ignored",
      },
    ["Eirenwaar Island"] = {["a black tailed doe"] = "ignored"},
    ["First Circle of Nur"] =
      {["a celestial spider"] = "ignored", ["an ethereal caterpillar"] = "ignored"},
    ["Forest Watch"] = {["a slugbeast"] = "ignored"},
    ["Garash's Grief"] =
      {
        ["a dust elemental"] = "ignored",
        ["a greater earth elemental"] = "ignored",
        ["a lesser earth elemental"] = "ignored",
        ["a stone giant"] = "ignored",
      },
    ["Green Lake"] =
      {
        ["a large fox"] = "ignored",
        ["a massive bear"] = "ignored",
        ["a monstrous skolef"] = "ignored",
      },
    ["Grukai Swamp"] =
      {
        ["a bunyip"] = "ignored",
        ["a crocodile"] = "ignored",
        ["a giant leech"] = "ignored",
        ["a giant puffball"] = "ignored",
        ["a mud urchin"] = "ignored",
        ["a multicoloured boa constrictor"] = "ignored",
        ["a putrid green crab"] = "ignored",
        ["a reedy green buom"] = "ignored",
        ["a school of vicious piranha"] = "ignored",
        ["a serpentine tssalo"] = "ignored",
        ["a sinister glubber"] = "ignored",
        ["a tentacled polyp"] = "ignored",
        ["a thornback frog"] = "ignored",
        ["a transparent cahno"] = "ignored",
        ["a vicious dulosi majorus"] = "ignored",
        ["a vicious swarm of acacidic ants"] = "ignored",
        ["an aggressive dulosi minorus"] = "ignored",
        ["an azure koparfish"] = "ignored",
        ["an energetic red turtle"] = "ignored",
        ["an enormous anaconda"] = "ignored",
      },
    ["Haila-ele"] =
      {["a waterbound Forsaken"] = "ignored", ["an inundated quicksilver ogre"] = "ignored"},
    Isaia =
      {
        ["Yiastel Tenye"] = "ignored",
        ["a giant zelahia"] = "ignored",
        ["a moenai"] = "ignored",
        ["a silvery eel"] = "ignored",
        ["a snow-white ennelin"] = "ignored",
        ["an amorak"] = "ignored",
      },
    Istarion =
      {
        ["Arafaile, priestess of Life"] = "ignored",
        ["Cervantha, the Caretaker"] = "ignored",
        ["Dalendra Asgarai, Revered Counsellor"] = "ignored",
        ["Eriador, the Tsol'dasi merchant master"] = "ignored",
        ["Hethern Silwenil, Revered Counsellor"] = "ignored",
        ["Khurthia, Sword Ascendant"] = "ignored",
        ["Maal'ryn Asgarai, Outrider Ascendant"] = "ignored",
        ["Oraiya Silwenil"] = "ignored",
        ["Saldesari Elisanil, Warren Ascendant"] = "ignored",
        ["Santhrar, a young prince"] = "ignored",
        ["Sariontari, Queen of Istarion"] = "ignored",
        ["Shantuir, Watch Ascendant"] = "ignored",
        ["Sindrastar Nerrinth, the High Counsellor"] = "ignored",
        ["Tsui'zhir, Whisper Ascendant"] = "ignored",
        ["Vargalast Megurun, Revered Counsellor"] = "ignored",
        ["a Tsol'dasi merchant"] = "ignored",
        ["a Tsol'dasi villager"] = "ignored",
        ["a grey-haired Tsol'dasi"] = "ignored",
        ["a hooded Tsol'dasi villager"] = "ignored",
        ["a joyful Tsol'dasi villager"] = "ignored",
        ["a knight of the King's Guard"] = "ignored",
        ["a priestess of Life"] = "ignored",
        ["a studious Tsol'dasi"] = "ignored",
        ["a sword spider"] = "ignored",
        ["a sword spider outrider"] = "ignored",
        ["a sword spiderling"] = "ignored",
        ["a watch spider"] = "ignored",
        ["a watch spider outrider"] = "ignored",
        ["a watch spiderling"] = "ignored",
        ["a whisper spider"] = "ignored",
        ["a whisper spider outrider"] = "ignored",
        ["a whisper spiderling"] = "ignored",
        ["an acolyte of Life"] = "ignored",
        ["an astrologer"] = "ignored",
        ["an austere Tsol'dasi"] = "ignored",
        ["an extravagantly dressed Tsol'dasi"] = "ignored",
      },
    Jaru = {["Mayor Cotridge"] = "ignored"},
    ["Kkractle's Grasp"] =
      {["a monstrous lava slime"] = "ignored", ["a nascent lava slime"] = "ignored"},
    ["Kunapi Island"] =
      {
        ["a feral cat"] = "ignored",
        ["a feral dog"] = "ignored",
        ["a giant sea serpent"] = "ignored",
        ["a green-plated sand crab"] = "ignored",
        ["a green-spotted stingray"] = "ignored",
        ["a redfin tuna"] = "ignored",
      },
    ["Lake Narcisse"] =
      {["Gaderian, the mage of Narcisse"] = "ignored", ["Laposi, leader of the Hanai"] = "ignored"},
    ["Legion of Flame: Forward Command"] =
      {["a hulking confrag"] = "ignored", ["the Ear of Kkractle"] = "ignored"},
    ["Maim's Mansion"] =
      {
        ["Agnes Mooch"] = "ignored",
        ["Lindsey Coolsey"] = "ignored",
        ["Nanny Scoggs"] = "ignored",
        ["Vera Shackles"] = "ignored",
      },
    ["Manara Burrow"] =
      {
        ["Ala, Lirthak's wife"] = 1,
        ["Bissa, a Mingruk waterbearer"] = 2,
        ["Ebra, Matriarch of the Mingruk"] = 2,
        ["Glartharg, a gnoll commander"] = 1,
        ["Hrorknar, the gnoll smith"] = 1,
        ["Iofio, a Mingruk cook"] = "2",
        ["Lirthak, Chief of the gnoll"] = 1,
        ["Mawezel, grandson of Ebra"] = 2,
        ["Ograk, a gnoll Sergeant"] = 1,
        ["Thriel, an angry Mingruk miner"] = 2,
        ["Tuomo, an elder Mingruk"] = 2,
        ["Uhtan, the head farmer"] = 2,
        ["Vorlatan, a Mingruk farmer"] = 2,
        ["Vorluck, Captain of the gnoll guard"] = 1,
        ["a Mingruk caregiver"] = 2,
        ["a burly Mingruk slave"] = 2,
        ["a cowering Mingruk miner"] = 2,
        ["a dirt-covered earthworm"] = 4,
        ["a female tsol'aa pleasure slave"] = 4,
        ["a flail-wielding gnoll sentry"] = 1,
        ["a grook slave"] = "4",
        ["a hard-working Mingruk farmer"] = 2,
        ["a human slave"] = 4,
        ["a smirking gnoll slaver"] = 2,
        ["a sneering gnoll guard"] = 1,
        ["a vicious gnoll soldier"] = 1,
        ["a water-bearing Mingruk woman"] = 2,
        ["an apathetic gnoll sentinel"] = 1,
        ["an arrogant gnoll woman"] = 1,
        ["an atavian slave"] = 4,
      },
    Moghedu =
      {
        ["Commander Kalesh"] = "ignored",
        ["Deban, the mhun barkeep"] = "ignored",
        ["Guard Captain Chelak"] = "ignored",
        ["Guard Captain Darion"] = "ignored",
        ["Guard Captain Haedra"] = "ignored",
        ["Master Scout Madira"] = "ignored",
        ["Master Tarrin"] = "ignored",
        ["Mhunk, an inattentive mhun miner"] = "ignored",
        ["Sir Mertyn, Grand Champion of Moghedu"] = "ignored",
        ["Sir Temelin, Knight Commander of Moghedu"] = "ignored",
        ["a master mhun demolitionist"] = "ignored",
        ["a master mhun miner"] = "ignored",
        ["a mhun archer"] = "ignored",
        ["a mhun bodyguard"] = "ignored",
        ["a mhun conjuror"] = "ignored",
        ["a mhun demolitionist"] = "ignored",
        ["a mhun guard"] = "ignored",
        ["a mhun guard trainee"] = "ignored",
        ["a mhun knight"] = "ignored",
        ["a mhun labourer"] = "ignored",
        ["a mhun miner"] = "ignored",
        ["a mhun smelter"] = "ignored",
        ["an elite mhun keeper"] = "ignored",
        ["the Great Mhunna"] = "ignored",
      },
    ["New Thera"] = {["Lyaeus, the travelling bard"] = "ignored"},
    Nimick = {["Dr. Kortoxian"] = "ignored", ["a cave ecalith"] = "ignored"},
    ["Quartz Peak"] =
      {
        ["Burgam, the hunter"] = "ignored",
        ["Gnral, the taryen chieftain"] = "ignored",
        ["Grela, a pregnant ursu"] = "ignored",
        ["Kurgo, the Ursu chief"] = "ignored",
        ["Leesha, the ursu packmother"] = "ignored",
        ["Toogar, the ursu shaman"] = "ignored",
        ["Trag, the taryen wise man"] = "ignored",
        ["Turga, the ursu midwife"] = "ignored",
        ["a taryen man"] = "ignored",
        ["an ursu man"] = "ignored",
        ["the wrogroth"] = "ignored",
      },
    ["Radak's Hold"] = {["a Murai assassin"] = "ignored"},
    Riparium =
      {
        ["a dusky brown crayfish"] = "ignored",
        ["a fearsome tiger shark"] = "ignored",
        ["a giant octopus"] = "ignored",
        ["a jet-black manta"] = "ignored",
        ["a large red crab"] = "ignored",
        ["a man-eating shark"] = "ignored",
        ["a moray eel"] = "ignored",
        ["a school of fish"] = "ignored",
      },
    ["Sirocco Fortress"] =
      {
        ["Bertha the troll"] = "ignored",
        ["Duchess Alorina"] = "ignored",
        Gerda = "ignored",
        ["Jadorno, a cloaked nobleman"] = "ignored",
        ["a bearded cook"] = "ignored",
        ["a fortress guardsman"] = "ignored",
        ["a huge, writhing serpent"] = "ignored",
        ["a keen-eyed archer"] = "ignored",
        ["a knight of the Siroccian Order"] = "ignored",
        ["a proud ducal guard"] = "ignored",
        ["a shady-looking man"] = "ignored",
        ["a stout footsoldier"] = "ignored",
        ["an alert watchman"] = "ignored",
        ["the Captain of the Guard"] = "ignored",
        ["the fortress steward"] = "ignored",
      },
    ["Sllshya's Maw"] =
      {
        ["a greater air elemental"] = "ignored",
        ["a lesser air elemental"] = "ignored",
        ["a lesser water elemental"] = "ignored",
      },
    ["Squall Cleft"] =
      {
        ["a hydroform beast"] = "ignored",
        ["a hydroform brute"] = "ignored",
        ["a hydroform colossus"] = "ignored",
        ["a hydroform fawn"] = "ignored",
        ["a hydroform monstrosity"] = "ignored",
        ["a hydroform pup"] = "ignored",
        ["a hydroform stalker"] = "ignored",
        ["an inky black cocoon"] = "ignored",
      },
    ["Suliel Island"] =
      {
        ["Vhilen, the head fisherman"] = "ignored",
        ["a docile tundra wolf"] = "ignored",
        ["a greater yawo"] = "ignored",
        ["a hardy reindeer"] = "ignored",
        ["a hulking omatu"] = "ignored",
        ["a lokela beast"] = "ignored",
        ["a malevolent iridwyn"] = "ignored",
        ["a playful young boy"] = "ignored",
        ["a playful young girl"] = "ignored",
        ["a polar bear"] = "ignored",
        ["a silvery normine"] = "ignored",
        ["a sluggish yawo"] = "ignored",
        ["a speckled harp seal"] = "ignored",
        ["a statue of an ice golem"] = "ignored",
        ["a village woman"] = "ignored",
        ["a warmly dressed fisherman"] = "ignored",
      },
    ["Tapoa Island"] =
      {
        ["a blackfin shark"] = "ignored",
        ["a blue-plated sand crab"] = "ignored",
        ["a female ape"] = "ignored",
        ["a giant jellyfish"] = "ignored",
        ["a giant sandworm"] = "ignored",
        ["a large red kangaroo"] = "ignored",
        ["a ravenous vulture"] = "ignored",
        ["a scraggly dingo"] = "ignored",
        ["the Vultubus"] = "ignored",
        ["the king ape"] = "ignored",
      },
    ["Tenwat Prison"] =
      {
        ["Alsilan, the condemned"] = "ignored",
        ["Lican, a mad occultist"] = "ignored",
        ["Saunders, the prison warden"] = "ignored",
        ["a berserk prisoner"] = "ignored",
        ["a crazed prison guard"] = "ignored",
        ["a creaking rust golem"] = "ignored",
        ["a howling blood mastiff"] = "ignored",
        ["a massive crimson orb"] = "ignored",
        ["a pair of grasping hands"] = "ignored",
        ["a pulsing artery"] = "ignored",
        ["a screaming head"] = "ignored",
        ["a wall of limbs"] = "ignored",
      },
    ["The Alcazar"] =
      {
        ["Archoura, Captain of the Guard"] = "ignored",
        ["a meek servant"] = "ignored",
        ["an emaciated prisoner"] = "ignored",
      },
    ["the bog of Ashtan"] = {},
    ["the Sunderlands"] = {},
    ["The Caverns of Dominar"] =
      {
        ["a fire abomination"] = "ignored",
        ["a flaming bat"] = "ignored",
        ["a goblin guard"] = "ignored",
        ["a monstrous construct"] = "ignored",
      },
    ["The Elemental Embassy"] = {["a lesser air elemental"] = "ignored"},
    ["The Gulf of Nilakantha"] =
      {
        ["a gigantic sea spider"] = "ignored",
        ["a hammerhead shark"] = "ignored",
        ["a massive jellyfish"] = "ignored",
        ["a monstrous septacean"] = "ignored",
        ["a redfin tuna"] = "ignored",
        ["a whiptail stingray"] = "ignored",
      },
    ["The Mirrorlands"] =
      {
        ["Icosse, Mirrored Ire"] = "ignored",
        ["a shade of magic"] = "ignored",
        ["a shade of might"] = "ignored",
        ["a shade of nature"] = "ignored",
      },
    ["The valley of the dread avian"] =
      {
        ["Aran'Kesh, the Fleshrender"] = "ignored",
        ["a giant crow"] = "ignored",
        ["a grim, ebony vulture"] = "ignored",
        ["a mature mountain wildcat"] = "ignored",
      },
    ["Tir Murann"] =
      {
        ["Ayod'nai, Whisperer of the All"] = "ignored",
        ["Battle Captain Miingruan"] = "ignored",
        ["Damek, Feranki Magelord"] = "ignored",
        ["Dynas, the gour trainer"] = "ignored",
        ["Ghaser, the Vertani cook"] = "ignored",
        ["Iayh, a mage of House Feranki"] = "ignored",
        ["Ohmut, the Vertan craftswoman"] = "ignored",
        ["Rakwor, the Vertani Barkeep"] = "ignored",
        ["Rohase, Captain of the Guard"] = "ignored",
        ["Ver'osy, the Vertani priestess"] = "ignored",
        ["Vewig, the Magelord of House Tsez"] = "ignored",
        ["a House Feranki mage"] = "ignored",
        ["a House Tsez air mage"] = "ignored",
        ["a Vertani guard"] = "ignored",
        ["a drunken Vertani"] = "ignored",
        ["a hulking striped moirah"] = "ignored",
        ["a massive xabat"] = "ignored",
        ["a scimitar-wielding Vertani soldier"] = "ignored",
      },
    ["Wegava Valley"] = {["the Mahk"] = "ignored"},
    ["Xhaiden Dale"] =
      {
        Veshina = "ignored",
        ["a colossal water strider"] = "ignored",
        ["a fierce black crane"] = "ignored",
        ["a huge swamp crocodile"] = "ignored",
        ["a wild caribou"] = "ignored",
      },
    Zanzibaar =
      {
        Abelsa = "ignored",
        ["Alsimhinda, Queen of Zanzibaar"] = "ignored",
        ["Djulsan, King of Zanzibaar"] = "ignored",
        ["Fimsirun, a foreign prince"] = "ignored",
        ["Lordan Colse"] = "ignored",
        ["Makran, an island trader"] = "ignored",
        Paedri = "ignored",
        ["Princess Qitala"] = "ignored",
        ["Semmor, the dhow-maker"] = "ignored",
        ["Silana, Siren of the Hoalanatha"] = "ignored",
        Vadoor = "ignored",
        ["Yuskah, the witchdoctor"] = "ignored",
        ["a Baarian tiger"] = "ignored",
        ["a bare-chested sailor"] = "ignored",
        ["a burly dockhand"] = "ignored",
        ["a ghost crab"] = "ignored",
        ["a giant tortoise"] = "ignored",
        ["a palace servant"] = "ignored",
        ["a red colobus"] = "ignored",
        ["a red-banded cobra"] = "ignored",
        ["a royal guard of Zanzibaar"] = "ignored",
        ["a sea nettle"] = "ignored",
        ["a silvery scombra"] = "ignored",
        ["a sleek mongoose"] = "ignored",
        ["a spotted porpoise"] = "ignored",
        ["a surly smuggler"] = "ignored",
        ["an elusive shapeshifter"] = "ignored",
        ["an island man"] = "ignored",
        ["an island woman"] = "ignored",
        ["an islander in a dhow"] = "ignored",
      },
    ["Zaphar Isle"] = {["a banana spider"] = "ignored"},
    ["a filthy goblin village"] =
      {
        ["a goblin boy"] = "ignored",
        ["a goblin chieftain"] = "ignored",
        ["a goblin girl"] = "ignored",
        ["a goblin guard"] = "ignored",
        ["a small goblin boy"] = "ignored",
        ["an elderly goblin"] = "ignored",
        ["an energetic goblin boy"] = "ignored",
        ["the goblin lieutenant"] = "ignored",
        ["the goblin matron"] = "ignored",
        ["the goblin shaman"] = "ignored",
      },
    ["a network of caves beneath New Thera"] =
      {
        ["Dakrol, the Swiftblade"] = "ignored",
        ["Isiva, the Blood Maiden"] = "ignored",
        ["Katzynn Fireforge"] = "ignored",
        ["Nevon Talkar"] = "ignored",
        ["a Qui'sas hunter"] = "ignored",
        ["a Quisalis guard"] = "ignored",
        ["a Quisalis overseer"] = "ignored",
        ["an Initiate of the Mark"] = "ignored",
        ["an elder Qui'sas"] = "ignored",
        ["the beast in the crypt"] = "ignored",
      },
    ["an Orcish outpost"] =
      {
        ["Gorblatt, the orc chieftain"] = "ignored",
        ["Gothmog, the orc witch doctor"] = "ignored",
        ["Grashna, the tanner"] = "ignored",
        ["Thrakma, the butcher"] = "ignored",
        ["a diminutive orc servant"] = "ignored",
        ["an orc bodyguard"] = "ignored",
        ["an orc soldier"] = "ignored",
        ["an orc woman"] = "ignored",
      },
    ["deep below the sea"] =
      {
        ["a coelacanth"] = "ignored",
        ["a duskfin tuna"] = "ignored",
        ["a giant hatchetfish"] = "ignored",
        ["a gigantic sea spider"] = "ignored",
        ["a herd of hippocampi"] = "ignored",
        ["a hideaway nautilus"] = "ignored",
        ["a hulking geryas"] = "ignored",
        ["a malevolent sea dragon"] = "ignored",
        ["a millstone fish"] = "ignored",
        ["a pale, four-fin ray"] = "ignored",
        ["a peppermint stripefish"] = "ignored",
        ["a redfin tuna"] = "ignored",
        ["a sea cucumber"] = "ignored",
        ["a serpentine merrow"] = "ignored",
        ["a spotted fangtooth"] = "ignored",
        ["a two-headed fish"] = "ignored",
        ["a whiskerknot skrei"] = "ignored",
        ["an ivory bloomshell turtle"] = "ignored",
      },
    ["somewhere in the Notic Ocean"] =
      {["a whitetip shark"] = "ignored", ["the ghost of a drowned sailor"] = "ignored"},
    ["the Aalen Forest"] =
      {
        ["Celaabi, the Tsol'aa Queen Mother"] = "ignored",
        ["Tu'eras, the Tsol'aa King"] = "ignored",
        ["a Tsol'aa ranger"] = "ignored",
        ["a disfigured merman"] = "ignored",
        ["a forest basilisk"] = "ignored",
        ["a hissing, mutated mermaid"] = "ignored",
        ["a monstrous squid"] = "ignored",
        ["a vicious, mutated mermaid"] = "ignored",
      },
    ["the Aeraithian Falls"] = {["Elnai, Elder of Aeraithia"] = "ignored"},
    ["the Ashen Blight"] =
      {
        ["a hulking confrag"] = "ignored",
        ["a lesser earth elemental"] = "ignored",
        ["a soldier of Kkractle"] = "ignored",
      },
    ["the Asterian Peninsula"] =
      {
        ["a blue heron"] = "ignored",
        ["a horned viper"] = "ignored",
        ["a scrub fox"] = "ignored",
        ["a young heron"] = "ignored",
      },
    ["the Azdun Catacombs"] =
      {
        ["Malvoc, the Unholy"] = "ignored",
        ["Rhuzios, the Mummy Lord"] = "ignored",
        ["Ulgase, the lich crone"] = "ignored",
        ["Underlord Dreyvos"] = "ignored",
        ["Underlord Seroth"] = "ignored",
        ["a cursed phantasm"] = "ignored",
        ["a decaying lich"] = "ignored",
        ["a flesh-eating slug"] = "ignored",
        ["a shambling zombie"] = "ignored",
        ["a vicious ghast"] = "ignored",
        ["an accursed skeleton"] = "ignored",
        ["an undead knight"] = "ignored",
        ["an unravelling mummy"] = "ignored",
      },
    ["the Azdun Dungeon"] =
      {
        ["Lachesis, the Spider Queen"] = "ignored",
        ["Ulgase, the lich crone"] = "ignored",
        ["Xylthus the Outcast"] = "ignored",
        ["Zsarachnor, the Vampire Lord"] = "ignored",
        ["a choke creeper"] = "ignored",
        ["a decaying lich"] = "ignored",
        ["a decaying zombie"] = "ignored",
        ["a flesh-eating slug"] = "ignored",
        ["a ghast"] = "ignored",
        ["a goblin ghoul"] = "ignored",
        ["a goblin sergeant"] = "ignored",
        ["a goblin soldier"] = "ignored",
        ["a goblin zombie"] = "ignored",
        ["a guardian spider"] = "ignored",
        ["a hill giant"] = "ignored",
        ["a hobgoblin warrior"] = "ignored",
        ["a huge pulsating spider"] = "ignored",
        ["a mhun worker"] = "ignored",
        ["a mummy"] = "ignored",
        ["a pale vampiress"] = "ignored",
        ["a revolting ghoul"] = "ignored",
        ["a vampire"] = "ignored",
        ["a wight"] = "ignored",
        ["a wraith"] = "ignored",
      },
    ["the Barony of Dun Valley"] =
      {
        ["Tap'choa, the orc chieftain"] = "ignored",
        ["Xulu, an orc witchdoctor"] = "ignored",
        ["a bighorn sheep"] = "ignored",
        ["a dangerous water snake"] = "ignored",
        ["a drunk orc"] = "ignored",
        ["a female orc"] = "ignored",
        ["a giant mud beetle"] = "ignored",
        ["a giant water strider"] = "ignored",
        ["a greyish green crocodile"] = "ignored",
        ["a large, fat hippo"] = "ignored",
        ["a mist wraith"] = "ignored",
        ["a mud crab"] = "ignored",
        ["a muscular mountain lion"] = "ignored",
        ["a plague rat"] = "ignored",
        ["a school of piranha"] = "ignored",
        ["a spinorthos"] = "ignored",
        ["a swamp dryad"] = "ignored",
        ["a warthog"] = "ignored",
        ["an enormous swamp wyvern"] = "ignored",
        ["an ogre bowman"] = "ignored",
        ["an ogre captain"] = "ignored",
        ["an ogre cook"] = "ignored",
        ["an ogre huntress"] = "ignored",
        ["an ogre knight"] = "ignored",
        ["an ogre sentry"] = "ignored",
        ["an orc archer"] = "ignored",
        ["an orc blacksmith"] = "ignored",
        ["an orc captain"] = "ignored",
        ["an orc cook"] = "ignored",
        ["an orc guard"] = "ignored",
        ["an orc sergeant"] = "ignored",
        ["an orc soldier"] = "ignored",
        ["an orc warrior"] = "ignored",
        ["the Great Bull Elephant"] = "ignored",
      },
    ["the Battlesite of Mourning Pass"] =
      {
        ["Commander Farista Errikale"] = "ignored",
        ["Commander Malrian Kyra"] = "ignored",
        ["Knight Commander Lord Ethran Rani"] = "ignored",
        ["a battered Ashtani lieutenant"] = "ignored",
        ["a bedraggled Ashtani foot soldier"] = "ignored",
        ["a dishevelled young squire"] = "ignored",
        ["a frightened young squire"] = "ignored",
        ["a heavily armoured warrior sylphid beetle"] = "ignored",
        ["a lost knight errant"] = "ignored",
        ["a proud knight errant"] = "ignored",
        ["a queen sylphid beetle"] = "ignored",
        ["a sturdy knight"] = "ignored",
        ["a writhing mass of larvae"] = "ignored",
        ["an injured knight"] = "ignored",
      },
    ["the Black Forest"] = {["a monstrous cave bat"] = "ignored"},
    ["the Caverns of Nuskuwe"] =
      {
        ["a Nuskuwen child"] = "ignored",
        ["a Nuskuwen hero"] = 1,
        ["a Nuskuwen man"] = 2,
        ["a Nuskuwen woman"] = 3,
        ["a crimson angler"] = 2,
        ["a crimson pyrapede"] = 2,
        ["a fire wyrm"] = 1,
        ["a lost child"] = "ignored",
        ["a pregnant wyrm"] = 2,
        ["a rock beetle"] = 3,
        ["a rock leech"] = 4,
        ["a worried mother"] = 3,
        ["a wyrm whelp"] = "ignored",
        ["a young magma wyvern"] = "ignored",
        ["an ancient wyrm"] = 3,
        ["the Chieftain of Nuskuwe"] = 1,
        ["the Wyrm Lord"] = "ignored",
      },
    ["the Caverns of Riagath"] =
      {
        Aline = "ignored",
        ["Elder Tilath"] = "ignored",
        Farshen = "ignored",
        Ikaride = "ignored",
        Kisheth = "ignored",
        ["Leiga, the Gyrog matriarch"] = "ignored",
        ["Munfawa, a hunchbacked troll"] = "ignored",
        Ninea = "ignored",
        Rinaga = "ignored",
        ["Rurogan, Lord of the Rucktawn"] = "ignored",
        ["Shial, shaman of the Gyrog"] = "ignored",
        Tannel = "ignored",
        ["Tylorga, Captain of the Guard"] = "ignored",
        ["Xifeni the Wise"] = "ignored",
        ["a burly troll guard"] = 1,
        ["a sturdy troll woman"] = 1,
        ["a gigantic angler fish"] = 1,
      },
    ["the Central Atrousian Jungle"] = {["a swarm of mosquitoes"] = "ignored"},
    ["the Central Vasnari Mountains"] =
      {
        ["a bloodthirsty jackdaw"] = "ignored",
        ["a disfigured ram"] = "ignored",
        ["a rabid grizzly bear"] = "ignored",
        ["an enormous cave bat"] = "ignored",
      },
    ["the Central Wilderness"] = {["the beast in the crypt"] = "ignored"},
    ["the City of Shala-Khulia"] =
      {
        ["Coametu, a Shala-Khulia guard"] = "ignored",
        ["Ma'luiztli, a Shala-Khulia guard"] = "ignored",
      },
    ["the Coastal Highway"] =
      {["a mounted Asteri knight"] = "ignored", ["a proud ducal guard"] = "ignored"},
    ["the Coterie of Clouds"] = {["a lesser fire elemental"] = "ignored"},
    ["the Creville Asylum"] =
      {
        ["Darien, the shock therapist"] = "ignored",
        ["Suire, a mauled, narcissistic siren"] = "ignored",
        ["Ulthor, the coroner"] = "ignored",
        ["Villinix, the herbalist"] = "ignored",
        ["Xzavien, the scientist"] = "ignored",
        ["a blind, knife-wielding woman"] = "ignored",
        ["a blood-spattered jester"] = "ignored",
        ["a burly troll dweller"] = "ignored",
        ["a cannibalistic lunatic"] = "ignored",
        ["a crawling Tsol'aa inmate"] = "ignored",
        ["a deranged rajamalan dweller"] = "ignored",
        ["a grinning imp"] = "ignored",
        ["a grotesque xorani inmate"] = "ignored",
        ["a hooded man"] = "ignored",
        ["a hulking bush of hogsweed"] = "ignored",
        ["a maniacal atavian inmate"] = "ignored",
        ["a mutated horkvali inmate"] = "ignored",
        ["a one-eyed, convulsing priest"] = "ignored",
        ["a ravenous troll inmate"] = "ignored",
        ["a restless, drugged druid"] = "ignored",
        ["a shady dealer"] = "ignored",
        ["a shivering dwarf with a dull pick axe"] = "ignored",
        ["a sneering psychopathic inmate"] = "ignored",
        ["a sullen atavian inmate"] = "ignored",
        ["a young shaman inmate"] = "ignored",
        ["an axe-wielding dwarven patient"] = "ignored",
      },
    ["the Dakhota Hills"] =
      {
        ["a massive gour"] = "ignored",
        ["a restless phantom"] = "ignored",
        ["a stitched adder"] = "ignored",
      },
    ["the Daoric Plains"] =
      {
        ["Khovsgol, the Black"] = "ignored",
        ["a majestic grey elephant"] = "ignored",
        ["a menacing henchman"] = "ignored",
        ["a surly horse thief"] = "ignored",
      },
    ["the Dardanic Grasslands"] =
      {
        ["a savannah grizzly"] = "ignored",
        ["a shaggy buffalo"] = "ignored",
        ["a woolly barmotez"] = "ignored",
      },
    ["the Darkenwood Forest"] =
      {
        ["Istishia, the Arachnoi Queen"] = "ignored",
        ["a dark arachnoi man"] = "ignored",
        ["a dark arachnoi woman"] = "ignored",
        ["a huge pulsating spider"] = "ignored",
        ["a midnight stag"] = "ignored",
      },
    ["the Den of the Quisalis"] =
      {
        Anasyd = "ignored",
        ["Baliar Blackthorne"] = "ignored",
        ["Dalvas Sareish"] = "ignored",
        ["Gil, the Quisalis Enforcer"] = "ignored",
        ["Jerak, Captain of the Guard"] = "ignored",
        ["Karinda Talkar"] = "ignored",
        ["Kimitia, a Quisalis Assassin"] = "ignored",
        ["Master Jotbla"] = "ignored",
        ["Mistress Livastra"] = "ignored",
        ["Sifri, the Quisalis Overseer"] = "ignored",
        ["Stefanos Bladesong"] = "ignored",
        ["Varenia, the Venomous"] = "ignored",
        ["Westriv Talkar"] = "ignored",
        Xerafel = "ignored",
        ["Yuroc, the Black Wing"] = "ignored",
        ["Zen'fi Haar'chen"] = "ignored",
        ["a Qui'sas assassin"] = "ignored",
        ["a Quisalis assassin"] = "ignored",
        ["a Quisalis guard"] = "ignored",
        ["a Quisalis sentry"] = "ignored",
        ["a cloaked assassin"] = "ignored",
        ["a deranged assassin"] = "ignored",
        ["a female mage"] = "ignored",
        ["a horrifying abomination"] = "ignored",
        ["a large hound"] = "ignored",
        ["a large wolf"] = "ignored",
        ["a mage"] = "ignored",
        ["a master assassin"] = "ignored",
        ["a scholar of Nishnatoba"] = "ignored",
        ["a trained war vulture"] = "ignored",
        ["a withered husk"] = "ignored",
        ["an Initiate of the Mark"] = "ignored",
        ["an apprentice assassin"] = "ignored",
        ["an elderly mage"] = "ignored",
        ["an enormous hound"] = "ignored",
      },
    ["the Dungeon of the Beastlords"] =
      {
        ["Bearnath, the Beast Cultist"] = "ignored",
        ["Glash, the three-headed cerberus"] = "ignored",
        ["Inish, the head cultist"] = "ignored",
        ["the Beastlord"] = "ignored",
      },
    ["the Eastern Shore"] =
      {
        ["a bare-chested pirate"] = "ignored",
        ["a barnacle encrusted oyster"] = "ignored",
        ["a king barracuda"] = "ignored",
        ["a white-winged sandpiper"] = "ignored",
      },
    ["the Eastern Wilderness"] =
      {["a blue-bottomed switchfly"] = "ignored", ["a king barracuda"] = "ignored"},
    ["the Fissure of Echoes"] =
      {
        ["a demented cannibal"] = "ignored",
        ["a glacial windviper"] = "ignored",
        ["a monstrous crystal spider"] = "ignored",
      },
    ["the Ghezavat Commune"] =
      {["a Skullsworn berserker"] = "ignored", ["a bearded Ghezavati man"] = "ignored"},
    ["the Granite Hills"] =
      {["a female hill giant"] = "ignored", ["a hill giant child"] = "ignored"},
    ["the Ilyrean Caves"] =
      {
        ["Ankuwan, the Watcher"] = "ignored",
        ["Derin, the sakuwat fisher"] = "ignored",
        ["Merkuwan, the skinner"] = "ignored",
        ["Molkuwan, the egg protector"] = "ignored",
        ["Solkuwan, an apprentice sakuwat hunter"] = "ignored",
        ["Yanath, the sakuwat cook"] = "ignored",
        ["a female sakuwat"] = "ignored",
        ["a large male sakuwat"] = "ignored",
        ["a sakuwat hatchling"] = "ignored",
        ["a sakuwat hunter"] = "ignored",
        ["a sakuwat ice warrior"] = "ignored",
        ["a sakuwat youngling"] = "ignored",
      },
    ["the Ilyrean Tundra"] =
      {
        ["a massive polar bear"] = "ignored",
        ["a tundra wolf"] = "ignored",
        ["a woolly mammoth"] = "ignored",
      },
    ["the Ioje compound"] = {["a brawny warrior slave"] = "ignored"},
    ["the Island of Tuar"] =
      {
        ["Kir'Akan, a Tuari warrior"] = "ignored",
        ["Lin'Elar, a Tuari girl-child"] = "ignored",
        ["Lythlyss, the Nelbennir warder"] = "ignored",
        ["Tor'Yasir, Headsman of the Tuari"] = "ignored",
        ["a Nelbennir alchemist"] = "ignored",
        ["a Nelbennir dart-thrower"] = "ignored",
        ["a Nelbennir elder"] = "ignored",
        ["a Nelbennir scout"] = "ignored",
        ["a mottled green aratha"] = "ignored",
        ["a sinuous white salamander"] = "ignored",
        ["a speckled eel"] = "ignored",
        ["a spotted pernicon"] = "ignored",
        ["a throng of swarming horax"] = "ignored",
        ["a warty stonefish"] = "ignored",
        ["an eight-legged aspis"] = "ignored",
      },
    ["the Island off the Northern Vashnars"] =
      {
        ["a carnivorous lycopod"] = "ignored",
        ["a hideous abomination"] = "ignored",
        ["a wild lycopod"] = "ignored",
      },
    ["the Isle of Ageiro"] =
      {
        ["Chaklos, a copper malagma"] = "ignored",
        ["Ferran, an iron malagma"] = "ignored",
        ["Giacinto, a golden malagma"] = "ignored",
        ["a copper malagma"] = "ignored",
        ["a golden malagma"] = "ignored",
        ["a graphite spider"] = "ignored",
        ["a lead beetle"] = "ignored",
        ["a nickel snake"] = "ignored",
        ["a silver malagma"] = "ignored",
        ["a tin lizard"] = "ignored",
        ["a zinc dragonfly"] = "ignored",
        ["an iron malagma"] = "ignored",
      },
    ["the Isle of Delos"] =
      {
        ["a fur-covered ogre"] = "ignored",
        ["a raging goblinoid scarab-rider"] = "ignored",
        ["a shifting mass of shadows"] = "ignored",
        ["an eight-legged goblin"] = "ignored",
      },
    ["the Isle of Erymanthus"] = {["a Stymphalian bird"] = "ignored"},
    ["the Isle of New Hope"] =
      {
        ["a barnacle encrusted oyster"] = "ignored",
        ["a silver panther"] = "ignored",
        ["a spearhead shark"] = "ignored",
      },
    ["the Isle of Prin"] =
      {
        Bikia = "ignored",
        Chak = "ignored",
        ["Elder Sef"] = "ignored",
        ["Master Hunter Juravi"] = "ignored",
        Prui = "ignored",
        Shiraxa = "ignored",
        ["Urandesea, Guardian of the Oracle"] = "ignored",
        ["a dark shroud"] = "ignored",
        ["a dark, baleful spectre"] = "ignored",
        ["a dark, lithe puma"] = "ignored",
        ["a small xorani child"] = "ignored",
        ["a wild pig"] = "ignored",
        ["a xorani guardian"] = "ignored",
        ["a xorani hunter"] = "ignored",
        ["a xorani priestess"] = "ignored",
        ["a xorani temple guard"] = "ignored",
        ["an elderly xoran"] = "ignored",
        ["an imposing cockatrice"] = "ignored",
        ["the Underkeeper"] = "ignored",
      },
    ["the Istar Jungle"] =
      {
        ["a bearded pig"] = "ignored",
        ["a blue-crowned ifrit"] = "ignored",
        ["a flying viper"] = "ignored",
        ["a foot-pad lizard"] = "ignored",
        ["a giant gwaeron"] = "ignored",
        ["a monstrous gamling spider"] = "ignored",
        ["an agile kamatlan"] = "ignored",
        ["an armoured boalisk"] = "ignored",
      },
    ["the Keep of Belladona"] =
      {
        ["Belladona, the Demon Whore"] = "ignored",
        ["Derryk, the eunuch"] = "ignored",
        ["Ephesia, Handmaiden of Belladona"] = "ignored",
        ["Eritrea, Handmaiden of Belladona"] = "ignored",
        ["Geh'shya, the Black Dragon"] = "ignored",
        ["Glixx, the mutant"] = "ignored",
        ["Gloom, the Occultist"] = "ignored",
        ["Grollum, the Sentinel"] = "ignored",
        ["Grothgar, the ogre sergeant"] = "ignored",
        ["Hecuba, the Witch of Darkness and Chaos"] = "ignored",
        ["Helf'ga, the ogress cook"] = "ignored",
        ["Malorea, Handmaiden of Belladona"] = "ignored",
        ["Minoria, handmaiden of Belladona"] = "ignored",
        ["Mistandraxus, the flame drake"] = "ignored",
        ["Naggamantex, the torturer"] = "ignored",
        ["Quel'zar, the Surgeon"] = "ignored",
        ["Smirnick, the Serpentlord"] = "ignored",
        ["Smythe, the dwarven trainer"] = "ignored",
        ["Tigrinya, the Librarian"] = "ignored",
        ["a black hell-hound"] = "ignored",
        ["a courtier"] = "ignored",
        ["a dark minotaur"] = "ignored",
        ["a fearsome crocodile"] = "ignored",
        ["a manticore"] = "ignored",
        ["a marsh viper"] = "ignored",
        ["a mist-walker"] = "ignored",
        ["a spectral guardian"] = "ignored",
        ["a two-headed ogre"] = "ignored",
      },
    ["the Lost City of Kasmarkin"] =
      {["a ghostly troll senator"] = "ignored", ["a mummified troll guardian"] = "ignored"},
    ["the Lupine Hunting Grounds"] =
      {
        ["a centaur colt"] = "ignored",
        ["a centaur sage"] = "ignored",
        ["a fearsome lion"] = "ignored",
        ["a fell werewolf"] = "ignored",
        ["a fell werewolf cub"] = "ignored",
        ["a fierce black panther"] = "ignored",
        ["a fungal toad"] = "ignored",
        ["a giant fire eel"] = "ignored",
        ["a giant red scorpion"] = "ignored",
        ["a large bainligor"] = "ignored",
        ["a large fire eel"] = "ignored",
        ["a long, horned snake"] = "ignored",
        ["a massive gohlbrorn"] = "ignored",
        ["a massive swamp python"] = "ignored",
        ["a massive varkha"] = "ignored",
        ["a pregnant panther"] = "ignored",
        ["a russel's viper"] = "ignored",
        ["a school of bloodthirsty piranha"] = "ignored",
        ["a shaggy water buffalo"] = "ignored",
        ["a silver spider"] = "ignored",
        ["a sleek black werepanther"] = "ignored",
        ["a slender snake"] = "ignored",
        ["a striped viper"] = "ignored",
        ["a weretigress"] = "ignored",
        ["a wild centaur"] = "ignored",
        ["an agitated jaguar"] = "ignored",
        ["an elder centaur"] = "ignored",
        ["an elder centaur priestess"] = "ignored",
        ["an irate mountain goat"] = "ignored",
      },
    ["the Mesmerium"] = {["a dream horror"] = "ignored"},
    ["the Mhojave Desert"] =
      {
        ["a giant red scorpion"] = "ignored",
        ["a hardy jarbo"] = "ignored",
        ["a monitor lizard"] = "ignored",
        ["a rattlesnake"] = "ignored",
        ["a sidewinder"] = "ignored",
        ["a thoqqua"] = "ignored",
        ["a yellow scorpion"] = "ignored",
        ["an unformed thing of chaos"] = "ignored",
      },
    ["the Mines of Iskadar"] =
      {
        ["Bartok Stonefist, Leader of the Blackfire clan"] = "ignored",
        ["Breana Ironhammer"] = "ignored",
        ["Brok, the Blackfire shaman"] = "ignored",
        ["Glath Ironhammer, Leader of the Bloodstone clan"] = "ignored",
        ["Grelda Stonefist"] = "ignored",
        ["High Priest Asdath"] = "ignored",
        ["Thraken, the Bloodstone shaman"] = "ignored",
        ["a blood-soaked dwarven miner"] = "ignored",
        ["a bloodstained miner"] = "ignored",
        ["a convulsing miner"] = "ignored",
        ["a delirious miner"] = "ignored",
        ["a dirt-encrusted miner"] = "ignored",
        ["a dishevelled dwarven miner"] = "ignored",
        ["a dwarven priest"] = "ignored",
        ["a nervous acolyte"] = "ignored",
        ["a priest"] = "ignored",
        ["a queen leech"] = "ignored",
        ["a vomiting miner"] = "ignored",
        ["a young dwarven miner"] = "ignored",
        ["an adolescent miner"] = "ignored",
        ["an alert dwarven guard"] = "ignored",
        ["an injured miner"] = "ignored",
      },
    ["the Mirror Caves"] =
      {
        ["Firad, the Sileg Chieftain"] = "ignored",
        ["Girda, Ritualist of the Sileg"] = "ignored",
        ["Mokgrin, the fernbeast herder"] = "ignored",
        ["a bioluminescent ooze"] = "ignored",
        ["a crystal georith"] = "ignored",
        ["a ghost bat"] = "ignored",
        ["a giant quartz beetle"] = "ignored",
        ["a juvenile Sileg"] = "ignored",
        ["a lost spirit"] = "ignored",
        ["a malevolent echo"] = "ignored",
        ["a massive jade spider"] = "ignored",
        ["a plated fernbeast"] = "ignored",
        ["a rockhide basilisk"] = "ignored",
        ["a rope lichen"] = "ignored",
        ["an adult Sileg"] = "ignored",
        ["an aged Sileg"] = "ignored",
      },
    ["the Monastery of Shala'jen"] =
      {["Gontathis, the Master Thief"] = "ignored", ["a large bandit"] = "ignored"},
    ["the Northern Atrousian Jungle"] =
      {
        ["Hul'fro, a towering ogre"] = "ignored",
        ["a clouded leopard"] = "ignored",
        ["a disfigured ogre"] = "ignored",
        ["a domesticated water buffalo"] = "ignored",
        ["a swarm of mosquitoes"] = "ignored",
      },
    ["the Northern Ithmia"] = {["a black lamassu"] = "ignored"},
    ["the Northern Scrublands"] =
      {["a red jackal"] = "ignored", ["a scrub fox"] = "ignored", ["a water buffalo"] = "ignored"},
    ["the Northern Vasnari Mountains"] =
      {
        ["Malsaur, the brigand chief"] = "ignored",
        ["a bloodthirsty jackdaw"] = "ignored",
        ["a disfigured ram"] = "ignored",
        ["a disgusting goblin"] = "ignored",
        ["a fierce brigand"] = "ignored",
        ["a hulking hobgoblin"] = "ignored",
        ["a magnificent lightning eagle"] = "ignored",
        ["a masked ogre"] = "ignored",
        ["a mother gryphon"] = "ignored",
        ["a rabid grizzly bear"] = "ignored",
        ["a savage morsuleus"] = "ignored",
        ["a scruffy brigand"] = "ignored",
        ["a water leech"] = "ignored",
        ["a young gryphon"] = "ignored",
        ["an enormous cave bat"] = "ignored",
        ["an ice hellion"] = "ignored",
      },
    ["the Northreach Forest"] =
      {["a speckled fawn"] = "ignored", ["an incorporeal shadow"] = "ignored"},
    ["the Peshwar Delta"] = {["a barnacle encrusted oyster"] = "ignored"},
    ["the Port of Mysia"] =
      {
        ["Aneurin, the card shark"] = "ignored",
        ["Brodie, a bawdy pirate"] = "ignored",
        ["Captain Jarvace, Mayor of Mysia"] = "ignored",
        ["Captain Kelley, Mayor of Mysia"] = "ignored",
        ["Cassian, a blue-robed mage"] = "ignored",
        ["Cressa, the roulette attendant"] = "ignored",
        ["Delmar, a pirate with a peg-leg"] = "ignored",
        ["Devon, a bow-legged pirate"] = "ignored",
        ["Enys, a denounced cleric"] = "ignored",
        ["Favian, a towering bartender"] = "ignored",
        ["Jarvace, the Xorani brawler"] = "ignored",
        ["a chicken"] = "ignored",
        ["a drunken pirate"] = "ignored",
        ["a pirate lass"] = "ignored",
        ["a pirate with an eye-patch"] = "ignored",
        ["a scantily dressed prostitute"] = "ignored",
        ["a squat pig"] = "ignored",
      },
    ["the Port of Umbrin"] =
      {
        ["Colonel Antariz"] = "ignored",
        ["Master Healer Rivtan"] = "ignored",
        ["Reliar, the Umbrinite Merchant"] = "ignored",
        ["an Umbrinite conscript"] = "ignored",
        ["an Umbrinite raider"] = "ignored",
      },
    ["the Pri'alysh Moor"] =
      {["a pale, gaunt spectre"] = "ignored", ["an enraged spectre"] = "ignored"},
    ["the Rainforest of Shala-Khulia"] = {["a cat-eyed snake"] = "ignored"},
    ["the River Mnemosyne"] = {["an alligator"] = "ignored"},
    ["the Sangre Plains"] =
      {
        ["a groundhog"] = "ignored",
        ["a rugged buffalo"] = "ignored",
        ["a sheep"] = "ignored",
        ["a smoke-wreathed ictheli"] = "ignored",
        ["a vulture"] = "ignored",
      },
    ["the Sarave Foothills"] =
      {["a vicious wolverine"] = "ignored", ["an enormous cave bat"] = "ignored"},
    ["the Savannah"] =
      {
        ["a goblinoid soldier"] = "ignored",
        ["a massive, black and white war beetle"] = "ignored",
        ["a shifting mass of shadows"] = "ignored",
        ["an enraged ogre destroyer"] = "ignored",
        ["the beast in the crypt"] = "ignored",
      },
    ["the Shamtota Hills"] = {["the giant dwarf Tordahl"] = "ignored"},
    ["the Siroccian Mountains"] =
      {["a foul-smelling orc"] = "ignored", ["a vicious wolverine"] = "ignored"},
    ["the Southern Vashnar Mountains"] =
      {["a mountain drake"] = "ignored", ["a mountain grizzly"] = "ignored"},
    ["the Southern Zaphar River"] =
      {["a barnacle encrusted oyster"] = "ignored", ["a dusky brown crayfish"] = "ignored"},
    ["the Stone Forest"] = {["a greater caterpin"] = "ignored"},
    ["the Sunderlands"] = {["a transparent spectre"] = "ignored"},
    ["the Tears of Sarapis"] = {["a whitetip shark"] = "ignored"},
    ["the Thraasi Foothills"] = {["a muscular mountain lion"] = "ignored"},
    ["the Tower of Falaq'tor"] = {["a Tsol'dasi guardian"] = "ignored"},
    ["the Ulangi Isles"] =
      {
        ["Balai the Scorned"] = "ignored",
        ["a feisty badger"] = "ignored",
        ["a gorgeous pheasant"] = "ignored",
        ["a horkval guard"] = "ignored",
        ["a large buck"] = "ignored",
        ["a majestic moose"] = "ignored",
        ["the King Stag"] = "ignored",
      },
    ["the Valho Coast"] =
      {
        ["Gnomon, the confused"] = "ignored",
        ["Master Mascon"] = "ignored",
        ["a Penumbran fiend"] = "ignored",
        ["a mad cultist"] = "ignored",
        ["a murkworm"] = "ignored",
      },
    ["the Valley of Actar"] = {["a large rabbit with one black ear"] = "ignored"},
    ["the Vashnar Mountains"] =
      {
        ["a bighorn sheep"] = "ignored",
        ["a muscular mountain lion"] = "ignored",
        ["the wizard Hycanthus"] = "ignored",
      },
    ["the Vents of Hthrak"] =
      {
        ["Geltar, Patriarch of the Dirangi"] = "ignored",
        ["a dirangi cub"] = "ignored",
        ["a lean dirangi"] = "ignored",
        ["a sleek dirangi"] = "ignored",
        ["an ozhera chick"] = "ignored",
        ["an ozhera minorus"] = "ignored",
        ["the ozhera matriarch"] = "ignored",
      },
    ["the Village of Genji"] =
      {
        ["Tinja, the atavian"] = "ignored",
        ["a female atavian villager"] = "ignored",
        ["a ferocious manticore"] = "ignored",
        ["a huge, ferocious manticore"] = "ignored",
        ["a male atavian villager"] = "ignored",
        ["a young manticore"] = "ignored",
        ["an atavian warrior"] = "ignored",
        ["the queen manticore"] = "ignored",
      },
    ["the Village of Qerstead"] = {["a Kelstaad lioness"] = "ignored"},
    ["the Village of Tomacula"] = {["Elegnem, shaman of Tomacula"] = "ignored"},
    ["the bog of Ashtan"] = {"a bog hound", ["a bog hound"] = "ignored"},
    ["the fathomless expanse of the World Tree"] =
      {
        ["a bulbous banovaettr"] = "ignored",
        ["a giant honey bee"] = "ignored",
        ["a greater air elemental"] = "ignored",
        ["a greater water elemental"] = "ignored",
        ["a haskrovska vine"] = "ignored",
        ["a huge rat"] = "ignored",
        ["a lesser air elemental"] = "ignored",
        ["a lesser fire elemental"] = "ignored",
        ["a lesser water elemental"] = "ignored",
        ["a rajamala slaver"] = "ignored",
        ["a spined caterpillar"] = "ignored",
      },
    ["the fathomless expanse of the corrupted World Tree"] =
      {
        ["a greater air elemental"] = "ignored",
        ["a greater water elemental"] = "ignored",
        ["a huge rat"] = "ignored",
        ["a lesser air elemental"] = "ignored",
        ["a lesser water elemental"] = "ignored",
      },
    ["the frozen tundra"] =
      {
        ["Shmeeg, an old wendigo"] = "ignored",
        ["a diamond fish"] = "ignored",
        ["a massive wendigo"] = "ignored",
        ["a sabre walrus"] = "ignored",
        ["a woolly mammoth"] = "ignored",
        ["an ice bear"] = "ignored",
        ["an ice scarab"] = "ignored",
      },
    ["the gypsy village Manusha"] = {Vishengo = "ignored"},
    ["the ruins of Morindar"] =
      {
        ["Halatir Pelendur, former Shah of Morindar"] = "ignored",
        ["Lavarin Pelendur, the Shah"] = "ignored",
        ["Ramainen Tarcalion, Outrider Ascendant"] = "ignored",
        ["Yurasta Tarcalion, the Thaumaturge"] = "ignored",
        ["a corpulent rilma worm"] = "ignored",
        ["a cursed revenant"] = "ignored",
        ["a fearsome cave hunter"] = "ignored",
        ["a feral gangrel"] = "ignored",
        ["a greyish-green culuma"] = "ignored",
        ["a hideous nel'dorath"] = "ignored",
        ["a hunchbacked feyr"] = "ignored",
        ["a jagged quorin"] = "ignored",
        ["a menacing gargoyle"] = "ignored",
        ["a revenant tontra"] = "ignored",
        ["a shimmering gloomwing moth"] = "ignored",
        ["an armoured nahar"] = "ignored",
      },
    ["the ruins of Phereklos"] =
      {
        ["a black sea bass"] = "ignored",
        ["a bleeding salt-water cod"] = "ignored",
        ["a blue-spotted stingray"] = "ignored",
        ["a hideous, writhing squid"] = "ignored",
        ["a large bull shark"] = "ignored",
        ["a multi-headed water hydra"] = "ignored",
        ["a school of clownfish"] = "ignored",
        ["an abyssal chargefish"] = "ignored",
      },
    ["the salt mines of Ulsyndar"] =
      {
        ["Anttan, the mess cook"] = "ignored",
        ["Emmith, a sullen blacksmith"] = "ignored",
        ["a disgruntled salt miner"] = "ignored",
        ["a prison miner"] = "ignored",
        ["a stocky dwarf foreman"] = "ignored",
        ["an Ulsyndar guard"] = "ignored",
        ["an off-duty prison guard"] = "ignored",
      },
    ["the sewers of Ashtan"] = {["a murderous thug"] = "ignored"},
    ["the tunnels beneath Yggdrasil's lowest branches"] = {["an immense thopteran"] = "ignored"},
    ["the valley of Kuthalebak"] =
      {
        ["Balex, Solarn of Kuthalebak"] = "ignored",
        ["a chion ooze"] = "ignored",
        ["an infested Vertani"] = "ignored",
      },
    ["the village of Qurnok"] =
      {
        ["Aldroga, the Dendrologist"] = "ignored",
        ["Nel'ga, the wife of Ganorg"] = "ignored",
        ["Rurnog, the Herpetologist"] = "ignored",
        ["Ulvna, the witch of Qurnok"] = "ignored",
        ["a Qurnok guard"] = "ignored",
        ["a Qurnok warrior"] = "ignored",
        ["a Qurnok woman"] = "ignored",
        ["a huge, ferocious crocodile"] = "ignored",
        ["a large toad"] = "ignored",
        ["a mischievous troll boy"] = "ignored",
        ["a vicious water moccasin"] = "ignored",
        ["a young troll girl"] = "ignored",
        ["an enormous anaconda"] = "ignored",
      },
    ["the village of Tasur'ke"] =
      {["a barnacle encrusted oyster"] = "ignored", ["a man-eating shark"] = "ignored"},
  }
  saveTargetMasterList()
  end
end

-- Function to load areaIgnoreList and update area information
function updateAreaInfo()
  local area = gmcp.Room.Info.area
  local printpriolist = false
  -- Check if the current area is in the ignore list
  if not table.contains(areaIgnoreList, area) then
    -- Add items to the ignore list when first encountered.
    for k, v in pairs(items.room) do
      if v.properties and v.properties.denizen then
        local denizenName = v.name
        if recordmode then
          -- Check if the denizen name contains the word 'corpse' and ignore it if it does.
          if not string.find(denizenName:lower(), "corpse") then
            targetMasterList[area] = targetMasterList[area] or {}
            if not targetMasterList[area].denizenName and not (targetMasterList[area] == "") then
              if not table.contains(targetMasterList[area], denizenName) then
                targetMasterList[area][denizenName] = "ignored"
                -- Save the updated targetMasterList
                saveTargetMasterList()
                printpriolist = true
              end
            end
          end
        end
      end
    end
    if area ~= currentarea then
      currentarea = area
      -- Load targetMasterList
      loadTargetMasterList()
      -- Set values for the current area to targetPriorityList
      targetPriorityList = targetMasterList[currentarea] or {}
      printpriolist = true
    end
  end
  -- if new area not found in target master list, add to target master list and auto ignore.
  --if not table.contains(targetMasterList, area) then
   -- targetMasterList[area] = {}
   -- saveTargetMasterList()
   -- toggleIgnoreArea(area)
    --setIgnoreArea(area)
  --end
  if printpriolist then
    printpriolist = false
    -- Print denizen priority list
    --printDenizenPriorityList()
  end
end

function roomstuff()
  extermlist = {}
  roomstufflist = {}
  for i = 1, #gmcp.Char.Items.List.items, 1 do
    if gmcp.Char.Items.List.items[i].attrib == "m" then
      roomstufflist[gmcp.Char.Items.List.items[i].id] = gmcp.Char.Items.List.items[i].name
      if not (findkey(extermlist, gmcp.Char.Items.List.items[i].id)) then
        extermlist[gmcp.Char.Items.List.items[i].id] = {gmcp.Char.Items.List.items[i].name}
      end
    end
  end
end

-- Update targetMasterList based on the area when a denizen is killed manually

function removestuff()
  if gmcp.Char.Items.Remove.location == "room" then
    local removedItemId = gmcp.Char.Items.Remove.item.id
    if roomstufflist[removedItemId] then
      local removedItemName = roomstufflist[removedItemId]
      roomstufflist[removedItemId] = nil
      if hunting and autohunting then
        huntNext()
      end
    end
  end
end

-- Add denizens to the list when encountered for the first time

function addstuff()
  if gmcp.Char.Items.Add.location == "room" and gmcp.Char.Items.Add.item.attrib == "m" then
    local itemId = gmcp.Char.Items.Add.item.id
    local itemName = gmcp.Char.Items.Add.item.name
    roomstufflist[itemId] = itemName
    if not findkey(extermlist, itemId) then
      extermlist[itemId] = {itemName}
    end
  end
end

-- Register the event handler
--registerAnonymousEventHandler("gmcp.Room.Info", updateAreaInfo)
--registerAnonymousEventHandler("gmcp.Char.Items.List", roomstuff)
--registerAnonymousEventHandler("gmcp.Char.Items.Add", addstuff)
--registerAnonymousEventHandler("gmcp.Char.Items.Remove", removestuff)

	
function reloadHuntingFile()	
  dofile(getMudletHomeDir() .. "/Achaean System/hunting/hunting.lua")  -- Adjust the path as needed
  echo("\nHunting Loaded")
end

registerAnonymousEventHandler("gmcp.Room.Info", updateAreaInfo)
registerAnonymousEventHandler("gmcp.Char.Items.List", roomstuff)
registerAnonymousEventHandler("gmcp.Char.Items.Add", addstuff)
registerAnonymousEventHandler("gmcp.Char.Items.Remove", removestuff)