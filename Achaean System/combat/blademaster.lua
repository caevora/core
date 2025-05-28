-- Shin cost dictionary for Striking abilities
abilityCosts =
  {
    airfist = 20,
    icefist = 20,
    flamefist = 20,
    voidfist = 20,
    infusefire = 5,
    infuseice = 5,
    infuselightning = 5,
    infusevoid = 5,
    vitiate = 40,
    blizzard = 30,
    thunderstorm = 30,
    annihilation = 40,
    perfection = 40,
    phoenix = 80,
  }
-- Action to required conditions and blockers mapping
actionQueueMap =
  {
    ["impaleslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["bladetwist"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["raze"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["immunity"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["voidfist"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["airfist"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["brokenstar"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["pommelstrike"] = {conditions = {"b"}, blockers = "prone, paralysed, bound, stunned"},
    ["compass"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["drawslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["armslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["legslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["balanceslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["centreslash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["mir"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["thyr"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["sanya"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["arash"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["alleviate"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["impale"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["manatrans"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["healthtrans"] = {conditions = {"e", "b"}, blockers = "prone, paralysed, bound, stunned"},
    ["phoenix"] = {conditions = {"c", "b", "p"}, blockers = "prone, paralysed, bound, stunned"},
    ["tumble"] = {conditions = {"b"}, blockers = "stunned"},
  }
-- Function to check if the current state matches the conditions and blockers

function getQueueConditions(action)
  local actionData = actionQueueMap[action]
  if not actionData then
    cecho(
      "<red>Action " ..
      action ..
      " is missing from the actionQueueMap, cannot perform action.<reset>\n"
    )
    return ""
    -- Return empty string if the action is missing
  end

  local balanceToKey =
    {
      ["prone"] = "u",
      ["balance"] = "b",
      ["equilibrium"] = "e",
      ["class"] = "c",
      ["paralysed"] = "!p",
      ["bound"] = "!w",
      ["stunned"] = "!t",
    }
  local checks = ""
  -- Concatenate conditions and blockers to the checks string
  for _, condition in ipairs(actionData.conditions or {}) do
    local conditionCheck = balanceToKey[condition] or condition
    checks = checks .. conditionCheck
  end
  for _, blocker in ipairs(actionData.blockers and actionData.blockers:split(", ") or {}) do
    local blockerCheck = balanceToKey[blocker] or blocker
    checks = checks .. blockerCheck
  end
  return checks
end

-- Function to check if you can attack based on afflictions

function attackcheck()
  -- Check if you have any hinder afflictions
  if
    hasHinderedAffliction(
      {
        "webbed",
        "roped",
        "disrupted",
        "stun",
        "pacified",
        "peace",
        "lovers",
        "stupidity",
        "transfixation",
        "impaled",
        "entangled",
        "bound",
      }
    )
  then
    return true
  end
  -- Check for limb-related afflictions
  if
    hasLimbAffliction(
      {
        "mangledleftleg",
        "damagedleftleg",
        "brokenleftleg",
        "mangledrightleg",
        "damagedrightleg",
        "brokenrightleg",
        "mangledleftarm",
        "damagedleftarm",
        "brokenleftarm",
        "mangledrightarm",
        "damagedrightarm",
        "brokenrightarm",
      }
    )
  then
    return true
  end
  return false
end

-- Function to check if any hinder afflictions are present

function hasHinderedAffliction(afflictions)
  for _, affliction in ipairs(afflictions) do
    if myaffs[affliction] then
      return true
    end
  end
  return false
end

-- Function to check for any limb-related afflictions

function hasLimbAffliction(afflictions)
  for _, affliction in ipairs(afflictions) do
    if myaffs[affliction] then
      return true
    end
  end
  return false
end

-- Helper function to compare two tables (used to check if sequences are the same)

function table.equal(t1, t2)
  if #t1 ~= #t2 then
    return false
  end
  for i = 1, #t1 do
    if t1[i] ~= t2[i] then
      return false
    end
  end
  return true
end

function resetLimbValues()
  -- Conv values for different stances (used for determining damage per hit)
  local conv = {thyr = 18.0, sanya = 21.9, mir = 20.0, arash = 23.9, doya = 22.9}
  -- Initialize limbdamage table for the target if it does not exist
  -- Loop through each limb and calculate the required hits to prep the limb
  for limbName, data in pairs(limbdamage[target:title()]) do
    -- Calculate the remaining hits for the current limb
    local remainingStrikes = calculateRemainingStrikes(data.health, conv[stance])
    -- Adjust stance for the correct damage value
    -- Update the remaining hits for the limb
    limbdamage[target:title()][limbName].hits = remainingStrikes
    limbdamage[target:title()][limbName].health = data.health
    -- Output the result for the current limb
    if DEBUG_MODE then
      cecho(
        "\n<green>" ..
        limbName:title() ..
        " <white>Hits Remaining: " ..
        remainingStrikes ..
        " Health: " ..
        data.health
      )
    end
  end
  --end
end

-- Function to handle the assessment phase (before combat)

function handleAssess(line)
  -- Now let's parse the target health information
  if
    string.match(
      line, "^You glance over (%w+) and see that .+ health is at (%d+)\/(%d+) %[(%d+)%%%]%.$"
    )
  then
    local tar, currentHealth, maxHealth, healthPercentage =
      string.match(
        line, "^You glance over (%w+) and see that .+ health is at (%d+)\/(%d+) %[(%d+)%%%]%.$"
      )
    resetLimbValues()
    -- If a match is found, process the extracted values
    if tar then
      -- Process the target's health data
      tarCurHealth = tonumber(currentHealth)
      -- Current health
      tarMaxHealth = tonumber(maxHealth)
      -- Max health
      tarPerHealth = tonumber(healthPercentage)
      -- Health percentage
      -- Optionally, you can print or process the variables further
      if DEBUG_MODE then
        cecho(
          "\n<green>Target: " ..
          tar ..
          "\nCurrent Health: " ..
          tarCurHealth ..
          "/" ..
          tarMaxHealth ..
          " (" ..
          tarPerHealth ..
          "%)\n"
        )
      end
    end
  end
end

-- Function to handle tumbling logic separately

function handleTumbling(line)
  -- Check for Tumble start and finish triggers
  if string.match(line, "^You begin to tumble agilely to the (.*).$") then
    -- Tumble started, set cooldown
    tumblecd = os.clock() + 8
    tumblerequested = false
    -- Reset tumble requested flag
    fleerequested = false
    tumbling = true
    afflictions.paralysis.priority = 26
    sendCuringPriority("paralysis", afflictions.paralysis.priority)
  elseif
    string.match(line, "^You cease your tumbling.$") or
    string.match(line, "^You tumble out of the room.$")
  then
    -- Tumble finished, reset the tumble flag
    tumblerequested = false
    fleerequested = false
    tumbling = false
    afflictions.paralysis.priority = 7
    sendCuringPriority("paralysis", afflictions["paralysis"].priority)
  end
end

-- Curing function for better separation of concerns

function sendCuringPriority(affliction, priority)
  if curinglist[affliction] ~= priority then
    send("curing priority " .. affliction .. " " .. priority)
  end
end

function intime()
  -- Retrieve balance and timer values
  local targetClass = NDB_getClass(target:title()):lower()
  local enemyBal = getRemainingEnemyTimerTime(targetClass)
  -- Enemy balance time remaining
  local myBal = getRemainingPersonalTimerTime("balance")
  -- Your personal balance time remaining
  local herbTimer = getRemainingEnemyTimerTime("herb")
  -- Enemy herb timer remaining
  -- Check if conditions are met
  local x = false

  if herbTimer > myBal + 1.2 and herbTimer > 0 then
    x = true
  end
  
  -- Return the result of the check
  return x
end

-- Utility function to split a string by a delimiter (used for blockers)

function string.split(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
    table.insert(t, str)
  end
  return t
end

-- Function to randomly select a tumble direction

function findDirection()
  local exits = table.keys(gmcp.Room.Info.exits)
  return exits[math.random(#exits)]
end

-- Function to get Shin energy

function myshin()
  if gmcp.Char.Vitals.charstats[3] then
    returnstring =
      tonumber(string.sub(gmcp.Char.Vitals.charstats[3], 7, #gmcp.Char.Vitals.charstats[3])) or ""
  else
    returnstring = "0"
  end
  return returnstring
end

function handleStriking(line)
  lastaffgiven = ""
  if
    string.match(
      line, "^Ducking behind %w+, you strike at (%w+)'s hamstring with a rigid, practised grip%.$"
    )
  then
    local tar =
      string.match(
        line, "^Ducking behind %w+, you strike at (%w+)'s hamstring with a rigid, practised grip%.$"
      )
    echo(tar)
    if tar == target:title() then
      if hamstringtimer then
        killTimer(hamstringtimer);
        hamstringtimer = nil
      end
      hamstrung = true
      hamstringtimer = tempTimer(7, [[hamstrung = false]])
    end
  end
  --voidfist
  if
    string.match(
      line,
      "^Emptying your mind of conscious thought, you welcome the void as you strike (%w+) a hollow blow%.$"
    )
  then
    local tar =
      string.match(
        line,
        "^Emptying your mind of conscious thought, you welcome the void as you strike (%w+) a hollow blow%.$"
      )
    if tar == target:title() then
      if voidfisttimer then
        killTimer(voidfisttimer);
        voidfisttimer = nil
      end
      voidfisted = true
      voidfisttimer = tempTimer(voidtimes[stance], [[voidfisted = false]])
    end
  end
  --airfist
  if
    string.match(
      line,
      "^Freeing your mind to the unpredictable dance of the wind, you hurl a blow towards (%w+)%.$"
    )
  then
    local tar =
      string.match(
        line,
        "^Freeing your mind to the unpredictable dance of the wind, you hurl a blow towards (%w+)%.$"
      )
    if tar == target:title() then
      if airfisttimer then
        killTimer(airfisttimer);
        airfisttimer = nil
      end
      airfisted = true
      airfisttimer = tempTimer(airtimes[stance], [[airfisted = false]])
    end
  end
  --pommelstrike
  if
    string.match(
      line, "^As you draw %w+ %w+ from its scabbard, you drive the pommel into (%w+)'s chin.$"
    )
  then
    local tar =
      string.match(
        line, "^As you draw %w+ %w+ from its scabbard, you drive the pommel into (%w+)'s chin.$"
      )
    if tar == target:title() then
      mybal = os.clock() + 1
    end
  end
  -- Additional affliction strikes
  if string.match(line, "^With a fluid motion, you aim a blow just below (%w+)'s shoulder.$") then
    local tar =
      string.match(line, "^With a fluid motion, you aim a blow just below (%w+)'s shoulder.$")
    if tar == target:title() then
      addAfflictionsToTable({"weariness", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if string.match(line, "^Lashing out with open palms, you box (%w+)'s ears.$") then
    local tar = string.match(line, "^Lashing out with open palms, you box (%w+)'s ears.$")
    if tar == target:title() then
      addAfflictionsToTable({"clumsiness", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(line, "^With the heel of your palm, you send a pulverising blow at (%w+)'s nose.$")
  then
    local tar =
      string.match(
        line, "^With the heel of your palm, you send a pulverising blow at (%w+)'s nose.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"disloyalty", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(line, "^Sweeping out with a blade hand, you strike at the back of (%w+)'s knee.$")
  then
    local tar =
      string.match(
        line, "^Sweeping out with a blade hand, you strike at the back of (%w+)'s knee.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"prone", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^With fluid motions of your iron fingers, you strike precisely at pressure points on (%w+)'s neck.$"
    )
  then
    local tar =
      string.match(
        line,
        "^With fluid motions of your iron fingers, you strike precisely at pressure points on (%w+)'s neck.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"paralysis", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^Dancing behind %w+ with a neat sidestep, you strike at (%w+)'s kidney with a balled fist.$"
    )
  then
    local tar =
      string.match(
        line,
        "^Dancing behind %w+ with a neat sidestep, you strike at (%w+)'s kidney with a balled fist.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"addiction", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^With pinpoint strikes to (%w+)'s sockets, you burst blood vessels in %w+ eyes, causing them to run red.$"
    )
  then
    local tar =
      string.match(
        line,
        "^With pinpoint strikes to (%w+)'s sockets, you burst blood vessels in %w+ eyes, causing them to run red.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"hallucinations", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if string.match(line, "^Striking %w+ temple with a clenched fist, you leave (%w+) reeling.$") then
    local tar =
      string.match(line, "^Striking %w+ temple with a clenched fist, you leave (%w+) reeling.$")
    if tar == target:title() then
      addAfflictionsToTable({"stupidity", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line, "^Stepping in close, you strike upwards at a precise point below (%w+)'s chin.$"
    )
  then
    local tar =
      string.match(
        line, "^Stepping in close, you strike upwards at a precise point below (%w+)'s chin.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"sleep", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^Targeting a vulnerable point, you lash out at (%w+)'s groin with a calculated strike.$"
    )
  then
    local tar =
      string.match(
        line,
        "^Targeting a vulnerable point, you lash out at (%w+)'s groin with a calculated strike.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"recklessness", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^With rapid precision, you aim first a punch then a spearhand blow at two points on (%w+)'s chest.$"
    )
  then
    local tar =
      string.match(
        line,
        "^With rapid precision, you aim first a punch then a spearhand blow at two points on (%w+)'s chest.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"hypochondria", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line, "^With iron fingers, you aim a darting strike at a weak point on (%w+)'s throat.$"
    )
  then
    local tar =
      string.match(
        line, "^With iron fingers, you aim a darting strike at a weak point on (%w+)'s throat.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"asthma", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line,
      "^You aim a measured blow at (%w+)'s stomach, feeling muscles clench beneath your fist.$"
    )
  then
    local tar =
      string.match(
        line,
        "^You aim a measured blow at (%w+)'s stomach, feeling muscles clench beneath your fist.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"anorexia", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
  if
    string.match(
      line, "^With a swift, snaking strike, you thrust upwards at (%w+)'s unprotected armpit.$"
    )
  then
    local tar =
      string.match(
        line, "^With a swift, snaking strike, you thrust upwards at (%w+)'s unprotected armpit.$"
      )
    if tar == target:title() then
      addAfflictionsToTable({"slickness", 1}, probabilityTable)
	  highlightstrikeline()
    end
  end
end

function highlightstrikeline()
    highlightline(selectString(line, 1) > -1, "black", "orange", false, true)
    moveCursor(0, getLineNumber())
    cinsertText("\n<white>[<orange>" .. lastaffgiven:upper() .. "<white>]: ")
    moveCursorEnd()
end

function handleStances()
  if string.match(line, "^You adopt a neutral stance.$") then
    stance = "none"
    resetLimbValues()
  end
  if string.match(line, "^Readying yourself with a flourish, you flow into the Thyr stance.$") then
    stance = "thyr"
    resetLimbValues()
  end
  if string.match(line, "^Resolving to move as water, you enter the Mir stance.$") then
    stance = "mir"
    resetLimbValues()
  end
  if string.match(line, "^Clearing your mind, you sink into the Sanya stance.$") then
    stance = "sanya"
    resetLimbValues()
  end
  if string.match(line, "^Mind set on the dancing flame, you take up the Arash stance.$") then
    stance = "arash"
    resetLimbValues()
  end
  if string.match(line, "^Lowering your centre of gravity, you drop into the Doya stance.$") then
    stance = "doya"
    resetLimbValues()
  end
end

-- Function to handle limb attack logic

function handleSwordAttack(line)
  -- Initialize side, target, and limb variables
  local side = ""
  local tar = ""
  local limb = ""
  if
    string.match(
      line,
      "^With a look of agony on %w+ face, (%w+) manages to writhe %w+ free of the weapon which impaled %w+.$"
    )
  then
    tar =
      string.match(
        line,
        "^With a look of agony on %w+ face, (%w+) manages to writhe %w+ free of the weapon which impaled %w+.$"
      )
    if tar == target:title() then
      impaled = false
    end
  end
  if
    string.match(
      line, "^With a deft twist of your blade, you send blood gushing from (%w+)'s gut.$"
    )
  then
    tar =
      string.match(
        line, "^With a deft twist of your blade, you send blood gushing from (%w+)'s gut.$"
      )
    if tar == target:title() then
      --bladetwist = bladetwist + 1				
    end
  end
  if
    string.match(
      line,
      "^You draw your blade back and plunge it deep into the body of (%w+) impaling %w+ to the hilt.$"
    )
  then
    tar =
      string.match(
        line,
        "^You draw your blade back and plunge it deep into the body of (%w+) impaling %w+ to the hilt.$"
      )
    if tar == target:title() then
      impaled = true
    end
  end
  -- compass head
  if string.match(line, "^You raze (%w+)'s aura of rebounding with %w+ %w+%.$") then
    tar = string.match(line, "^You raze (%w+)'s aura of rebounding with %w+ %w+%.$")
    if tar == target:title() then
      rebounding = false
    end
  end
  -- compass head
  if
    string.match(
      line,
      "^Whispering a prayer to northern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s head%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to northern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s head%.$"
      )
    if tar == target:title() then
      lasthit = "head"
    end
  end
  -- compass torso
  if
    string.match(
      line,
      "^Whispering a prayer to southern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s torso%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to southern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s torso%.$"
      )
    if tar == target:title() then
      lasthit = "torso"
    end
  end
  -- compass left arm
  if
    string.match(
      line,
      "^Whispering a prayer to eastern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s left arm%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to eastern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s left arm%.$"
      )
    if tar == target:title() then
      lasthit = "left arm"
    end
  end
  -- compass right arm
  if
    string.match(
      line,
      "^Whispering a prayer to western winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s right arm%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to western winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s right arm%.$"
      )
    if tar == target:title() then
      lasthit = "right arm"
    end
  end
  -- compass left leg
  if
    string.match(
      line,
      "^Whispering a prayer to southeastern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s left leg%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to southeastern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s left leg%.$"
      )
    if tar == target:title() then
      lasthit = "left leg"
    end
  end
  -- compass right leg
  if
    string.match(
      line,
      "^Whispering a prayer to southwestern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s right leg%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Whispering a prayer to southwestern winds, you draw %w+ %w+ and unleash a slash towards (%w+)'s right leg%.$"
      )
    if tar == target:title() then
      lasthit = "right leg"
    end
  end
  -- armslash
  if
    string.match(
      line,
      "^Spinning to the (%w+) as you draw .* from its sheath, you unleash a precise slash across (%w+)'s arms%.$"
    )
  then
    side, tar, limb =
      string.match(
        line,
        "^Spinning to the (%w+) as you draw %w+ %w+ from its sheath, you unleash a precise slash across (%w+)'s arms%.$"
      )
    if tar == target:title() then
      lasthit = ""
    end
  end
  -- legslash
  if
    string.match(
      line,
      "^With a smooth lunge to the (%w+), you draw .* from its scabbard and deliver a powerful slash across (%w+)'s legs%.$"
    )
  then
    side, tar, limb =
      string.match(
        line,
        "^Spinning to the (%w+) as you draw %w+ %w+ from its sheath, you unleash a precise slash across (%w+)'s legs%.$"
      )
    if tar == target:title() then
      lasthit = ""
    end
  end
  -- centreslash down
  if
    string.match(
      line,
      "^In a single motion, you draw %w+ %w+ from its scabbard and loose a vicious falling slash at (%w+)'s (%w+)%.$"
    )
  then
    tar, limb =
      string.match(
        line,
        "^In a single motion, you draw %w+ %w+ from its scabbard and loose a vicious falling slash at (%w+)'s (%w+)%.$"
      )
    if tar == target:title() then
      lasthit = limb
    end
  end
  -- centreslash up
  if
    string.match(
      line,
      "^In a single motion, you draw %w+ %w+ from its scabbard and loose a vicious rising slash at (%w+)'s (%w+)%.$"
    )
  then
    tar, limb =
      string.match(
        line,
        "^In a single motion, you draw %w+ %w+ from its scabbard and loose a vicious falling slash at (%w+)'s (%w+)%.$"
      )
    if tar == target:title() then
      lasthit = limb
    end
  end
  --balanceslash
  if
    string.match(
      line,
      "^Taking a half step forward, you draw %w+ %w+ and unleash a forceful slash that drives (%w+) back%.$"
    )
  then
    tar =
      string.match(
        line,
        "^Taking a half step forward, you draw %w+ %w+ and unleash a forceful slash that drives (%w+) back%.$"
      )
    if tar == target:title() then
      slashtype = ""
    end
  end
end

function resetLimbs(line)
  -- Reset both legs to 1 if the target takes some substance for their legs
  if string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ legs%.$") then
    local tar = string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ legs%.$")
    -- Extract target name
    if target:title() == tar then
      limbdamage[target:title()]["left leg"].health = 100
      limbdamage[target:title()]["right leg"].health = 100
      limbdamage[target:title()]["left leg"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
      limbdamage[target:title()]["right leg"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
  -- Reset one leg to 1 if the target ceases to favour a specific leg
  if string.match(line, "^(%w+) ceases to favour %w+ (%w+) leg%.$") then
    local tar, limb = string.match(line, "^(%w+) ceases to favour %w+ (%w+) leg%.$")
    if tar == target:title() then
      limbdamage[target:title()][limb .. " leg"].health = 100
      limbdamage[target:title()][limb .. " leg"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
  -- Reset both arms to 1 if the target takes some substance for their arms
  if string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ arms%.$") then
    local tar = string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ arms%.$")
    -- Extract target name
    if target:title() == tar then
      limbdamage[target:title()]["left arm"].health = 100
      limbdamage[target:title()]["right arm"].health = 100
      limbdamage[target:title()]["left arm"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
      limbdamage[target:title()]["right arm"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
  -- Reset one arm to 1 if the target ceases to favour a specific arm
  if string.match(line, "^(%w+) ceases to favour %w+ (%w+) arm%.$") then
    local tar, limb = string.match(line, "^(%w+) ceases to favour %w+ (%w+) arm%.$")
    if target:title() == tar then
      limbdamage[target:title()][limb .. " arm"].health = 100
      limbdamage[target:title()][limb .. " arm"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
  -- Reset torso to 1 if the target takes some substance for their torso
  if string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ body%.$") then
    local tar = string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ body%.$")
    -- Extract target name
    if target:title() == tar then
      limbdamage[target:title()]["torso"].health = 100
      limbdamage[target:title()]["torso"].hits =
        calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
  -- Reset head to 1 if the target takes some substance for their head
  if string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ head%.$") then
    local tar = string.match(line, "^(%w+) takes some %w+ from a vial and rubs it on %w+ head%.$")
    -- Extract target name
    if target:title() == tar then
      limbdamage[target:title()]["head"].health = 100
      limbdamage[target:title()]["head"].hits = calculateRemainingStrikes(100, compass_conv[stance])
    end
  end
end

-- This function checks if an attack has been avoided based on the input line.

function enemyAvoidedAttack(line)
  -- Define common avoidance patterns for easier management
  -- target jumps back to avoid
  -- target dodges the attack
  -- target twists to avoid
  -- you missed the attack
  -- attack rebounds
  -- target parries
  -- target's reflection avoids
  local avoidancePatterns =
    {
      "^(%w+) quickly jumps back, avoiding the attack.$",
      "^(%w+) dodges nimbly out of the way.$",
      "^(%w+) twists %w+ body out of harm's way.$",
      "You miss.",
      "The attack rebounds back onto you!",
      "^(%w+) parries the attack with a deft manoeuvre.$",
      "^A reflection of (%w+) blinks out of existence.$",
      "^(%w+) moves into your attack, knocking your blow aside before viciously countering with a strike to your head.$",
      "^(%w+) steps into the attack, grabs your arm, and throws you violently to the ground.$",
      "^A chaos orb intercepts the attack against %w+ and renders it harmless.$",
    }
  -- Check if the line matches any of the avoidance patterns
  for _, pattern in ipairs(avoidancePatterns) do
    if string.match(line, pattern) then
      if
        lasthit == "head" or
        lasthit == "torso" or
        lasthit == "left arm" or
        lasthit == "left leg" or
        lasthit == "right arm" or
        lasthit == "right leg"
      then
        if limbdamage[target:title()][lasthit].health < 100 then
          recalculateLimbs()
        end
      end
      -- Special logic for specific patterns
      if pattern == "^(%w+) parries the attack with a deft manoeuvre.$" then
        airfistrequested = true
      end
      if pattern == "The attack rebounds back onto you!" then
        rebounding = true
      end
    end
  end
end

-- Function to remove an attack from the sequence and retry the previous index

function recalculateLimbs()
  if slashtype == "compass" and lasthit ~= "" then
    limbdamage[target:title()][lasthit].health =
      limbdamage[target:title()][lasthit].health + compass_conv[stance]
    limbdamage[target:title()][lasthit].hits = limbdamage[target:title()][lasthit].hits + 1
  elseif slashtype == "armslash" or slashtype == "legslash" or slashtype == "centreslash" then
    limbdamage[target:title()][lasthit].health =
      limbdamage[target:title()][lasthit].health + limbslash_conv[stance]
    limbdamage[target:title()][lasthit].hits = limbdamage[target:title()][lasthit].hits + 1
  end
end

-- Function to reset all combat-related variables to their default values

function resetCombatState()
  -- skillStatuses to default values (empty tables)
  skillStatuses = {}
  appliedAfflictionsStack = {}
  
  -- This is for centreslash, armslash, and legslash values
  limbslash_conv =
    {
      thyr = {primary = 14.9, secondary = 10.0},
      sanya = {primary = 18.1, secondary = 12.1},
      mir = {primary = 16.5, secondary = 11.0},
      arash = {primary = 19.8, secondary = 13.2},
      doya = {primary = 18.9, secondary = 12.6},
    }
	
  -- This is for compassslash values
  compass_conv = {
	  thyr = 18.0, 
	  sanya = 21.9, 
	  mir = 20.0, 
	  arash = 23.9, 
	  doya = 22.9
	  }
	  
  airtimes =
    {
      ["none"] = 14.5,
      ["thyr"] = 20.0,
      ["sanya"] = 14.5,
      ["mir"] = 14.5,
      ["doya"] = 14.5,
      ["arash"] = 14.5,
    }
  voidtimes =
    {
      ["none"] = 4.5,
      ["thyr"] = 4.5,
      ["sanya"] = 7.5,
      ["mir"] = 4.5,
      ["doya"] = 4.5,
      ["arash"] = 4.5,
    }
	
  mybal = 0
  hisherbbal = 0
  fleerequested = false
  tumblerequested = false
  tumbling = false
  healrequested = false
  manarequested = false
  phoenixrequested = false
  alleviaterequested = false
  musttumble = false
  hamstrung = false
  hamstringTimer = 0
  action = action or ""
  tumblecd = 0
  myfleedir = ""
  flying = false
  targetflying = false
  airfistrequested = false
  voidfistrequested = false
  airfisted = false
  voidfisted = false
  can_bstar = false
  rebounding = false
  shielded = false
  requestchase = false
  chasedata = {}
  tarCurHealth = 0
  tarMaxHealth = 0
  tarPerHealth = 0
  target = target or "none"
  stance = stance or ""
  side = ""
  limb = ""
  recordingSequence = false
  keepingHamstring = false
  hamstringActive = 0
  normalizedInfusion = "none"
  slashtype = slashtype or "none"
  striketype = striketype or "none"
  lasthit = ""
  lasteaten = ""
  impaled = false
  shin = myshin() or 0  
  
  limbdamage[target:title()] =
    {
      ["head"] = {health = 100, hits = 0},
      ["torso"] = {health = 100, hits = 0},
      ["left leg"] = {health = 100, hits = 0},
      ["right leg"] = {health = 100, hits = 0},
      ["left arm"] = {health = 100, hits = 0},
      ["right arm"] = {health = 100, hits = 0},
    }

  cecho("<green>\nCombat state has been reset to defaults!<reset>")
end

function setTarget(tar)
  if tar == "none" then
    hunting = false
    autohunting = false
    failsafe = false
  else
    if hunting then
      if target == "" or lasthunttarget ~= target then
        lasthunttarget = target
        if target ~= "" then
          send("settarget " .. target)
        else
          --send("settarget none")
        end
      end
    else
      target = tar
      precacheCheck()
      if stance == "" or stance == "none" then
        if myclass() == "blademaster" then
          send("queue addclear eqbal thyr")
        end
      end
      send("settarget " .. target)
      send("assess " .. target)
      send("curingset switch set1")
      cecho("\n<white>Target:<green> " .. target:title())
      if not limbdamage[target:title()] then
        limbdamage[target:title()] =
          {
            ["head"] = {health = 100, hits = 0},
            ["torso"] = {health = 100, hits = 0},
            ["left leg"] = {health = 100, hits = 0},
            ["right leg"] = {health = 100, hits = 0},
            ["left arm"] = {health = 100, hits = 0},
            ["right arm"] = {health = 100, hits = 0},
          }
      end
      if not (NDB_getClass(target:title()) == "Unknown") then
        set_class(NDB_getClass(target):title())
      else
        cecho("\n<yellow> SET CLASS MANUALLY")
      end
      systemPaused = false
      send("curing on")
      if not table.contains(NDB.cityList, target:title()) then
        send("enemy " .. target)
      end
      if idtwo then
        killTrigger(idtwo)
      end
      idtwo = tempTrigger(target, [[selectString("]] .. target .. [[", 1) fg("red") resetFormat()]])
      if id then
        killTrigger(id)
      end
      id = tempTrigger(target, [[selectString("]] .. target .. [[", 1) fg("red") resetFormat()]])
      expandAlias("pm stand")
      if parrymethod ~= "none" then
        checkForParry()
        send("queue add eqbal " .. parrystring)
      end
    end
  end
  updateWhoHere()
  resetCombatState()
end

function targetHere()
  if table.contains(gmcp.Room.Players, target:title()) then
    return true
  else
    return false
  end
end

function bmGUI()
  if combatLoaded then
    bmGUI_previousValues = bmGUI_previousValues or {}
    target = target or "none"
    normalizedInfusion = normalizedInfusion or "none"
    slashtype = slashtype or "none"
    stance = stance or "none"
    -- Ensure tarMaxHealth is not nil
    tarMaxHealth = tarMaxHealth or "none"
    -- Initialize the values for the limbs (fetching 'hits' and 'health' for each limb)
    local headHits = limbdamage[target:title()]["head"].hits or 10
    -- Default to 10 if no hits data
    local torsoHits = limbdamage[target:title()]["torso"].hits or 10
    local leftArmHits = limbdamage[target:title()]["left arm"].hits or 10
    local rightArmHits = limbdamage[target:title()]["right arm"].hits or 10
    local leftLegHits = limbdamage[target:title()]["left leg"].hits or 10
    local rightLegHits = limbdamage[target:title()]["right leg"].hits or 10
    local headValue = limbdamage[target:title()]["head"].health or 100
    local torsoValue = limbdamage[target:title()]["torso"].health or 100
    local leftArmValue = limbdamage[target:title()]["left arm"].health or 100
    local rightArmValue = limbdamage[target:title()]["right arm"].health or 100
    local leftLegValue = limbdamage[target:title()]["left leg"].health or 100
    local rightLegValue = limbdamage[target:title()]["right leg"].health or 100
    -- Normalize infusion value
    local normalizedInfusion = infusionrequested or "none"
    -- Gather the current values to display
    local currentValues =
      {
        target = target,
        shin =
          tonumber(myshin()) and
          tonumber(myshin()) > 0 and
          " <white>SHIN:             <green>" ..
          myshin() ..
          "" or
          " <white>SHIN:             <red>" ..
          (myshin() or 0) ..
          "",
        infusion = normalizedInfusion,
        slashtype = slashtype,
        stance = stance,
        head = "<white>" .. headHits .. "\|" .. headValue,
        torso = "<white>" .. torsoHits .. "\|" .. torsoValue,
        leftarm = "<white>" .. leftArmHits .. "\|" .. leftArmValue,
        rightarm = "<white>" .. rightArmHits .. "\|" .. rightArmValue,
        leftleg = "<white>" .. leftLegHits .. "\|" .. leftLegValue,
        rightleg = "<white>" .. rightLegHits .. "\|" .. rightLegValue,
      }
    -- Check if any value has changed
    local valuesChanged = false
    for key, value in pairs(currentValues) do
      if bmGUI_previousValues[key] ~= value then
        valuesChanged = true
        break
      end
    end
    -- If values have changed, clear and update the target
    if valuesChanged then
      -- Clear the previous content in the target window
      GUI.target:clear()
      GUI.tdata:clear()
      GUI.head:clear()
      GUI.torso:clear()
      GUI.la:clear()
      GUI.ra:clear()
      GUI.ll:clear()
      GUI.rl:clear()
      -- Activate the target tab and echo the new values
      GUI.datawindow:activateTab("target")
      GUI.tdata:cecho("\n")
      -- Display the updated values for the limbs directly
      local outputString =
        "  " ..
        currentValues.shin ..
        "\n" ..
        "  <white> TARGET:           " ..
        currentValues.target:title() ..
        "\n" ..
        "  <white> STANCE:           " ..
        currentValues.stance:title() ..
        "\n" ..
        "  <white> INFUSION:         " ..
        currentValues.infusion:title() ..
        "\n" ..
        "  <white> SLASH TYPE:       " ..
        currentValues.slashtype:title() ..
        "\n"
      -- Now echo the combined string all at once
      GUI.tdata:cecho(outputString)
      GUI.head:cecho("" .. currentValues.head:title() .. "\n")
      GUI.torso:cecho("" .. currentValues.torso:title() .. "\n")
      GUI.la:cecho("" .. currentValues.leftarm:title() .. "\n")
      GUI.ra:cecho("" .. currentValues.rightarm:title() .. "\n")
      GUI.ll:cecho("" .. currentValues.leftleg:title() .. "\n")
      GUI.rl:cecho("" .. currentValues.rightleg:title() .. "\n")
      -- Update the previous values for comparison in the next cycle
      bmGUI_previousValues = currentValues
    end
  end
end

function handleActionBasedOnSlashtype(limb)
  local cs = cmdsep
  local command = ""
  -- Local command variable to store the full action command
  local conv =
    {
      ["left leg"] = "left",
      ["right leg"] = "right",
      ["left arm"] = "left",
      ["right arm"] = "right",
      ["head"] = "down",
      ["torso"] = "up",
    }
  local compass_conv =
    {
      ["head"] = "north",
      ["right leg"] = "southwest",
      ["left leg"] = "southeast",
      ["right arm"] = "west",
      ["left arm"] = "east",
      ["torso"] = "south",
    }
	
	

	-- React based on current strategies
	if not shielded and not rebounding then		
		-- Ensure hamstrung is maintained
		if not hamstrung then
			slashtype = "pommelstrike"
		else
				
					-- Checks to allow offensive actions
			if can_bstar then
				slashtype = "brokenstar"
				-- Use Brokenstar if available
			elseif impaled and not can_bstar then
				slashtype = "bladetwist"
				-- Use Bladetwist if impaled
			elseif probabilityTable["prone"] == 1 then
				slashtype = "impale"
				-- Use Impale if the target is prone
			--elseif hisbal < os.clock() - 3 then
				-- Prioritize balance timing
				--slashtype = "balanceslash"
			else
				-- Target limbs based on damage and limb type
				if limb == "left leg" or limb == "right leg" then
					if limbdamage[target:title()]["left leg"].hits == 1 and limbdamage[target:title()]["right leg"].hits == 1 then
						slashtype = "legslash"
					else
						slashtype = "compass"
					end
				elseif limb == "left arm" or limb == "right arm" then
					if limbdamage[target:title()]["left arm"].hits == 1 and limbdamage[target:title()]["right arm"].hits == 1 then
						slashtype = "armslash"
					else
						slashtype = "compass"
					end
				else
					-- Default to compass if no specific limb condition matches
					slashtype = "compass"
				end
			end
		
		

		end

	
	else
	
		slashtype = "raze"
		
	end

	  -- Define action handlers based on slashtype
	  local actionHandlers =
		{
		  brokenstar =
			function()
			  action = "brokenstar"
			  return 
				"stand" .. 
				cs .. 
				"brokenstar" .. 
				cs .. 
				"assess " .. 
				target
			end,
		  impaleslash =
			function()
			  action = "impaleslash"
			  return
				"stand" ..
				cs ..
				"impaleslash" ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  bladetwist =
			function()
			  action = "bladetwist"
			  return
				"stand" .. 
				cs .. 
				"bladetwist" .. 
				cs .. 
				"discern " .. 
				target .. 
				cs .. 
				"assess " .. 
				target
			end,
		  impale =
			function()
			 action = "impale"			 
			 return
				"stand" ..
				cs ..
				"sheathe sword" ..
				cs ..
				"impale " ..
				target ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  raze =
			function()
		     action = "raze"
			  return
				"stand" ..
				cs ..
				infusedecide() ..
				cs ..
				"sheathe sword" ..
				cs ..
				"raze " ..
				target ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  compass =
			function()
			  action = "compass"
			  return
				infusedecide() ..
				cs ..
				"compassslash " ..
				target ..
				" " ..
				compass_conv[limb] ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  legslash =
			function()
			  action = "legslash"
			  return
				infusedecide() ..
				cs ..
				"legslash " ..
				target ..
				" " ..
				conv[limb] ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  armslash =
			function()
			  action = "armslash"
			  return
				infusedecide() ..
				cs ..
				"armslash " ..
				target ..
				" " ..
				conv[limb] ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  centreslash =
			function()
			  action = "centreslash"
			  return
				infusedecide() ..
				cs ..
				"centreslash " ..
				target ..
				" " ..
				conv[limb] ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  balanceslash =
			function()
			  action = "balanceslash"
			  return
				infusedecide() ..
				cs ..
				"balanceslash " ..
				target ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		  pommelstrike =
			function()
			  action = "pommelstrike"
			  return
				"pommelstrike " ..
				target ..
				" " ..
				strikedecide() ..
				cs ..
				"discern " ..
				target ..
				cs ..
				"assess " ..
				target
			end,
		}
	  -- If the slashtype is found in the handlers, call the handler and return the command
	  if actionHandlers[slashtype] then
		return actionHandlers[slashtype]() -- Call the function and return the command
	  end
	  return "" -- Return an empty string if no handler is found for the slashtype
end

-- Handle airfist and voidfist actions if requested

function handleFistActions()
  if not airfisted and myshin() > 20 then
    action = "airfist"
    command = "airfist " .. target
  --elseif not voidfisted and myshin() > 15 then
    --action = "voidfist"
    --command = "voidfist " .. target
  end
end


-- Handle defensive actions like hamstring, healthtrans, etc.

function handleDefensiveActions()
  if healrequested and shin() > 20 then
    action = "healthtrans"
    command = "shin healthtrans all"
  elseif manarequested and shin() > 20 then
    action = "manatrans"
    command = "shin manatrans all"
  elseif alleviaterequested then
    action = "alleviate"
    command = "alleviate"
  elseif
    (
      phoenixrequested or
      (
        listfind(myaffs, "anorexia") and
        listfind(myaffs, "asthma") and
        listfind(myaffs, "slickness")
      )
    ) and
    shin() > 79
  then
    action = "phoenix"
    command = "shin phoenix"
  end
end

-- Handle flee, tumble, or attack check logic

function handleTumbleLogic()
  if fleerequested or tumblerequested or attackcheck() then
    musttumble = true
  end
  if musttumble and tumblecd < os.clock() then
    myfleedir = findDirection()
    -- Get tumble direction
    action = "tumble"
    command = "tumble " .. myfleedir
    tumblecd = os.clock() + 8
    -- Set cooldown
  end
end

-- Handle flying target (special condition)

function handleFlyingTarget()
  if targetflying then
    action = "leap"
    command = "leap high"
  else
    if flying then
      action = "land"
      command = "land"
    end
  end
end

-- This function handles the logic when a target leaves the room.

function handleChaseLogic(line)
  local tar
  local direction = ""
  local command = ""
  -- Common target-leaves triggers. This gives us the direction.
  if string.match(line, "^(%w+) slowly hobbles (%w+).$") then
    tar, direction = string.match(line, "^(%w+) slowly hobbles (%w+).$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+) tumbles out to the (%w+).$") then
    tar, direction = string.match(line, "^(%w+) tumbles out to the (%w+).$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+) glances (%w+) and vanishes.$") then
    tar, direction = string.match(line, "^(%w+) glances (%w+) and vanishes.$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+) leaves to the (%w+).$") then
    tar, direction = string.match(line, "^(%w+) leaves to the (%w+).$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+), riding .+, leaves to the (%w+).$") then
    tar, direction = string.match(line, "^(%w+), riding .+, leaves to the (%w+).$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+) launches %w+ to the (%w+) in a great leap.$") then
    tar, direction = string.match(line, "^(%w+) launches %w+ to the (%w+) in a great leap.$")
    command = "who " .. direction
  elseif
    string.match(line, "^(%w+) stomps out to the (%w+), shaking the ground with each step.$")
  then
    tar, direction =
      string.match(line, "^(%w+) stomps out to the (%w+), shaking the ground with each step.$")
    command = "who " .. direction
  elseif string.match(line, "^(%w+) moves %w+ huge bulk to the (%w+) with surprising grace.$") then
    tar, direction =
      string.match(line, "^(%w+) moves %w+ huge bulk to the (%w+) with surprising grace.$")
    command = "who " .. direction
    -- Target following another person
  elseif string.match(line, "^(%w+) leaves, following %w+ to the (%w+).$") then
    tar, direction = string.match(line, "^(%w+) leaves, following %w+ to the (%w+).$")
    command = "who " .. direction
    -- Handle ghosted person leaving the room (special case)
    --elseif string.match(line, "^A ghostly apparition vanishes from sight to the (%w+).$") then
    -- direction = string.match(line, "^A ghostly apparition vanishes from sight to the (%w+).$")
    -- command = "who "..direction
    -- Special case handling (jolted in a direction)
  elseif string.match(line, "^You are jolted violently (%w+)wards by powers unseen.$") then
    direction = string.match(line, "^You are jolted violently (%w+)wards by powers unseen.$")
    local conversion =
      {
        southeast = "northwest",
        southwest = "northeast",
        northwest = "southeast",
        northeast = "southwest",
        north = "south",
        south = "north",
        east = "west",
        west = "east",
        up = "down",
        down = "up",
      }
    command = "who " .. conversion[direction]
    -- Adjust the direction accordingly
  end
  -- Check if the target is the one we are tracking
  if tar == target:title() then
    -- Target is leaving, so request a chase
    requestchase = true
    -- Store direction and command for the chase
    chasedata = {direction = direction, command = command}
  else
    -- Reset requestchase if it's not the target and clear chasedata
    requestchase = false
    chasedata = {}
  end
end

-- Function to dynamically handle combat actions

function blademaster(limb)
  local cs = cmdsep
  -- Immunity Handling
  --if immunityrequested or inimmunity then
  --   halted = true
  --   action = ""
  --  command = ""
  --end
  -- if immunityrequested and immunitycd < os.clock() then
  --   cecho("<cyan>i want immunity!")
  --  action = "immunity"
  --  command = "immunity"
  --  immunitycd = os.clock() + 4  -- Set the cooldown for immunity
  --end
  -- Handle action based on the slashtype
  command = handleActionBasedOnSlashtype(limb)
  -- Handle airfist and voidfist if requested
  
 
  handleFistActions()
  -- Handle special actions like flying targets
  handleFlyingTarget()
  -- Handle defensive abilities (hamstring, heal, etc.)
  handleDefensiveActions()
  -- Handle flee, tumble, or attack check
  handleTumbleLogic()
  -- If requestchase is true, use chase data
  --echo("\naction: " .. action)
  --echo("\ncommand: " .. command)
  
   
  if requestchase then
    -- Implement chasing logic, send movement or search commands here
    cecho("<yellow>Chasing target...\n")
    -- Use the command and direction stored in chasedata
    send(chasedata.command)
  else
    -- If a valid action exists, retrieve the checks string and send the command
   if action ~= "" and command ~= "" then
 
      local checks = getQueueConditions(action)
      --echo("\nqueue addclear " .. checks .. " " .. command)
      send("\nqueue addclear " .. checks .. " " .. command)
    else
      --echo"\nwe have no actions to queue"
    end
  end
end

function infusedecide()

local infusionMap = {
  armslash = "infuse ice",
  legslash = "infuse fire",
  pommelstrike = "infuse void",
  raze = "infuse void",
  compass = "infuse earth"
}

  if --[[hisbal < os.clock() - 3 or]] probabilityTable["prone"] == 1 then
    return "infuse lightning"
  elseif slashtype == "raze" then
	return "infuse void"
  else
	return infusionMap[slashtype] or "infuse lightning"
  end

end

function strikedecide()
  local cs = cmdsep
  local reactwindow = reactwindow or 0
  -- Mapping afflictions to body parts for targeted strikes
  local afftostrike =
    {
      anorexia = "stomach",
      hypochondria = "chest",
      asthma = "throat",
      slickness = "underarm",
      paralysis = "neck",
      clumsiness = "ears",
      weariness = "shoulder",
    }
  -- Fourth priority: Affliction-based targeting
  local foundone = 0
  local stacklist =
    {
      {"paralysis", 100},
      {"hypochondria", 100},
      {"asthma", 100},
      {"slickness", 100},
      {"anorexia", 100},
    }
  -- Dynamically select the most appropriate affliction
  for i = 1, #stacklist do
    if probabilityTable[stacklist[i][1]] < stacklist[i][2] and foundone == 0 then
      foundone = i
    end
  end
  -- Assign the condition found to jinx
  jinx = foundone
  selected = false
  -- If the current conditions match, attempt to select a new strategy
  if intime() and probabilityTable["paralysis"] == 1 and slashtype == "pommelstrike" then
    for i = 1, #stacklist do
      if probabilityTable[stacklist[i][1]] < stacklist[i][2] and i ~= jinx and not (selected) then
        selected = true
        foundone = i
      end
    end
  end
  -- Select affliction to strike based on probabilities
  local affliction = stacklist[foundone][1]
  if affliction then
    decidedstrike = afftostrike[affliction]
  end
  -- Third priority: Balance timing logic
  --if hisbal < os.clock() - 3 then
   -- decidedstrike = "sternum"
  --end
  -- Second priority: React window logic
  if reactwindow > os.clock() then
    decidedstrike = "knees"
  end
  -- Highest priority: Ensure hamstring is maintained
  if requestedstrike == "hamstring" or not hamstrung then
    decidedstrike = "hamstring"
  end
  -- Fifth priority: Mounted or prone checks
  if targetmounted or requestedstrike == "prone" then
    decidedstrike = "knees"
  end
  -- Final fallback: Default to engagement and sternum strike
  if not engaged then
    decidedstrike = decidedstrike .. cs .. "engage " .. target
  end
  return decidedstrike
end

-- Define the function that handles the limb damage and remaining strikes

function handleLimbs(line)
  -- Match the pattern for the damage line with a flexible capture for the limb
  if
    string.match(
      line,
      "^As you carve into (%w+), you perceive that you have dealt (%d+%.?%d*)%% damage to %w+ (.+)%."
    )
  then
    -- Extract target, damage, and limb from the string
    local tar, damage, limb =
      string.match(
        line,
        "^As you carve into (%w+), you perceive that you have dealt (%d+%.?%d*)%% damage to %w+ (.+)%."
      )
    -- update current percentages for correct values later.
    if slashtype == "compass" then
      compass_conv[stance] = damage
    elseif slashtype == "legslash" or slashtype == "armslash" or slashtype == "centreslash" then
      limbslash_conv[stance] = damage
    end
    -- Check if the matching was successful
    if tar == target:title() and damage and limb then
      -- Initialize the limb damage table for the target if it doesn't exist
      if not limbdamage[target:title()] then
        limbdamage[target:title()] =
          {
            ["head"] = {health = 100, hits = 10},
            ["torso"] = {health = 100, hits = 10},
            ["left leg"] = {health = 100, hits = 10},
            ["right leg"] = {health = 100, hits = 10},
            ["left arm"] = {health = 100, hits = 10},
            ["right arm"] = {health = 100, hits = 10},
          }
      end
      -- Convert the damage to a number for processing
      damage = tonumber(damage)
      -- Subtract damage from the corresponding limb's health
      if limbdamage[target:title()][limb] then
        limbdamage[target:title()][limb].health = limbdamage[target:title()][limb].health - damage
        -- If the limb is prepped (health <= 0), mark it
        if limbdamage[target:title()][limb].hits == 1 then
          cecho("\n<red>" .. target .. "'s " .. limb .. " is prepped for break!")
        end
      end
      -- Output the current state of the target's limb health
      cecho("\n<yellow>Target<white>: " .. target)
      cecho("\n<yellow>Damage<white>: " .. damage)
      cecho("\n<yellow>Limb<white>: " .. limb)
      -- Loop through each limb and calculate the remaining strikes
      for limbName, data in pairs(limbdamage[target:title()]) do
        -- Calculate the remaining hits for the current limb
        local remainingStrikes = calculateRemainingStrikes(data.health, damage)
        -- Use damage as a parameter
        -- Update the remaining hits
        limbdamage[target:title()][limbName].hits = remainingStrikes
        -- Echo the result for the current limb
        if DEBUG_MODE then
          cecho(
            "\n<green>" ..
            limbName:title() ..
            " <white>Hits Remaining: " ..
            remainingStrikes ..
            " Health: " ..
            data.health
          )
        end
      end
    end
  end
end

function calculateRemainingStrikes(health, damage)
  -- Calculate the number of strikes needed based on the remaining health of the limb
  local remainingStrikes = math.ceil(health / damage)
  return remainingStrikes
end

-- Function to handle skill triggers (balance used and balance recovered)

function combatHandler(line)
  if line and line ~= "" then
    handleLimbs(line)
    handleStances(line)
    handleChaseLogic(line)
    handleAssess(line)
    handleTumbling(line)
    handleSwordAttack(line)
    handleStriking(line)
    enemyAvoidedAttack(line)
    resetLimbs(line)
  end
end

function reloadCombatFile()
  dofile(getMudletHomeDir() .. "/Achaean System/combat/blademaster.lua")
  -- Adjust the path as needed
  resetCombatState()
  combatLoaded = true
end