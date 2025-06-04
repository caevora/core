
-- Utility function to check if a file exists

function fileExists(name)
  local f = io.open(name, "r")
  if f then
    f:close()
    return true
  else
    return false
  end
end




function ensureDirectoryExists(path)
    if not lfs.attributes(path, "mode") then
        lfs.mkdir(path)
        if DEBUG_MODE then
          cecho("<green>Created directory: " .. path .. "\n")
        end
    end
end


function ensureFileExists(directory, filename, mode, tableToUse)
    local fullPath = directory .. "/" .. filename

    -- Ensure the directory exists
    if not lfs.attributes(directory, "mode") then
        lfs.mkdir(directory)
        if DEBUG_MODE then
          cecho("<green>Created directory: " .. directory .. "\n")
        end
    end

    -- Check if the file exists; if not, create it
    if not fileExists(fullPath) then
        local file = io.open(fullPath, "w")
        if file then
            file:close()
           if DEBUG_MODE then
              cecho("<green>Created new file: " .. fullPath .. "\n")
            end
            if tableToUse then
                table.save(fullPath, tableToUse)
            end
        else
           if DEBUG_MODE then
              cecho("<red>Error: Could not create file: " .. fullPath .. "\n")
           end
            return
        end
    end

    -- Load or save the file depending on the mode
    if mode == "load" and tableToUse then
        table.load(fullPath, tableToUse)
        if DEBUG_MODE then cecho("<green>Loaded file: " .. fullPath .. "\n")  end
    elseif mode == "save" and tableToUse then
        table.save(fullPath, tableToUse)

           if DEBUG_MODE then cecho("<green>Saved file: " .. fullPath .. "\n") end

    end
end

function deepCopy(orig)
  if type(orig) ~= "table" then
    return orig
  end
  local copy = {}
  for key, value in pairs(orig) do
    copy[key] = deepCopy(value)
  end
  return copy
end

function deepcopyaffstrack()
  tempafflist = {}
  for i in pairs(affstrack.score) do
    tempafflist[i] = affstrack.score[i]
  end
end

function deeppasteaffstrack()
  for i in pairs(affstrack.score) do
    affstrack.score[i] = tempafflist[i]
  end
end

function arraytest(testvar)
  cecho(testvar[1])
end

-- Function to find if a specific item exists in a list (with optional return index)
function listfind(list, var, returnIndex)
    for i = 1, #list do
        if list[i] == var then
            return returnIndex and i or true
        end
    end
    return false
end


function flattenTable(t)
    local result = {}
    for _, v in ipairs(t) do
        if type(v) == "table" then
            for _, nested in ipairs(v) do
                table.insert(result, nested)
            end
        else
            table.insert(result, v)
        end
    end
    return result
end


--[[
  safeFlatten(value)
  Ensures that the input value is returned as a flat list (array-style table),
  even if it's a single string, nil, or a nested table. This is useful for
  fields like `requires` or `blockers` that sometimes appear as:
    - a single string:         "sleeping"
    - a flat table:            { "sleeping", "paralysis" }
    - a nested table:          { {"weariness", "recklessness"}, "sleeping" }
    - or nil
]]
function safeFlatten(value)
    local result = {}

    -- Case 1: If value is a table
    if type(value) == "table" then
        for _, v in ipairs(value) do
            -- If it's a nested table (e.g., {"a", "b"} inside the outer list)
            if type(v) == "table" then
                for _, nested in ipairs(v) do
                    table.insert(result, nested)
                end
            else
                -- Flat value, insert as-is
                table.insert(result, v)
            end
        end

    -- Case 2: If it's a string, number, etc. (non-table but not nil)
    elseif value ~= nil then
        table.insert(result, value)

    -- Case 3: value is nil → result remains empty
    end

    return result
end


--local myList = {"apple", "banana", "cherry"}
--local updatedList = listremove(myList, "banana")


-- Function to remove an item from a list
function listremove(list, var)
    local newList = {}  -- Create a new list to store items
    for i = 1, #list do
        if list[i] ~= var then  -- If the item is not equal to the one we're removing, add it to newList
            table.insert(newList, list[i])
        end
    end
    return newList  -- Return the new list
end


--numbers with commas
function math.reint(i)
  return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function tableLength(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

function tableToString(tbl)
  if tbl == nil then
    return ""
  end
  local result = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      local subResult = {}
      for subK, subV in pairs(v) do
        table.insert(subResult, tostring(subK) .. ": " .. tostring(subV))
      end
      table.insert(result, tostring(k) .. ": {" .. table.concat(subResult, ", ") .. "}")
    else
      table.insert(result, tostring(k) .. ": " .. tostring(v))
    end
  end
  return "{" .. table.concat(result, ", ") .. "}"
end

function printTable(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    if type(v) == "table" then
      print(string.rep("  ", indent) .. tostring(k) .. ":")
      printTable(v, indent + 1)
    else
      print(string.rep("  ", indent) .. tostring(k) .. ": " .. tostring(v))
    end
  end
end

function tablesEqual(t1, t2)
  if #t1 ~= #t2 then
    return false
  end
  local seen = {}
  for _, v in ipairs(t1) do
    seen[v] = true
  end
  for _, v in ipairs(t2) do
    if not seen[v] then
      return false
    end
  end
  return true
end

function trimDecimal(num)
  -- Round the number to two decimal places
  local roundedNum = math.floor(num * 100 + 0.5) / 100
  -- Format the number to a string with two decimal places
  return string.format("%.2f", roundedNum)
end

-- Function to silence the output of tempTimer

function silentTempTimer(seconds, callback)
  local originalPrint = print
  -- Backup original print function
  print =
    function()
    end
  -- Override print function to do nothing
  tempTimer(
    seconds,
    function()
      print = originalPrint
      -- Restore original print function
      callback()
    end
  )
end

function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
    end
    setmetatable(copy, deepcopy(getmetatable(orig)))
  else
    -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

--BETTER RANDOM

function betterRand()
  randomtable = {}
  for i = 1, 97 do
    randomtable[i] = math.random()
  end
  local x = math.random()
  local i = 1 + math.floor(97 * x)
  x, randomtable[i] = randomtable[i], x
  return x
end

-- Function to find the index of an element in a table

function findIndex(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      return i
    end
  end
  return nil
end

-- Function to copy a table

function copyTable(orig)
  local copy = {}
  for key, value in pairs(orig) do
    copy[key] = value
  end
  return copy
end

function toggleDebugMode()
  if DEBUG_MODE then
    DEBUG_MODE = false
    cecho("\n<red>Debug mode has been turned off.")
  else
    DEBUG_MODE = true
    cecho("\n<green>Debug mode has been turned on.")
  end
end

--function toggleGUIGauges()
--showGauges = showGauges or false
--if not showGauges then
--  showGauges = true
-- gui.gauges:show()
--  cecho("\n<white>(<gold>GUI<white>):<green> Gauges Enabled")
--elseif showGauges then
-- showGauges = false
-- gui.gauges:hide()
-- cecho("\n<white>(<gold>GUI<white>):<red> Gauges Disabled")
-- end
--end
-- 2. Utility Functions

function findkey(list, item, var)
  for v, k in pairs(list) do
    if v == item then
      return true
    end
  end
  return false
end

function removeElement(tbl, value)
  for i, v in ipairs(tbl) do
    if v == value then
      table.remove(tbl, i)
      --return true
    end
  end
  --return false
end

-- Utility function to check if any elements from subset are present in elements

function containsAny(elements, subset)
  for _, v in pairs(subset) do
    if table.contains(elements, v) then
      return true
    end
  end
  return false
end

function get_aff_modifiers(cure_type)
  local keys = {}
  local aff_modifiers = balance_data[cure_type].aff_modifiers
  for k, v in pairs(aff_modifiers) do
    local entry = {affliction = k, multiplier = v.multiplier, offset = v.offset}
    table.insert(keys, entry)
  end
  return keys
end

function myTimerEcho(DEBUG_MODE, balanceType, string, color)
  local nextline = ""
  local debug = DEBUG_MODE
  moveCursorEnd("main")
  if getCurrentLine() ~= "" then
    nextline = "\n"
  end
  if debug then
    cecho("" .. nextline .. "<" .. color .. ">" .. balance_data[balanceType].echo_title .. string)
  end
end

function myDebugEcho(color, string)
  local nextline = ""
  local debug = DEBUG_MODE
  moveCursorEnd("main")
  if getCurrentLine() ~= "" then
    nextline = "\n"
  end
  if debug then
    cecho("" .. nextline .. "<" .. color .. ">" .. string)
  end
end

function tryingtodo(what)
  -- Removing trailing semicolon
  local trimmedWhat = what:gsub(";$", "")
  -- Outputting the trimmed value
  cecho(
    "\n<LightBlue>CURES QUEUED: <DarkSlateGrey>(<LightBlue>" .. trimmedWhat .. "<DarkSlateGrey>)"
  )
end

function myEcho(color, string)
  local nextline = ""
  moveCursorEnd("main")
  if getCurrentLine() ~= "" then
    nextline = "\n"
  end
  cecho("" .. nextline .. "<" .. color .. ">" .. string)
end

function myHEcho(string)
  local nextline = ""
  --local debug = DEBUG_MODE
  moveCursorEnd("main")
  if getCurrentLine() ~= "" then
    nextline = "\n"
  end
  --if debug then
  hecho(nextline .. string)
  --end
end

-- Function to check if matches[2] is one of the desired words, case-insensitive

function checkWord(matches)
  -- Possible words to check
  local validWords = {"yes", "true", "on"}
  -- Generate all possible capitalizations for each word
  for _, word in ipairs(validWords) do
    local validCapitalizations = generateCapitalizations(word)
    -- Check if matches[2] matches any capitalization of the word
    for _, capitalization in ipairs(validCapitalizations) do
      if matches[2] == capitalization then
        return true
      end
    end
  end
  return false
end

-- Function to generate all capitalization combinations of a word

function generateCapitalizations(word)
  local combinations = {}

  local function generate(word, index)
    if index > #word then
      table.insert(combinations, word)
      return
    end
    -- Try both lowercase and uppercase for each letter
    generate(
      word:sub(1, index - 1) .. word:sub(index, index):lower() .. word:sub(index + 1), index + 1
    )
    generate(
      word:sub(1, index - 1) .. word:sub(index, index):upper() .. word:sub(index + 1), index + 1
    )
  end

  generate(word, 1)
  return combinations
end

function checkBooleanString(value)
  -- Convert the input value to uppercase for case-insensitive comparison
  value = string.upper(value)
  -- Check if the value matches any of the predefined true values
  if value == "YES" or value == "ON" or value == "TRUE" or value == "1" then
    return true
  else
    return false
  end
end

function city_capture()
  for k, v in pairs(gmcp.Char.Status) do
    if k == "city" then
      if string.starts(v, "(None)") then
        return "None"
      end
      if string.starts(v, "Ashtan") then
        return "Ashtan"
      end
      if string.starts(v, "Eleusis") then
        return "Eleusis"
      end
      if string.starts(v, "Mhaldor") then
        return "Mhaldor"
      end
      if string.starts(v, "Hashan") then
        return "Hashan"
      end
      if string.starts(v, "Targossas") then
        return "Targossas"
      end
      if string.starts(v, "Cyrene") then
        return "Cyrene"
      end
    end
  end
end

function inaparty()
  if not gmcp.Comm then
    return false
  end
  for _, v in ipairs(gmcp.Comm.Channel.List) do
    if v.name == "party" then
      return true
    end
  end
  return false
end




function afflictionClassEnabled()
  local affliction_classes = {"apostate", "serpent", "shaman", "bard", "jester"}
  for _, v in pairs(affliction_classes) do
    if enemyclass[string.lower(v)].enabled then
      return true
    end
  end
  return false
end

function channels()
  display(gmcp.Comm.Channel.List)
end

keystolist =
  function(t)
    local r = {}
    for k, v in pairs(t) do
      r[#r + 1] = k
    end
    return r
  end

function listfind(list, var, vartwo)
  local re = false
  for i = 1, #list, 1 do
    if list[i] == var then
      re = true
      if vartwo then
        re = i
      end
    end
  end
  return re
end

function flip(var)
  if var == true then
    return false
  else
    return true
  end
end

function ts(var)
  if var < os.clock() then
    return true
  else
    return false
  end
end

function highlightline(selectstring)
  selectString(selectstring, 1)
  setItalics(true)
  fg("red")
  resetFormat()
  deselect()
end

function highlightline(selectstring, bgcolor, fgcolor, bold, italics)
  setBold(false)
  setItalics(true)
  bg(bgcolor)
  fg(fgcolor)
  resetFormat()
  deselect()
end

function boxDisplay(msg, color)
  deselect()
  local colTbl = {}
  if color then
    colTbl = string.split(color, ":")
    for k = 1, 2 do
      if colTbl[k] == "" then
        colTbl[k] = nil
      end
    end
    if colTbl[2] then
      bg(colTbl[2])
    end
  end
  colTbl[1] = colTbl[1] or "red"
  fg(colTbl[1])
  local leng = ((2 * string.len(msg)) + 11)
  local mes = string.upper(msg)
  echo("\n ")
  echo(string.rep("-", leng + 2))
  echo(" \n|     " .. mes .. " | " .. mes .. "     |\n ")
  echo(string.rep("-", leng + 2))
  echo(" \n")
  resetFormat()
end

   
function loadMethods()

    -- Reload the updated script (if srvQueue is defined in it)
    dofile(getMudletHomeDir() .. "/Achaean System/system/methods.lua")  -- Adjust the path as needed
  
    echo("\nMethods File Loaded")
end