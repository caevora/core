function configureSystem()


  cecho("\n<white>System Settings\n-------------------------------\n")
 
  -- Configure command separator
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set command separator ")
	  end,
	  "click to set command separator",
	  true

	  
  )
 
	
 
	cecho("<white> Command Separator: <white>" .. settings.cmdsep)
    echo"\n"
  
  
  -- configure ANSI
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.ansi = not settings.ansi

	  if settings.ansi then	
		send("CONFIG ANSI ON")
	  else
		send("CONFIG ANSI OFF")
	  end
	  
    initializeFlags()		

			local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
			local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
			local filename = "configuration.lua"
			ensureFileExists(baseDir, filename, "save", settings)

	configureSystem()	
	
	end,
    "click to toggle 'ANSI', (ON or OFF)",
    true
  )
  cecho(" "..(settings.ansi and "<white>ANSI (+)" or "<DarkSlateGray>ANSI (-)"))
  echo"\n"


  -- configure MXP
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.mxp = not settings.mxp

	  if settings.mxp then	
		send("CONFIG MXP ON")
	  else
		send("CONFIG MXP OFF")
	  end
	  
	initializeFlags()		
	
		local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
			
	configureSystem()	
	
	 end,
    "click to toggle 'MXP', (ON or OFF)",
    true
  )
  
  cecho(" "..(settings.mxp and "<white>MXP (+)" or "<DarkSlateGray>MXP (-)"))
  echo"\n"    

  
	-- Configure page length
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set pagelength 250")
	  end,
	  "click to set page length",
	  true
	)

	-- Initialize pagelength to false
	local pagelength = false

	-- Check if settings.pagelength is a number
	if type(settings.pagelength) == "number" then
	  pagelength = true
	else
	  pagelength = false
	end

	cecho(" "..(pagelength and "<white>Page Length: <green>"..settings.pagelength.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")

  
  
  	-- Configure screen width
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set screenwidth 0")
	  end,
	  "click to set screen width",
	  true
	)

	-- Initialize screenwidth to false
	local screenwidth = false

	-- Check if settings.pagelength is a number
	if type(settings.screenwidth) == "number" then
	  screenwidth = true
	else
	  screenwidth = false
	end

	cecho(" "..(screenwidth and "<white>Screen Width: <green>"..settings.screenwidth.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")
  
  
  
    	-- Configure time out
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set timeout 0")
	  end,
	  "click to set system timeout",
	  true
	)

	-- Initialize timeout to false
	local timeout = false

	-- Check if settings.pagelength is a number
	if type(settings.timeout) == "number" then
	  timeout = true
	else
	  timeout = false
	end

	cecho(" "..(timeout and "<white>Timeout: <green>"..settings.timeout.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")
    
  
  
  
   --Auto Open Doors
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.showqueuealerts = not settings.showqueuealerts

	  if settings.showqueuealerts then	
		 send("CONFIG SHOWQUEUEALERTS ON")
	  else
		 send("CONFIG SHOWQUEUEALERTS OFF")
	  end

	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()
	
	end,
    "click to toggle 'show queue alerts', (ON or OFF)",
    true
  )

  cecho(" "..(settings.showqueuealerts and "<white>Show Queue Alerts (+)" or "<DarkSlateGray>Show Queue Alerts (-)"))
  echo"\n"
  
  --Kill Warning
    cechoLink(
    " <white>(click) ",
    function()
    
	  settings.killwarning = not settings.killwarning

	  if settings.killwarning then	
		 send("CONFIG KILLWARNING ON")
	  else
		 send("CONFIG KILLWARNING OFF")
	  end
	  
	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()	  
	
	end,
    "click to toggle 'kill warning', (ON or OFF)",
    true
  )
  cecho(" "..(settings.killwarning and "<white>Kill Warning (+)" or "<DarkSlateGray>Kill Warning (-)"))
  echo"\n"
  
  
    --Universal Affliction Messages
    cechoLink(
    " <white>(click) ",
    function()
    
	  settings.uamessages = not settings.uamessages

	  if settings.uamessages then	
		 send("CONFIG UNIVERSALAFFLICTIONMESSAGES ON")
	  else
		 send("CONFIG UNIVERSALAFFLICTIONMESSAGES OFF")
	  end

	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()

	end,
    "click to toggle 'universal affliction messages', (ON or OFF)",
    true
  )
  cecho(" "..(settings.uamessages and "<white>Afflictin Messages (+)" or "<DarkSlateGray>Affliction Messages (-)"))
  echo"\n"
  
  
  
    --Auto Open Doors
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.autoopendoors = not settings.autoopendoors

	  if settings.autoopendoors then	
		 send("CONFIG AUTOOPENDOORS YES")
	  else
		 send("CONFIG AUTOOPENDOORS NO")
	  end

	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()
	
	end,
    "click to toggle 'auto open doors', (ON or OFF)",
    true
  )
  cecho(" "..(settings.autoopendoors and "<white>Open Doors (+)" or "<DarkSlateGray>Open Doors (-)"))
  echo"\n"

  
    --show batching
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.batching = not settings.batching
	
	  if settings.batching then	
		send("CURING BATCH ON")
	  else
		send("CURING BATCH OFF")
	  end

    initializeFlags()		
	configureSystem()	  
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		

	end,
    "click to toggle 'batching', (ON or OFF)",
    true
  )
  cecho(" "..(batching and "<white>Batching (+)" or "<DarkSlateGray>Batching (-)"))
  echo"\n"
     
  
  -- configure DEBUG MODE
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.debug = not settings.debug


	  if settings.debug then
		DEBUG_MODE = true
	  else
		DEBUG_MODE = false
	  end  

	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()

    end,
    "click to toggle 'DEBUG MODE', (ON or OFF)",
    true
  )
  cecho(" "..(settings.debug and "<white>DEBUG (+)" or "<DarkSlateGray>DEBUG (-)"))
  echo"\n"
  
   
      --set class
  cechoLink(
    " <white>(click) ",
    function()
	  local class = PLAYER:myclass()
	  settings.myclass = class

    local class = false
  	-- Check if settings.myclass is an empty string
	if settings.myclass ~= "" then
	  class = true
	else
	  class = false
	end

	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	configureSystem()
	
	end,
    "click to set 'class'",
    true
  )

	cecho(" "..(class and "<white>Current Class: <green>"..settings.myclass.." <white>(+)" or "<red>Not Set (-)"))
    echo"\n"
  
  
  
  --show inventory
  cechoLink(
    " <white>(click) ",
    function()

		settings.showInventory = not settings.showInventory
					
		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()			
	
    end,
    "click to toggle 'show inventory', (ON or OFF)",
    true
  )
  
  cecho(" "..(settings.showInventory and "<white>Show Inventory (+)" or "<DarkSlateGray>Show Inventory (-)"))
  echo"\n"
  
  
  
  --show scrollbar
  cechoLink(
    " <white>(click) ",
    function()
	  
	  settings.showScrollbar = not settings.showScrollbar

		-- Update the display
	    
		  if settings.showScrollbar then
			enableScrollBar("main")
		  else
			disableScrollBar()
		  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	  
    end,
    "click to toggle 'show scrollbar', (ON or OFF)",
    true
  )

  cecho(" "..(settings.showScrollbar and "<white>Show Scrollbar (+)" or "<DarkSlateGray>Show Scrollbar (-)"))
  echo"\n"  
  
  
  -- show prompt
  cechoLink(
    " <white>(click) ",
    function()

		settings.promptEnabled = not settings.promptEnabled

		  if settings.promptPercentages then
			promptstring = "*h#W(#G*%h#W)#Gh#W, *m#W(#G*%m#W)#Cm#G#W, #W(#G*%w#W)#Mw#G#W, #W(#G*%e#W)#Ye#G#W, #w*b*d #R*t #W*T"
		  else
			promptstring = "*h#W#Gh#W, *m#W#Cm#G#W, #w*b*d #R*t #W*T" --"*h#W#Gh#W, *m#W#Cm#G#W, *w#W#Mw#G#W, *e#W#Ye#G#W, #w*b*d #R*t #W*T"		  
		  end  

		  if settings.promptEnabled then
			send("CONFIG PROMPT CUSTOM " .. promptstring)
		  else
			send("CONFIG PROMPT OFF")
		  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()

		send("")		
		
    end,
    "click to toggle 'show prompt', (ON or OFF)",
    true
  )

  cecho(" "..(settings.promptEnabled and "<white>Show Prompt (+)" or "<DarkSlateGray>Show Prompt (-)"))
  echo("\n")
  
  
  -- show prompt percentages
  cechoLink(
    " <white>(click) ",
    function()
	  
	  settings.promptPercentages = not settings.promptPercentages
	  
	  if settings.promptPercentages then
		promptstring = "*h#W(#G*%h#W)#Gh#W, *m#W(#G*%m#W)#Cm#G#W, #W(#G*%w#W)#Mw#G#W, #W(#G*%e#W)#Ye#G#W, #w*b*d #R*t #W*T"
	  else
		promptstring = "*h#W#Gh#W, *m#W#Cm#G#W, #w*b*d #R*t #W*T" --"*h#W#Gh#W, *m#W#Cm#G#W, *w#W#Mw#G#W, *e#W#Ye#G#W, #w*b*d #R*t #W*T"		  
	  end    
	  
	  if settings.promptEnabled then
		send("CONFIG PROMPT CUSTOM " .. promptstring)
	  else
		send("CONFIG PROMPT OFF")
	  end
	  
	  send("")
	  
	  initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
	  configureSystem()	

    end,
    "click to toggle 'show prompt percentages', (ON or OFF)",
    true
  )

  
  cecho(" "..(settings.promptPercentages and "<white>Show Prompt Percentages (+)" or "<DarkSlateGray>Show Prompt Percentages (-)"))
  echo("\n")  


    --Toggle Curing
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.curing = not settings.curing

	  if settings.curing then	
		  send("CURING ON")
	  else
		 send("CURING OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'curing', (ON or OFF)",
    true
  )
  
  cecho(" "..(settings.curing and "<white>Curing (+)" or "<DarkSlateGray>Curing (-)"))
  echo"\n"
  
   

    --Toggle Advanced Curing
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.advancedcuring = not settings.advancedcuring

	  if settings.advancedcuring then	
		  send("CONFIG ADVANCEDCURING ON")
	  else
		 send("CONFIG ADVANCEDCURING OFF")
	  end
	  
		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	

	end,
    "click to toggle 'advanced curing', (ON or OFF)",
    true
  )
  
  cecho(" "..(settings.advancedcuring and "<white>Advanced Curing (+)" or "<DarkSlateGray>Advanced Curing (-)"))
  echo"\n"
  

  -- configure cure method (alchemical or herbal)
  cechoLink(
    " <white>(click) ",
    function()
      --clearCmdLine()
      --appendCmdLine("show prompt percentages ")
	  
	  if settings.cureMethod == "alchemical" then	
		settings.cureMethod = "herbal"
		send("CURING TRANSMUTATION OFF")
	  else	
		settings.cureMethod = "alchemical"
		send("CURING TRANSMUTATION ON")
	  end
	  
	  
	  	initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
 
	  
    end,
    "click to toggle 'show prompt percentages', (Alchemical or Concoctions)",
    true
  )
  
  --cecho("configure 'show prompt', enter (true or false))\n")
  cecho(" "..(cureMethod == "alchemical" and "<white>Cure Type: <cyan>Alchemical <white> (+)" or "<white>Cure Type: <green>Concoctions <white> (-)"))
  echo("\n")  



    --Toggle Reporting
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.reporting = not settings.reporting

	  if settings.reporting then	
		  send("CURING REPORTING ON")
	  else
		 send("CURING REPORTING OFF")
	  end
 
 		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'curing reporting', (ON or OFF)",
    true
  )
  
  cecho(" "..(settings.reporting and "<white>Curing Reporting (+)" or "<DarkSlateGray>Curing Reporting (-)"))
  echo"\n"


    --Toggle Defences
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.defences = not settings.defences
	
	  if settings.defences then	
		  send("CURING DEFENCES ON")
	  else
		 send("CURING DEFENCES OFF")
	  end
	  
		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'defence handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.defences and "<white>Defenses (+)" or "<DarkSlateGray>Defenses (-)"))
  echo"\n"


    --Toggle Sipping
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.sipping = not settings.sipping

	  if settings.sipping then	
		  send("CURING SIPPING ON")
	  else
		 send("CURING SIPPING OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'sip handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.sipping and "<white>Sipping (+)" or "<DarkSlateGray>Sipping (-)"))
  echo"\n"
  
  
      --Toggle Affliciton Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.afflictions = not settings.afflictions

	  if settings.afflictions then	
		  send("CURING AFFLICTIONS ON")
	  else
		 send("CURING AFFLICTIONS OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
		
	end,
    "click to toggle 'affliction handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.afflictions and "<white>Afflictions (+)" or "<DarkSlateGray>Afflictions (-)"))
  echo"\n"

      --Toggle Insomnia Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.insomnia = not settings.insomnia

	  if settings.insomnia then	
		  send("CURING INSOMNIA ON")
	  else
		 send("CURING INSOMNIA OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
  	
	end,
    "click to toggle 'insomnia handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.insomnia and "<white>Insomnia (+)" or "<DarkSlateGray>Insomnia (-)"))
  echo"\n"


      --Toggle Clot Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.clot = not settings.clot
	
	  if settings.clot then	
		  send("CURING USECLOT ON")
	  else
		 send("CURING USECLOT OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'clot handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.clot and "<white>Clot (+)" or "<DarkSlateGray>Clot (-)"))
  echo"\n"


      --Toggle Tree Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.tree = not settings.tree
	
	  if settings.tree then	
		  send("CURING TREE ON")
	  else
		 send("CURING TREE OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'tree handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.tree and "<white>Tree (+)" or "<DarkSlateGray>Tree (-)"))
  echo"\n"


    --Toggle Focus Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.focus = not settings.focus
	
	  if settings.focus then	
		  send("CURING FOCUS ON")
	  else
		 send("CURING FOCUS OFF")
	  end

		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'focus handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.focus and "<white>Focus (+)" or "<DarkSlateGray>Focus (-)"))
  echo"\n"

  
     	-- Configure Mount
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set mount <#>")
	  end,
	  "click to set your mount",
	  true
	)

	-- Initialize timeout to false
	local mount = false

	-- Check if settings.pagelength is a number
	if settings.mount ~= "" then
	  mount = true
	else
	  mount = false
	end

	cecho(" "..(mount and "<white>Mount: <green>"..settings.mount.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  



      --Toggle Vault Handling
  cechoLink(
    " <white>(click) ",
    function()
    
	  settings.usevault = not settings.usevault

	  if settings.usevault then	
		  send("CURING USEVAULT ON") 
	  else
		 send("CURING USEVAULT OFF") 
	  end
  
		initializeFlags()
	
	  	local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
		local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
		local filename = "configuration.lua"
		ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
	
	end,
    "click to toggle 'vault handling', (ON or OFF)",
    true
  )
  cecho(" "..(settings.usevault and "<white>Vault (+)" or "<DarkSlateGray>Vault (-)"))
  echo"\n"



 	-- Configure Curing Set
	cechoLink(
	  " <white>(click) ",
	  function()
	  	  
	    clearCmdLine()
		appendCmdLine("set curingset default")	  
	  
		-- Initialize timeout to false
		local curingset = false
		
		if settings.curingset == "" then
		  curingset = false
		else
		  curingset = true
		end 		
				
	  end,
	  "click to set default curingset",
	  true
	)

	cecho(" "..(curingset and "<white>Curing Set: <green>"..settings.curingset.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  


     	-- Curing Sip Health
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set siphealth 95")
	  end,
	  "click to set your health sip",
	  true
	)

	-- Initialize timeout to false
	local siphealth = false

	-- Check if settings.pagelength is a number
	if settings.siphealth ~= "" then
	  siphealth = true
	else
	  siphealth = false
	end

	cecho(" "..(siphealth and "<white>Health Sip: <green>"..settings.siphealth.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  



     	-- Curing Sip Mana
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set sipmana 95")
	  end,
	  "click to set your mana sip",
	  true
	)

	-- Initialize timeout to false
	local sipmana = false

	-- Check if settings.pagelength is a number
	if settings.sipmana ~= "" then
	  sipmana = true
	else
	  sipmana = false
	end

	cecho(" "..(sipmana and "<white>Mana Sip: <green>"..settings.sipmana.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  

     	-- Curing Health Affs Above
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set healthaffs 95")
	  end,
	  "click to set your health affs threshold",
	  true
	)

	-- Initialize timeout to false
	local healthaffsabove = false

	-- Check if settings.pagelength is a number
	if settings.healthaffsabove ~= "" then
	  healthaffsabove = true
	else
	  healthaffsabove = false
	end
	  
	cecho(" "..(healthaffsabove and "<white>Apply Health Above: <green>"..settings.healthaffsabove.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n") 




     	-- Curing Mana Threshold
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set manathreshold 70")
	  end,
	  "click to set your health affs threshold",
	  true
	)

	-- Initialize timeout to false
	local manathreshold = false

	-- Check if settings.pagelength is a number
	if settings.manathreshold ~= "" then
	  manathreshold = true
	else
	  manathreshold = false
	end

	cecho(" "..(manathreshold and "<white>Mana Threshold: <green>"..settings.manathreshold.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  




     	-- Curing Moss Health
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set mosshealth 75")
	  end,
	  "click to set your moss health threshold",
	  true
	)

	-- Initialize timeout to false
	local mosshealth = false

	-- Check if settings.pagelength is a number
	if settings.mosshealth ~= "" then
	  mosshealth = true
	else
	  mosshealth = false
	end

	cecho(" "..(mosshealth and "<white>Moss Health Threshold: <green>"..settings.mosshealth.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  



     	-- Curing Moss Mana
	cechoLink(
	  " <white>(click) ",
	  function()
		clearCmdLine()
		appendCmdLine("set mossmana 75")
	  end,
	  "click to set your moss mana threshold",
	  true
	)

	-- Initialize timeout to false
	local mossmana = false

	-- Check if settings.pagelength is a number
	if settings.mossmana ~= "" then
	  mossmana = true
	else
	  mossmana = false
	end

	cecho(" "..(mossmana and "<white>Moss Mana Threshold: <green>"..settings.mossmana.." <white>(+)" or "<red>Not Set (-)"))
	echo("\n")  


	-- Toggle Curing Priority
	cechoLink(
	  " <white>(click) ",
	  function()

		-- Check current setting and send the appropriate command
		if settings.sippriority == "CURING PRIORITY MANA" then
		  send("CURING PRIORITY HEALTH")  -- Switch to Health priority
		  settings.sippriority = "CURING PRIORITY HEALTH"  -- Update the setting
		else
		  send("CURING PRIORITY MANA")  -- Switch to Mana priority
		  settings.sippriority = "CURING PRIORITY MANA"  -- Update the setting
		end

		initializeFlags()
		
			local userHome = os.getenv("USERPROFILE") or "C:/Users/Default"
			local baseDir = userHome .. "/Documents/" .. gmcp.Char.Status.name:title() .. " System/Tables"
			local filename = "configuration.lua"
			ensureFileExists(baseDir, filename, "save", settings)
		
		configureSystem()	
  
	  end,
	  "click to toggle 'sip priority', (HEALTH or MANA)",
	  true
	)

	-- Display the current sip priority
	local prioText = (settings.sippriority == "CURING PRIORITY MANA" and "<cyan>MANA" or "<green>HEALTH")
	cecho(" <white>Sipping Priority: " .. prioText .. "\n")



end


    
function reloadSystem()

    -- Reload the updated script (if srvQueue is defined in it)
    dofile(getMudletHomeDir() .. "/Achaean System/system/system.lua")  -- Adjust the path as needed
  
    echo("\nSystem File Loaded")
end