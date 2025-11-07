-- Initialize an empty table to serve as the prototype for the queue
local queue = {}

-- Set the metatable index to allow 'queue' to serve as its own prototype
queue.__index = queue

-- Constructor for a new queue
function queue:new()
    local obj = {items = {}, heap = {}, nodes = {}}
    setmetatable(obj, self)
    return obj
end

-- Initialize 'remedy' with a new instance of 'queue' if 'remedy' is nil or false
remedy = remedy or queue:new()

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

-- Method to reset the queue (same as clearing it)
function queue:reset()
    self:clear()
end

-- Print the queued command for debugging
function queue:echo(command)
    cecho("\n<DarkSlateGray>SENT COMMAND: <white>- <PowderBlue>" .. command:upper() .. "\n")
end

-- Check if any blockers are active for a cure
function queue:blockers(cure)
    if not cure.blockers or #cure.blockers == 0 then
        return false
    end

    local blockersSet = {}
    for _, blocker in ipairs(cure.blockers) do
        blockersSet[blocker] = true
    end

    for _, aff in ipairs(myaffs) do
        if blockersSet[aff] then
            return true
        end
    end

    return false
end


-- Select the best cure type based on priorities
function queue:priority(cures, affliction, priority)
    local commands = {}

    -- Construct command structure with required fields
    for _, cure in ipairs(cures) do
        table.insert(commands, {
            type = cure.type,
            command = cure.command,
            cooldown = cure.cooldown,
            requires = cure.requires,
            handle = cure.handle,
            name = affliction,
            priority = priority,
            prompt = cure.prompt,
            blockers = cure.blockers
        })
    end

    -- Sort commands based on priority
    table.sort(commands, function(a, b)
        return a.priority < b.priority
    end)

    return commands
end

-- Create a table of afflictions sorted by priority
function queue:createLocalAffs()
    local localAffs = {}

    for _, affliction in ipairs(myaffs) do
        local affDetails = afflictions[affliction]
        if affDetails then
            table.insert(localAffs, {name = affliction, priority = affDetails.priority})
        end
    end
    return localAffs
end

-- Sort the local afflictions by priority
function queue:sortAfflictionsByPriority(localAffs)
    table.sort(localAffs, function(a, b) return a.priority < b.priority end)
end


-- Check if an affliction is on cooldown
function queue:isCureOnCooldown(affliction)
    local afflictionPipeline = pipeline.afflictions[affliction]
    return afflictionPipeline 
        and afflictionPipeline.cooldown_end 
        and os.time() < afflictionPipeline.cooldown_end 
        and afflictionPipeline.in_progress
end

-- Get the cooldown time for a cure type
function queue:getCureCooldown(cureType)
    local cureData = balance_data[cureType]
    return cureData and cureData.avg_time or 0.08
end

-- Check if a cure is valid based on required balances, cooldowns, and blockers
function queue:isCureValid(cure)
    local hasRequiredBalance, hasRequiredCooldown = true, true

    -- Check balance requirements
    if type(cure.requires) == "table" then
        for _, balance in ipairs(cure.requires) do
            if balance_data[balance].in_use then
                hasRequiredBalance = false
                break
            end
        end
    elseif type(cure.requires) == "string" and balance_data[cure.requires].in_use then
        hasRequiredBalance = false
    end

    -- Check cooldown requirements
    if type(cure.cooldown) == "table" then
        for _, cooldown in ipairs(cure.cooldown) do
            if balance_data[cooldown].in_use then
                hasRequiredCooldown = false
                break
            end
        end
    elseif type(cure.cooldown) == "string" and balance_data[cure.cooldown].in_use then
        hasRequiredCooldown = false
    end

    -- Ensure there are no active blockers
    return hasRequiredBalance and hasRequiredCooldown and not self:blockers(cure)
end



function queue:clearPipelineOnCommand(balanceType)
    for affliction, cureData in pairs(pipeline.afflictions) do
   
 -- Check if the cure type matches the specified balanceType
        if cureData.curetype == balanceType then
		   -- Clear the pipeline entry for this affliction
            pipeline.afflictions[affliction] = nil

            if DEBUG_MODE then
                self:echo("Cleared pipeline entry for " .. affliction .. " due to cure type: " .. balanceType)
            end
        end
    end
end



function queue:process()
    -- Early exit if the system is not ready
    if not systemLoaded or systemPaused or balance_data.stunned.in_use then
        return
    end

    -- Localize data for faster access
    local afflictionData = afflictions
    local localAffs = self:createLocalAffs()
    self:sortAfflictionsByPriority(localAffs) -- Sort once upfront

    local validCures = {}
    local usedCureTypes = {} -- Track highest-priority cure for each type
    local seenCommands = {} -- Track already added commands by command and affliction

    -- Iterate over sorted afflictions to find the best cures
    for _, affData in ipairs(localAffs) do
        local affliction = affData.name
        local details = afflictionData[affliction]

        -- Skip afflictions with active cooldowns
        if not self:isCureOnCooldown(affliction) then
            local bestCure = self:processCure(affliction, details)

            if bestCure then
                local cureType = bestCure.type
                local existingCure = usedCureTypes[cureType]

                -- Update with the highest-priority cure for this type
                if not existingCure or affData.priority < existingCure.priority then
                    usedCureTypes[cureType] = bestCure
                end
            end
        end
    end

    -- Build validCures while avoiding duplicates by both command and affliction
    for _, bestCure in pairs(usedCureTypes) do
        -- Safely handle command conversion to string
        local command
        if type(bestCure.command) == "table" then
            command = table.concat(bestCure.command, ", ") -- Concatenate table into a string
        else
            command = tostring(bestCure.command) -- Convert to string if not already
        end

        -- Ensure cureKey is unique for command and affliction
        local cureKey = command .. ":" .. bestCure.name

        if not seenCommands[cureKey] then
            seenCommands[cureKey] = true
            table.insert(validCures, bestCure)
        end
    end

    -- Debug: Log the final list of validCures
    if DEBUG_MODE then
        self:echo("---- Valid Cures Processed ----")
        for _, cure in ipairs(validCures) do
            self:echo(string.format("Command: %s | Affliction: %s", 
                type(cure.command) == "table" and table.concat(cure.command, ", ") or cure.command, 
                cure.name))
        end
    end

    -- Process cures
    if #validCures > 0 then
        if batching then
            self:sendBatchCures(validCures)
        else
            self:sendSingleCure(validCures[1])
        end
    end
end



function queue:sendSingleCure(cure)
    local pipelineAfflictions = pipeline.afflictions
    local curingList = curinglist
    local afflictionData = afflictions
    local currentTime = os.time()
    local networkLatency = getNetworkLatency()
    local nonPrioritizedCures = { "herb", "salve", "smoke", "writhe", "wake", "balance" }
    local affliction = cure.name
    local cureType = cure.type
    local command = cure.command

    -- Adjust command for herb or smoke
    if cureType == "herb" or cureType == "smoke" then
        command = cureMethod == "alchemical" and cure.command.alchemical or cure.command.herbal
    end

    -- Skip if cure type is already in progress
    if pipelineAfflictions[affliction] then
        if DEBUG_MODE then self:echo("Cure type already in progress for: " .. affliction) end
        return
    end

    -- Handle prioritization for nonPrioritizedCures
    if table.contains(nonPrioritizedCures, cureType) then
        local currentSlot1Aff = nil

        -- Identify current slot 1 affliction
        for aff, prio in pairs(curingList) do
            if prio == 1 then
                currentSlot1Aff = aff
                break
            end
        end

        -- Reset current slot 1 if necessary
        if currentSlot1Aff and currentSlot1Aff ~= affliction then
            local defaultPriority = afflictionData[currentSlot1Aff] and afflictionData[currentSlot1Aff].priority or 25
            if curingList[currentSlot1Aff] ~= defaultPriority then
                --send("curing prio " .. currentSlot1Aff .. " " .. defaultPriority)
                if DEBUG_MODE then
                   self:echo("Reset " .. currentSlot1Aff .. " to default priority " .. defaultPriority)
                end
            end
        end

        -- Set the new affliction to slot 1 if it's not already there
        if (curingList[affliction] or 25) ~= 1 then
            -- Before setting, check if the affliction is already at priority 1
            if not sentPriorityCommands[affliction] then
                -- Mark as sent globally
                sentPriorityCommands[affliction] = true

                send("curing prio " .. affliction .. " 1")
                if DEBUG_MODE then
                    self:echo("Set " .. affliction .. " to priority 1.")
                end
            else
                -- Debugging output: Already processed affliction
               -- cecho("<yellow>Affliction " .. affliction .. " already at priority 1, skipping command.\n")
            end
        end
    end

    -- Send cure command if not non-prioritized
    if not table.contains(nonPrioritizedCures, cureType) then
        -- Mark cure as in progress
        pipelineAfflictions[affliction] = {
            name = affliction,
            command = command,
            in_progress = true,
            curetype = cureType,
            cooldown_end = currentTime + self:getCureCooldown(cureType) + networkLatency,
            priority = afflictionData[affliction] and afflictionData[affliction].priority or 25
        }

        if DEBUG_MODE then self:echo("Sending cure command: " .. command) end
        send(command)
    end
end


function queue:sendBatchCures(validCures)
    local cs = cmdsep
    local serverCommands = {} -- Priority commands
    local batchCommands = {} -- Cure commands
    local seenBatchCommands = {} -- Track unique batch commands
    local usedCureTypes = {} -- Track processed cure types
    local pipelineAfflictions = pipeline.afflictions -- Localize global table
    local curingList = curinglist -- Localize curinglist
    local afflictionData = afflictions -- Localize affliction definitions
    local currentTime = os.time() -- Cache current time
    local networkLatency = getNetworkLatency() -- Cache network latency
    local nonPrioritizedCures = { "herb", "salve", "smoke", "writhe", "wake", "balance" }
    local highestPrioAff = nil -- Track highest-priority affliction
    local highestPriority = 25 -- Start with the lowest priority


    -- Step 1: Determine the highest-priority affliction
    for _, cure in ipairs(validCures) do
        local affliction = cure.name
        local cureType = cure.type
        local affPriority = afflictionData[affliction] and afflictionData[affliction].priority or 25
        
        -- Skip already processed or irrelevant cures
        if not pipelineAfflictions[affliction] and not usedCureTypes[cureType] and table.contains(nonPrioritizedCures, cureType) then            
            if affPriority < highestPriority then
                highestPrioAff = affliction
                highestPriority = affPriority
            end
        end
    end

    -- Step 2: Prioritize the highest-priority affliction
    if highestPrioAff then
        local command = "curing prio " .. highestPrioAff .. " 1"
        
        -- Check if this command has already been sent
        if not sentPriorityCommands[highestPrioAff] then
            -- Check if the affliction is already at priority 1
            if (curingList[highestPrioAff] or 25) ~= 1 then
                -- Mark as sent and add the command
                sentPriorityCommands[highestPrioAff] = true
                table.insert(serverCommands, command)

                -- Debug output for priority change
              --  cecho("<green>Sent priority command for affliction: " .. highestPrioAff .. " to priority 1.\n")
            else
              --  cecho("<yellow>Affliction " .. highestPrioAff .. " is already at priority 1, skipping command.\n")
            end
        end
    end

    -- Step 3: Send priority commands immediately
    if #serverCommands > 0 then
        while #serverCommands > 4 do
            table.remove(serverCommands)
        end
        send(table.concat(serverCommands, cs))
        
        if DEBUG_MODE then
            self:echo("Sent priority commands: " .. table.concat(serverCommands, cs))
        end
    end

    -- Step 4: Prepare and queue batch cure commands
    for _, cure in ipairs(validCures) do
        local affliction = cure.name
        local cureType = cure.type
        local command = cure.command

        -- Adjust command based on type
        if cureType == "herb" or cureType == "smoke" then
            command = cureMethod == "alchemical" and cure.command.alchemical or cure.command.herbal
        end

        -- Skip cures already processed or queued
        if not pipelineAfflictions[affliction] and not usedCureTypes[cureType] and not seenBatchCommands[command] and not table.contains(nonPrioritizedCures, cureType) then
            local affPriority = afflictionData[affliction] and afflictionData[affliction].priority or 25

            -- Mark the cure as in progress
            pipelineAfflictions[affliction] = {
                name = affliction,
                command = command,
                in_progress = true,
                curetype = cureType,
                cooldown_end = currentTime + self:getCureCooldown(cureType) + networkLatency,
                priority = affPriority
            }

            -- Add the command to the batch if unique
            seenBatchCommands[command] = true
            table.insert(batchCommands, command)
            if DEBUG_MODE then
                self:echo("Added unique cure command: " .. command)
            end

            -- Track the cure type as processed
            usedCureTypes[cureType] = true
        end
    end

    -- Step 5: Send batch cure commands
    if #batchCommands > 0 then
        while #batchCommands > 10 do
            table.remove(batchCommands)
        end
        send(table.concat(batchCommands, cs))
        if DEBUG_MODE then
            self:echo("Sent unique batch commands: " .. table.concat(batchCommands, cs))
        end
    end
end




function queue:setAfflictionPriorities()
    local afflictionCommands = {}  -- Table to store the curing prio commands
    local currentTime = os.time()
    local networkLatency = getNetworkLatency()
    local priority = 0

    -- Iterate through each affliction in the afflictions table
    cecho("<yellow>\nStarting affliction iteration...<reset>\n")
    for affliction, data in pairs(afflictions) do
        -- Assign a default priority in case data.priority is nil
        priority = 0

        if table.contains({"fear", "aeon", "entangled", "blackout", "bound", "daeggerimpale", "impaled", "sleeping", "transfixation", "voyria", "webbed", "prone", "disrupted"}, affliction) then
            priority = 2
        elseif data and data.priority then
            priority = data.priority
        else
            cecho("<red>Warning: No priority set for affliction '" .. affliction .. "'. Defaulting to 0.<reset>\n")
        end

        -- Check if the first cure is of type "time"
        if data.cures[1] and data.cures[1].type == "time" then
            -- If the first cure is time, set the priority to 26
            table.insert(afflictionCommands, "curing prio " .. affliction .. " 26")
            afflictions[affliction].priority = 26
        else
            -- Otherwise, use the affliction's priority for all other cures
            table.insert(afflictionCommands, "curing prio " .. affliction .. " " .. priority)
            afflictions[affliction].priority = priority
        end
    end

    scheduleBatchProcessing(afflictionCommands)
end




	-- Create tempTimers to send batches
	function scheduleBatchProcessing(afflictionCommands)
		local maxCommandsPerBatch = 4
		local totalCommands = #afflictionCommands
		local sendTime = 1
		

		-- Process the commands in batches with timers
		for i = 1, totalCommands, maxCommandsPerBatch do
			-- Define the end of the current batch
			local batchEndIndex = math.min(i + maxCommandsPerBatch - 1, totalCommands)
			local batch = {}

			-- Slice the commands for the current batch
			for j = i, batchEndIndex do
				table.insert(batch, afflictionCommands[j])
			end


			-- Calculate the cumulative delay for this batch
			sendTime = sendTime + 1.3  -- Adds 1.2 seconds per batch

			-- Schedule the batch to be sent with the calculated cumulative delay
			tempTimer(sendTime, function()
				sendBatch(batch)
				
			end)
			
		end
				
		
		
	end


    -- Function to send the batch commands
    function sendBatch(batch)
	    local cs = cmdsep
        local filename = PLAYER:myclass() .. "prios.lua"
		local batchString = table.concat(batch, cs)
        --cecho("<yellow>Sending batch: " .. batchString .. "<reset>\n")

        if batchString and batchString ~= "" then
            if DEBUG_MODE then self:echo(batchString) end
            send(batchString)
			ensureFileExists("curing", filename, "save", afflictions)
        end
    end
	

	function updateCuringListPriorities()
		-- Loop through each affliction in the afflictions table
		for affliction, data in pairs(afflictions) do
			-- Set the curinglist priority for each affliction to match the afflictions priority
			if data.type == "time" then
				curinglist[affliction] = 26
			else
				curinglist[affliction] = data.priority
			end
		end
	end




-- Process and select the best cure for an affliction
function queue:processCure(affliction, details)
    local prioritizedCures = self:priority(details.cures, affliction, details.priority)

    for _, cure in ipairs(prioritizedCures) do
        if self:isCureValid(cure) then
            return cure
        end
    end
    return nil
end

-- Trigger for successful cure of an affliction
function onCureSuccess(affliction)
    if pipeline.afflictions[affliction] then
        pipeline.afflictions[affliction] = nil
    end
end

-- Reset the curing process by clearing afflictions
function resetCuringProcess()
    pipeline.afflictions = {}

    for _, affliction in pairs(myaffs) do
        if pipeline.afflictions[affliction] then
            pipeline.afflictions[affliction].in_progress = false
            pipeline.afflictions[affliction].attempts = 0
        end
    end
end

-- Reload the remedies queue
function reloadRemediesQueue()
    remedy = nil  -- Clear the old remedy instance
    queue = nil   -- Clear the old queue table

    -- Reload the script to update remedies
    dofile(getMudletHomeDir() .. "/Achaean System/curing/remedies.lua")

    -- Re-initialize remedy
    remedy = remedy or queue:new()
    
    echo("\nRemedies Loaded")
end






