 -- Initialize an empty table to serve as the prototype for the queue.
local queue = {}
-- Set the metatable index to allow 'queue' to serve as its own prototype.
queue.__index = queue

-- Constructor for a new queue
function queue:new()
  local obj = {items = {}, heap = {}, nodes = {}}
  setmetatable(obj, self)
  return obj
end

-- Initialize 'defenses' with a new instance of 'queue' if 'defenses' is nil or false.
fortify = fortify or queue:new()

-- Method to clear all items from the queue
function queue:clear()
  self.items = {}
  self.heap = {}
  self.nodes = {}
end

-- Method to get the size of the queue
function queue:size()
  return #self.items
end

-- Method to reset the queue
function queue:reset()
  self:clear()
end

-- Echo next cure command queued.
function queue:echo(command)
  cecho("\n<DarkSlateGray>SENT COMMAND: <white>- <PowderBlue>" .. command:upper() .. "\n")
end

-- Check if queue already contains special key in heap.
function queue:contains(item)
  local key = item.type .. "-" .. item.name
  return self.nodes[key] ~= nil
end

-- Helper method to check if active afflictions block a new detail
function queue:blockers(blockers)
    for _, blocker in ipairs(blockers) do
        for _, aff in ipairs(myaffs) do
            if aff == blocker then
                return true
            end
        end
    end
    return false
end

function fortify:update(defense, value)

  --if defense == "speed" then
    --cecho("\n<orange>[DEBUG] fortify:update() called for speed - value = " .. tostring(value))
  --end

  if defenses[defense] then
    cecho("\n<green>[DEBUG] Updating defense: " .. defense)
  else
	if defense == "tree" then
		cecho("\n<red>[DEBUG] TREE GONE - <white>GET A PERMA TATTOO!!!")
		cecho("\n<red>[DEBUG] TREE GONE - <white>GET A PERMA TATTOO!!!")
		cecho("\n<red>[DEBUG] TREE GONE - <white>GET A PERMA TATTOO!!!")
		cecho("\n<red>[DEBUG] TREE GONE - <white>GET A PERMA TATTOO!!!")
		cecho("\n<red>[DEBUG] TREE GONE - <white>GET A PERMA TATTOO!!!")
	else
		cecho("\n<red>[DEBUG] No such defense found in defenses table: " .. tostring(defense))
	end
  end

  if value then
    -- Always add to mydefs if not present
    if not table.contains(mydefs, defense) then
      table.insert(mydefs, defense)
    end

    -- ✅ Always clear pipeline key regardless of mydefs state
    pipeline.defenses[defense] = nil
    pipeline.activeCommand = ""

    if defenses[defense] then
      defenses[defense].active = value
      defenses[defense].enabled = value
    end

    cecho("\n<yellow>[DEBUG] Cleared pipeline key: " .. tostring(defense))

  else
    if table.contains(mydefs, defense) then
      table.remove(mydefs, table.index_of(mydefs, defense))
    end

    pipeline.defenses = {}

    if defenses[defense] then
      defenses[defense].active = value
      defenses[defense].enabled = value
      defenses[defense].keepup = value
    end
  end
end



function fortify:relax()
    local cs = cmdsep
	local currentClassType = PLAYER:myclass()  -- Get the current class type
    local validSkillTree = skillTreeList[currentClassType]  -- Get the skills for the current class
    local list = table.n_union(validSkillTree, {"vision", "free", "survival", "herb", "salve", "smoke", "tattoo", "yourMissingType1", "yourMissingType2"})  -- Add missing types
    local relaxCommands = {}  -- Table to hold the relax commands

    -- Iterate over each defense
    for defenseName, defense in pairs(defenses) do

        -- Check the conditions
        if defense.active and  -- Check if the defense is active
           string.find(defense.relax, "relax") and  -- Check if "relax" is in the relax command
           table.contains(list, defense.type) and
           (defense.drain == "mana" or defense.drain == "endurance") and
           not (defense.type == "blindness" or defense.type == "deafness" or defense.type == "insomnia") then  -- Exclude blindness and deafness
           
            -- Add the relax command to the list
            table.insert(relaxCommands, defense.relax)
        end
    end

    -- Send all relax commands if any were found
    if #relaxCommands > 0 then
        local relaxCommandString = table.concat(relaxCommands, cs)  -- Concatenate the commands into a single string
        send(relaxCommandString)  -- Send the concatenated relax commands
    else
        echo("No relax commands to send.")
    end
end

-- Method to add an item to the queue
--function queue:push(item)
  --  local key = item.type .. "-" .. item.name
    --if not self:contains(item) then
      --  self.items[#self.items + 1] = item
        --self.nodes[key] = #self.items
        
        --table.sort(self.items, function(a, b)
          --  return a.priority < b.priority
        --end)
    --else
      --  print("Item is already in the queue")
    --end
--end

-- Method to remove and return the highest priority item
function queue:pop()
    if #self.items == 0 then
        print("Queue is empty")
        return nil
    end
    
    -- Remove the highest priority item (first item in the sorted list)
    local item = table.remove(self.items, 1)
    local key = item.type .. "-" .. item.name
    self.nodes[key] = nil
    
    -- Update the nodes table to reflect the new indices of remaining items
    for i, v in ipairs(self.items) do
        local k = v.type .. "-" .. v.name
        self.nodes[k] = i
    end

    return item
end

function queue:process()
    if not systemLoaded or systemPaused or balance_data.stunned.in_use then
        return 
    end  

    fortify:reset()

    local list = table.n_union(skillTreeList[PLAYER:myclass()], {"vision", "free", "survival", "herb", "salve", "smoke", "tattoo"})
    local validDefenses = {}

    for defense, details in pairs(defenses) do
        local defenseType = details.type
        if type(defenseType) == "table" then
            for _, v in ipairs(defenseType) do
                if table.contains(skillTreeList[PLAYER:myclass()], v) then
                    defenseType = v
                    break
                end
            end
        end

        if table.contains(list, defenseType) and not table.contains(mydefs, defense) then
            local hasRequiredBalance, hasRequiredCooldown = true, true

            for _, balance in ipairs(details.requires) do
                if not balance_data[balance] or balance_data[balance].in_use then
                    hasRequiredBalance = false
                    break
                end
            end

            for _, cooldown in ipairs(details.cooldown) do
                if not balance_data[cooldown] or balance_data[cooldown].in_use then
                    hasRequiredCooldown = false
                    break
                end
            end

            if hasRequiredBalance and hasRequiredCooldown then
			
			--if defense == "speed" then
			 -- cecho("\n<cyan>[DEBUG] queue:process() sees speed.active = " .. tostring(details.active))
			--end

			--cecho("\n<cyan>[DEBUG] mydefs has speed: " .. tostring(table.contains(mydefs, "speed")))

			
                if ((details.enabled and defupmode) or (not defupmode and details.keepup)) and not details.active then
                    table.insert(validDefenses, details)
                end
            end
        end
    end

    --print("[DEBUG] Valid defenses found:", #validDefenses)
	--for i, def in ipairs(validDefenses) do
		--print(string.format("[DEBUG] Def #%d: name=%s, command=%s", i, def.name or "nil", def.command or "nil"))
	--end

	
	table.sort(validDefenses, function(a, b)
        return a.priority > b.priority
    end)
	
	local bestDefense = validDefenses[1]

	if #validDefenses > 0 then
        local bestDefense = validDefenses[1]
		--print("[DEBUG] Best defense selected:", bestDefense.name, bestDefense.command)
        if not pipeline.defenses[bestDefense.name] then
             pipeline.defenses[bestDefense.name] = true
             pipeline.activeCommand = bestDefense.command  -- Set active command
			 cecho("\n<magenta>[DEBUG] Added pipeline key: " .. bestDefense.name)
			 self:send(bestDefense) 
         end

    end
end



function queue:debugPipeline()
    cecho("\n<cyan>[DEBUG] Pipeline contents:")
    for k, v in pairs(pipeline.defenses) do
        cecho("\n<white> - " .. k)
    end
end


function queue:send(defense)
    local command = defense.command

    if not defense.name then
        cecho("\n<red>[ERROR] Defense is missing name!")
        return
    end

    -- Adjust command if herbal/alchemical
    if defense.type == "herb" or defense.type == "smoke" then
        command = cureMethod == "alchemical" and defense.command.alchemical or defense.command.herbal
    end

    send(command)

    -- Defenses that are delayed in confirming
    local delayed = {
        "levitating", "insulation", "speed", "poisonresist",
        "fangbarrier", "rebounding", "density", "dragonbreath"
    }

    local isDelayed = table.contains(delayed, defense.name)

    if isDelayed then
        -- Manually simulate GMCP
        if not table.contains(mydefs, defense.name) then
            table.insert(mydefs, defense.name)
        end

        if defenses[defense.name] then
            defenses[defense.name].active = true
            defenses[defense.name].enabled = true
        end
		
		-- ✅ Actually tell the system this was successfully applied
		fortify:update(defense.name, true)
		
		--pipeline.defenses[defense.name] = nil
        --pipeline.activeCommand = nil
		echo("[DEBUG] Marked delayed defense as active and cleared key:", defense.name)
    end

    self:debugPipeline()
	return
end




-- Initialize cleanup timer once
lastPipelineCleanup = lastPipelineCleanup or 0

function queue:cleanPipeline()
    local now = os.clock()
    if now - lastPipelineCleanup < 2 then return end  -- throttle to every 2 seconds
    lastPipelineCleanup = now

    local cleaned = 0
    for name, _ in pairs(pipeline.defenses) do
        local def = defenses[name]
        if def and not def.active and not table.contains(mydefs, name) then
            pipeline.defenses[name] = nil
            cleaned = cleaned + 1
        end
    end

    if cleaned > 0 then
        cecho("\n<grey>[INFO] Cleaned " .. cleaned .. " stale pipeline entr" .. (cleaned == 1 and "y." or "ies."))
    end
end






function reloadFortifyQueue()
    fortify = nil  -- Clear the old defenses instance
    queue = nil   -- Clear the old queue table

    -- Reload the updated script (if in a file)
    dofile(getMudletHomeDir() .. "/Achaean System/defenses/defenses.lua")  -- Adjust the path as needed

    -- Optionally, re-initialize
    fortify = fortify or queue:new()
	
	echo("\nDefenses Loaded")
end


