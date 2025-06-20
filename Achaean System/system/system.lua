
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
  
    settings.autoAllyManagement = settings.autoAllyManagement or false
	settings.autoEnemyManagement = settings.autoEnemyManagement or false

  cecho("\n<white>System Settings\n-------------------------------\n")

  cechoLink(" <white>(click) ", function()
    clearCmdLine()
    appendCmdLine("set command separator ")
  end, "click to set command separator", true)
  cecho("<white> Command Separator: <white>" .. settings.cmdsep)
  echo"\n"

  -- Common toggles with custom handlers
  addInput("Page Length", "pagelength", "250")
  addInput("Screen Width", "screenwidth", "0")
  addInput("Timeout", "timeout", "0")
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
  addToggle("Prompt Display", "promptEnabled", "", "", "Show Prompt", togglePrompt)
  addToggle("Prompt Percentages", "promptPercentages", "", "", "Show Prompt Percentages", togglePromptPercentages)

   --class logic
	cechoLink(" <white>(click) ", function()
	  local class = PLAYER:myclass()
	  settings.myclass = class
	  initializeFlags()
	  saveTableToJSON(settings, "configuration")
	  configureSystem()
	end, "click to set 'class'", true)

	local classSet = settings.myclass and settings.myclass ~= ""
	cecho(" "..(classSet and "<white>Current Class: <green>"..settings.myclass.." <white>(+)" or "<red>Class: Not Set (-)"))
	echo"\n"

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
  
  -- Auto Ally/Unally
	cechoLink(
	  " <white>(click) ",
	  function()
		settings.autoAllyManagement = not settings.autoAllyManagement

		initializeFlags()
		saveTableToJSON(settings, "configuration")
		configureSystem()
	  end,
	  "click to toggle 'auto ally/unally allies', (ON or OFF)",
	  true
	)

	cecho(" "..(settings.autoAllyManagement and "<white>Auto Ally/Unally (+)" or "<DarkSlateGray>Auto Ally/Unally (-)"))
	echo("\n")


	-- Auto Enemy/Unenemy
	cechoLink(
	  " <white>(click) ",
	  function()
		settings.autoEnemyManagement = not settings.autoEnemyManagement

		initializeFlags()
		saveTableToJSON(settings, "configuration")
		configureSystem()
	  end,
	  "click to toggle 'auto enemy/unenemy enemies', (ON or OFF)",
	  true
	)

	cecho(" "..(settings.autoEnemyManagement and "<white>Auto Enemy/Unenemy (+)" or "<DarkSlateGray>Auto Enemy/Unenemy (-)"))
	echo("\n")

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

function togglePrompt()
  settings.promptEnabled = not settings.promptEnabled

  local promptstring
  if settings.promptPercentages then
    promptstring = "*h#W(#G*%h#W)#Gh#W, *m#W(#G*%m#W)#Cm#G#W, #W(#G*%w#W)#Mw#G#W, #W(#G*%e#W)#Ye#G#W, #w*b*d #R*t #W*T"
  else
    promptstring = "*h#W#Gh#W, *m#W#Cm#G#W, #w*b*d #R*t #W*T"
  end

  if settings.promptEnabled then
    send("CONFIG PROMPT CUSTOM " .. promptstring)
  else
    send("CONFIG PROMPT OFF")
  end

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end

function togglePromptPercentages()
  settings.promptPercentages = not settings.promptPercentages

  local promptstring
  if settings.promptPercentages then
    promptstring = "*h#W(#G*%h#W)#Gh#W, *m#W(#G*%m#W)#Cm#G#W, #W(#G*%w#W)#Mw#G#W, #W(#G*%e#W)#Ye#G#W, #w*b*d #R*t #W*T"
  else
    promptstring = "*h#W#Gh#W, *m#W#Cm#G#W, #w*b*d #R*t #W*T"
  end

  if settings.promptEnabled then
    send("CONFIG PROMPT CUSTOM " .. promptstring)
  else
    send("CONFIG PROMPT OFF")
  end

  initializeFlags()
  saveTableToJSON(settings, "configuration")
  configureSystem()
end


function reloadSystem()
  -- Reload the updated script
  dofile(getMudletHomeDir() .. "/Achaean System/system/system.lua")
  cecho("\n<green>Configuration File Loaded.\n")
end