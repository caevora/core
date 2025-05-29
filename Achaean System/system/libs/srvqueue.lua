-- Queue implementation
local srvQueue = {}

-- Create a new queue
function srvQueue.new()
  return {first = 0, last = -1}
end

-- Check if the queue is empty
function srvQueue.isEmpty(queue)
  return queue.first > queue.last
end

-- Add an item to the end of the queue
function srvQueue.enqueue(queue, item)
  local last = queue.last + 1
  queue.last = last
  queue[last] = item
end

-- Remove and return the first item from the queue
function srvQueue.dequeue(queue)
  local first = queue.first
  if first > queue.last then
    myDebugEcho("white", "Queue is empty")
  end
  local item = queue[first]
  queue[first] = nil
  queue.first = first + 1
  return item
end

-- Get all items in the queue as a table
function srvQueue.getItems(queue)
  local items = {}
  for i = queue.first, queue.last do
    table.insert(items, queue[i])
  end
  return items
end

-- Table to hold different queue types
local queues = {}

-- Create a new queue with the given type and optional rate limit
function createQueue(queueType)
  if not queues[queueType] then
    queues[queueType] = srvQueue.new()
  else
    myDebugEcho("white", string.format("Queue type '%s' already exists", queueType))
  end
end

-- Add a command to the specified queue type without a rate limit
function addToQueue(queueType, command, prepend)
  local queue = queues[queueType]
  if not queue then
    myDebugEcho("white", string.format("Queue type '%s' does not exist", queueType))
    return
  end
  if prepend then
    queue.first = queue.first - 1
    queue[queue.first] = command
  else
    srvQueue.enqueue(queue, command)
  end
end

-- Custom function to check if a command exists in the queue
function isCommandInQueue(queueType, command)
  local queue = queues[queueType]
  if not queue then
    myDebugEcho("white", string.format("Queue is not defined for type: %s", queueType))
    return false
  end
  myDebugEcho(
    "white",
    string.format(
      "Queue Info: %s First: %s Last: %s",
      tostring(queueType),
      tostring(queue.first),
      tostring(queue.last)
    )
  )
  
  -- Ensure the queue range is valid before checking
  if queue.first > queue.last then
    myDebugEcho("red", "Invalid queue range detected!")
    return false
  end

  -- Compare each command in the queue with the target command
  for i = queue.first, queue.last do
    myDebugEcho(
      "white", string.format("Comparing: %s %s", tostring(command), tostring(queue[i]))
    )
    if queue[i] == command then
      return true
    end
  end
  return false
end





function isShieldBreakInQueue(queueType, target)
  local queue = queues[queueType]
  local class = gmcp.Char.Status.class:lower()
  if not queue then
    return false
  end
  local classData = bragelist[class]
  if not classData then
    return false
  end
  for _, data in pairs(classData) do
    if data.enabled and data.type == "shield break" then
      local shieldBreakCommand = data.command:gsub("@tar", target)
      for i = queue.first, queue.last do
        myDebugEcho(
          "white",
          string.format("Comparing: %s %s", tostring(shieldBreakCommand), tostring(queue[i]))
        )
        if queue[i] == shieldBreakCommand then
          return true
        end
      end
    end
  end
  -- Check for regular shield break attack in huntSettingsData
  local regularShieldBreakCommand =
    huntSettingsData[class]["regular shield break"]:gsub("@tar", target)
  for i = queue.first, queue.last do
    myDebugEcho(
      "white",
      string.format(
        "Comparing (regular): %s %s", tostring(regularShieldBreakCommand), tostring(queue[i])
      )
    )
    if queue[i] == regularShieldBreakCommand then
      return true
    end
  end
  return false
end

--Process the queue of the specified type
function processQueue(queueType)
  local balanceInUse = not (gmcp.Char.Vitals.bal == '1')
  local equilibriumInUse = not (gmcp.Char.Vitals.eq == '1')
  local fullbalance = not (balanceInUse) or not (equilibriumInUse)
  if not srvQueue.isEmpty(queues["nobal"]) then
    local nobalCommands = srvQueue.getItems(queues["nobal"])
    local nobalCommandString = table.concat(nobalCommands, "; ")
    send(nobalCommandString)
  end
  if not srvQueue.isEmpty(queues["eqbal"]) then
    if fullbalance and not srvQueue.isEmpty(queues["eqbal"]) then
      local queuedCommand = srvQueue.dequeue(queues["eqbal"])
      send(queuedCommand)
    end
  end
  if not srvQueue.isEmpty(queues["bal"]) then
    if not (balanceInUse) and not srvQueue.isEmpty(queues["bal"]) then
      local queuedCommand = srvQueue.dequeue(queues["bal"])
      send(queuedCommand)
    end
  end
  if not srvQueue.isEmpty(queues["eq"]) then
    if not (equilibriumInUse) and not srvQueue.isEmpty(queues["eq"]) then
      local queuedCommand = srvQueue.dequeue(queues["eq"])
      send(queuedCommand)
    end
  end
  --clearQueue(queueType)
  myDebugEcho("white", "Your queues are empty")
end

-- Custom wait function
function wait(seconds)
  local start = os.clock()
  while os.clock() + getNetworkLatency() - start <= seconds + getNetworkLatency() do
    -- Do nothing and wait for the specified time
  end
end

-- Clear the specified queue
function clearQueue(queueType)
  local queue = queues[queueType]
  if not queue then
    myDebugEcho("white", string.format("Queue type '%s' does not exist", tostring(queueType)))
    return
  end
  -- Properly reset the indices
  queue.first = 0
  queue.last = -1
  -- Clear the existing items in the queue
  while not srvQueue.isEmpty(queue) do
    srvQueue.dequeue(queue)
    send("clearqueue " .. queueType)
  end
  myDebugEcho("white", string.format("Cleared queue type: %s", tostring(queueType)))
end

-- Clear all queues
function clearAllQueues()
  for queueType, _ in pairs(queues) do
    clearQueue(queueType)
  end
end

-- Print all items in the specified queue
function printQueueItems(queueType)
  local queue = queues[queueType]
  if not queue then
    myDebugEcho("white", string.format("Queue type '%s' does not exist", tostring(queueType)))
  end
  for i = queue.first, queue.last do
    myDebugEcho("white", tostring(queue[i]))
    return queue[i]
  end
end

-- Print items in all queue types
function printAllQueueItems()
  for queueType, _ in pairs(queues) do
    myDebugEcho("white", string.format("Queue Type: %s", tostring(queueType)))
    printQueueItems(queueType)
  end
end

function reloadSrvQueue()
    -- Clear the current srvQueue and related data
    queues = {} -- Clear all queues
    srvQueue = nil  -- Clear the old srvQueue instance
    srvQueue = {}   -- Reinitialize srvQueue as an empty table

    -- Reload the updated script (if srvQueue is defined in it)
    dofile(getMudletHomeDir() .. "/Achaean System/system/srvqueue.lua")  -- Adjust the path as needed

    -- Optionally, re-initialize the specific queues used in your system
    createQueue("eqbal")
    createQueue("bal")
    createQueue("eq")
    createQueue("class")
    createQueue("nobal")
  
    echo("\nServer Queue Loaded")
end

