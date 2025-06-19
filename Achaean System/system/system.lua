
-- Helper to handle toggles and settings
function addToggle(label, settingKey, onCmd, offCmd, displayText, customHandler)
  cechoLink(
    " <white>(click) ",
    function()
      if customHandler then
        customHandler()
      else
        settings[settingKey] = not settings[settingKey]
        if onCmd ~= "" and offCmd ~= "" then
          send(settings[settingKey] and onCmd or offCmd)
        end
        initializeFlags()
        saveTableToJSON(settings, "configuration")
        configureSystem()
      end
    end,
    "click to toggle '"..label.."'",
    true
  )
  cecho(" "..(settings[settingKey] and "<white>"..displayText.." (+)" or "<DarkSlateGray>"..displayText.." (-)"))
  echo"\n"
end

-- Helper to create input setting
function addInput(label, settingKey, example, customHandler)
  cechoLink(
    " <white>(click) ",
    function()
      if customHandler then
        customHandler()
      else
        clearCmdLine()
        appendCmdLine("set " .. settingKey .. " " .. example)
      end
    end,
    "click to set '"..label.."'",
    true
  )
  local val = settings[settingKey]
  local isSet = val and tostring(val) ~= ""
  cecho(" "..(isSet and "<white>"..label..": <green>"..val.." <white>(+)" or "<red>"..label..": Not Set (-)"))
  echo"\n"
end

function configureSystem()
  if not settings.cmdsep or settings.cmdsep == "" then
    settings.cmdsep = ";"
    send("set command separator " .. settings.cmdsep)
    cecho("\n<yellow>Command separator not set. Defaulting to ';'.\n")
  end

  cecho("\n<white>System Settings\n-------------------------------\n")

  cechoLink(" <white>(click) ", function()
    clearCmdLine()
    appendCmdLine("set command separator ")
  end, "click to set command separator", true)
  cecho("<white> Command Separator: <white>" .. settings.cmdsep)
  echo"\n"

  -- Common toggles with custom handlers
  addToggle("ANSI", "ansi", "CONFIG ANSI ON", "CONFIG ANSI OFF", "ANSI", toggleAnsi)
  addToggle("MXP", "mxp", "CONFIG MXP ON", "CONFIG MXP OFF", "MXP", toggleMXP)
  addToggle("Queue Alerts", "showqueuealerts", "CONFIG SHOWQUEUEALERTS ON", "CONFIG SHOWQUEUEALERTS OFF", "Show Queue Alerts")
  addToggle("Kill Warning", "killwarning", "CONFIG KILLWARNING ON", "CONFIG KILLWARNING OFF", "Kill Warning")
  addToggle("Affliction Messages", "uamessages", "CONFIG UNIVERSALAFFLICTIONMESSAGES ON", "CONFIG UNIVERSALAFFLICTIONMESSAGES OFF", "Affliction Messages")
  addToggle("Auto Open Doors", "autoopendoors", "CONFIG AUTOOPENDOORS YES", "CONFIG AUTOOPENDOORS NO", "Open Doors")
  addToggle("Batching", "batching", "CURING BATCH ON", "CURING BATCH OFF", "Batching")
  addToggle("Debug Mode", "debug", "", "", "DEBUG", toggleDebug)
  addToggle("Inventory Display", "showInventory", "", "", "Show Inventory", toggleInventory)
  addToggle("Scrollbar", "showScrollbar", "", "", "Show Scrollbar", toggleShowScrollbar)
  addToggle("Curing", "curing", "CURING ON", "CURING OFF", "Curing")
  addToggle("Advanced Curing", "advancedcuring", "CONFIG ADVANCEDCURING ON", "CONFIG ADVANCEDCURING OFF", "Advanced Curing")
  addToggle("Reporting", "reporting", "CURING REPORTING ON", "CURING REPORTING OFF", "Curing Reporting")
  addToggle("Defences", "defences", "CURING DEFENCES ON", "CURING DEFENCES OFF", "Defences")
  addToggle("Sipping", "sipping", "CURING SIPPING ON", "CURING SIPPING OFF", "Sipping")
  addToggle("Afflictions", "afflictions", "CURING AFFLICTIONS ON", "CURING AFFLICTIONS OFF", "Afflictions")
  addToggle("Insomnia", "insomnia", "CURING INSOMNIA ON", "CURING INSOMNIA OFF", "Insomnia")
  addToggle("Clot", "clot", "CURING USECLOT ON", "CURING USECLOT OFF", "Clot")
  addToggle("Tree", "tree", "CURING TREE ON", "CURING TREE OFF", "Tree")
  addToggle("Focus", "focus", "CURING FOCUS ON", "CURING FOCUS OFF", "Focus")
  addToggle("Vault", "usevault", "CURING USEVAULT ON", "CURING USEVAULT OFF", "Vault")

  -- Cure method
  cechoLink(" <white>(click) ", function()
    if settings.cureMethod == "alchemical" then
      settings.cureMethod = "herbal"
      send("CURING TRANSMUTATION OFF")
    else
      settings.cureMethod = "alchemical"
      send("CURING TRANSMUTATION ON")
    end
    initializeFlags()
    saveTableToJSON(settings, "configuration")
    configureSystem()
  end, "click to toggle 'cure method'", true)
  cecho(" "..(settings.cureMethod == "alchemical" and "<white>Cure Type: <cyan>Alchemical (+)" or "<white>Cure Type: <green>Concoctions (-)"))
  echo"\n"

  -- Priority toggle
  cechoLink(" <white>(click) ", function()
    if settings.sippriority == "CURING PRIORITY MANA" then
      settings.sippriority = "CURING PRIORITY HEALTH"
      send("CURING PRIORITY HEALTH")
    else
      settings.sippriority = "CURING PRIORITY MANA"
      send("CURING PRIORITY MANA")
    end
    initializeFlags()
    saveTableToJSON(settings, "configuration")
    configureSystem()
  end, "click to toggle 'sip priority'", true)
  local prioText = (settings.sippriority == "CURING PRIORITY MANA" and "<cyan>MANA" or "<green>HEALTH")
  cecho(" <white>Sipping Priority: " .. prioText .. "\n")

  -- Input configurations
  addInput("Mount", "mount", "my_mount")
  addInput("Curing Set", "curingset", "default")
  addInput("Sip Health", "siphealth", "95")
  addInput("Sip Mana", "sipmana", "95")
  addInput("Health Affs Above", "healthaffsabove", "95", function()
    clearCmdLine()
    appendCmdLine("curing healthaffsabove 95")
  end)
  addInput("Mana Threshold", "manathreshold", "70")
  addInput("Moss Health", "mosshealth", "75")
  addInput("Moss Mana", "mossmana", "75")
end

-- Toggle handler for showScrollbar
function toggleShowScrollbar()
  settings.showScrollbar = not settings.showScrollbar

  -- Update the display
  if settings.showScrollbar then
    enableScrollBar("main")
  else
    disableScrollBar()
  end

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end

-- Toggle handler for ANSI
function toggleAnsi()
  settings.ansi = not settings.ansi

  if settings.ansi then
    send("CONFIG ANSI ON")
  else
    send("CONFIG ANSI OFF")
  end

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end

-- Toggle handler for MXP
function toggleMXP()
  settings.mxp = not settings.mxp

  if settings.mxp then
    send("CONFIG MXP ON")
  else
    send("CONFIG MXP OFF")
  end

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end

-- Toggle handler for Debug Mode
function toggleDebug()
  settings.debug = not settings.debug
  DEBUG_MODE = settings.debug or false

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end

-- Toggle handler for Inventory Display
function toggleInventory()
  settings.showInventory = not settings.showInventory

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end


function reloadSystem()
  -- Reload the updated script
  dofile(getMudletHomeDir() .. "/Achaean System/system/system.lua")
  cecho("\n<green>Configuration File Loaded.\n")
end