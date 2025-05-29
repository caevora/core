-- Queue implementation
local srvQueue = {}

function srvQueue.new()
  return {first = 0, last = -1}
end

function srvQueue.isEmpty(queue)
  if type(queue) ~= "table" then return true end
  for i = queue.first, queue.last do
    if queue[i] ~= nil then return false end
  end
  return true
end

function srvQueue.enqueue(queue, item)
  queue.last = queue.last + 1
  queue[queue.last] = item
end

function srvQueue.dequeue(queue)
  local first = queue.first
  if first > queue.last then
    myDebugEcho("white", "Queue is empty")
    return nil
  end
  local item = queue[first]
  queue[first] = nil
  queue.first = first + 1
  return item
end

function srvQueue.getItems(queue)
  local items = {}
  for i = queue.first, queue.last do
    table.insert(items, queue[i])
  end
  return items
end

-- Queue management
local queues = {}

function createQueue(queueType)
  if not queues[queueType] then
    queues[queueType] = srvQueue.new()
  else
    myDebugEcho("white", string.format("Queue type '%s' already exists", queueType))
  end
end

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

function isCommandInQueue(queueType, command)
  local queue = queues[queueType]
  if not queue then return false end
  for i = queue.first, queue.last do
    if queue[i] == command then
      return true
    end
  end
  return false
end

function processQueue(queueType)
  --echo("BALANCE TYPE:" ..queueType)
  
  local balanceInUse = not (gmcp.Char.Vitals.bal == '1')
  local equilibriumInUse = not (gmcp.Char.Vitals.eq == '1')
  local fullbalance = not balanceInUse or not equilibriumInUse

  if not srvQueue.isEmpty(queues["nobal"]) then
    send(table.concat(srvQueue.getItems(queues["nobal"]), "; "))
  end

  if not srvQueue.isEmpty(queues["eqbal"]) and fullbalance then
    send(srvQueue.dequeue(queues["eqbal"]))
  end

  if not srvQueue.isEmpty(queues["bal"]) and not balanceInUse then
    send(srvQueue.dequeue(queues["bal"]))
  end

  if not srvQueue.isEmpty(queues["eq"]) and not equilibriumInUse then
    send(srvQueue.dequeue(queues["eq"]))
  end

  myDebugEcho("white", "Your queues are empty")
end

function clearQueue(queueType)
  local queue = queues[queueType]
  if not queue then return end
  queue.first = 0
  queue.last = -1
end

function clearAllQueues()
  for queueType in pairs(queues) do
    clearQueue(queueType)
  end
end

function printQueueItems(queueType)
  local queue = queues[queueType]
  if not queue then return end
  for i = queue.first, queue.last do
    myDebugEcho("white", tostring(queue[i]))
  end
end

function printAllQueueItems()
  for queueType in pairs(queues) do
    myDebugEcho("white", string.format("Queue Type: %s", queueType))
    printQueueItems(queueType)
  end
end

function reloadSrvQueue()
  queues = {}
  srvQueue = nil
  srvQueue = {}
  dofile(getMudletHomeDir() .. "/Achaean System/system/srvqueue.lua")
  createQueue("eqbal")
  createQueue("bal")
  createQueue("eq")
  createQueue("nobal")
  echo("\nServer Queue Loaded")
end
