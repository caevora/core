TAROT = TAROT or {}

function updateStrategyFile()
  dofile(getMudletHomeDir() .. "/Achaean System/combat/strategy.lua")
  -- loads logic
  TAROT:loadAllStrategies()
  -- loads modular strategies
  if TAROT.evaluateStrategies then
    cecho("\n<green>[TAROT] Strategies fully loaded.")
  else
    cecho("\n<red>[TAROT] Strategy loader failed.")
  end
  TAROT:resetTarotValues()
end

--Example core logic:
-----------------------------
--[[
| Phase     | Action                                                                      |
| --------- | --------------------------------------------------------------------------- |
| 🧠 Plan   | Devil + Aeon + Moon burst                                                   |
| 🎴 Step 1 | `fling devil at ground` (activates Devil)                                   |
| 🔁 Step 2 | `fling aeon at <target>` (Devil triggers random tarot — ideally AEON again) |
| 🌙 Step 3 | Follow up with 1–2 Moon flings manually                                     |
| 🎯 Result | Stack mental affs fast; begin lock or set up Death                          |
]]
--devilmark synergy

function TAROT:activateDevilmark()
  if self:get("devil") <= 0 then
    cecho("\n<red>[TAROT] No Devil cards available.")
    return
  end
  send("fling devil at ground")
  self.devilActive = true
  self.devilCharges = 1
  -- Devil only fires once *per fling*
  cecho("\n<cyan>[TAROT] Devil summoned. Your next card will be duplicated.")
end

function TAROT:handle_aeon(target, opts)
  self:startAeonTracking()
  if self.devilActive and self.devilCharges > 0 then
    if self.devilCharges == 0 then
      cecho("\n<cyan>[TAROT] Devil is active. Hoping for double Aeon...")
    end
    -- We just fling AEON. Devil synergy will happen automatically by game rules.
    self.devilCharges = self.devilCharges - 1
    if self.devilCharges == 0 then
      self.devilActive = false
      cecho("\n<magenta>[Devil] Has vanished.")
    end
  end
  return "fling aeon at " .. (target or "target")
end

--can execute death.

function TAROT:canExecuteDeath(target)
  return
    deathRubCounts[target] >= 7 and targetHasAfflictions(target, {"aeon", "paralysis", "entangled"})
end

---------------------------

function TAROT:updateDeathExecuteFile()
  TAROT.STRATEGY = TAROT.STRATEGY or {}
  TAROT.STRATEGY.deathExecute =
    dofile(getMudletHomeDir() .. "/Achaean System/combat/strats/death_execute.lua")
  cecho("\n<green>[TAROT] Loaded: Death Execute strategy.")
end

function TAROT:loadAllStrategies()
  --devilAeon = "devil_aeon_combo",
  --visionLock = "vision_lock"
  -- add more here
  local strategyFiles = {
		death_execute 			= "death_execute", 
		affliction_spike	 	= "affliction_spike",
		entangle_death_prep		= "entangle_death_prep",
		summon_trap_combo 		= "summon_trap_combo",
		psych_lock_heretic 		= "psych_lock_heretic",
		escape_reset			= "escape_reset",
		mana_drain_lock			= "mana_drain_lock",
		ruinate_trick			= "ruinate_trick",
		star_finisher			= "star_finisher",
		justice_finisher		= "justice_finisher",
		trait_death				= "trait_death",
		trait_empress_trap		= "trait_empress_trap",
						}
  for key, file in pairs(strategyFiles) do
    local ok, strategy =
      pcall(dofile, getMudletHomeDir() .. "/Achaean System/combat/strats/" .. file .. ".lua")
    if ok and strategy then
      self.STRATEGY = self.STRATEGY or {}
      self.STRATEGY[key] = strategy
      cecho(string.format("\n<green>[TAROT] Loaded strategy: %s", key))
    else
      cecho(string.format("\n<red>[TAROT] Failed to load strategy: %s", key))
    end
  end
end

function TAROT:evaluateStrategies(target)
  cecho("\n<cyan>[TAROT] evaluateStrategies called for " .. tostring(target))
  if not target then
    cecho("\n<red>[TAROT] No target specified.")
    return false
  end
  if not self.STRATEGY then
    cecho("\n<red>[TAROT] Strategy table is not initialized.")
    return false
  end
  for name, strat in pairs(self.STRATEGY) do
    cecho(string.format("\n<cyan>[TAROT] Checking strategy: %s", strat.name or name))
    if self:checkStrategyRequirements(strat.requirements, target) then
      cecho(string.format("\n<green>[TAROT] Executing strategy: %s", strat.name or name))
      self:executeStrategySteps(strat.steps, target)
      return true
    end
  end
  cecho("\n<yellow>[TAROT] No viable strategies met requirements.")
  return false
end

function TAROT:assessCombatSituation(target)
  local context = self:getCombatContext(target)
  local viable = {}
  for name, strat in pairs(self.STRATEGY) do
    if self:meetsRequirements(strat.requirements, context) then
      table.insert(viable, strat)
    end
  end
  table.sort(
    viable,
    function(a, b)
      return (a.weight or 0) > (b.weight or 0)
    end
  )
  if #viable > 0 then
    self:executeStrategy(viable[1].name, target)
  else
    cecho("\n<orange>[TAROT] No viable strategy found.")
  end
end

--flexible matcher.

function TAROT:meetsRequirements(reqs, ctx)
  if not ctx then
    return false
  end
  if reqs.enemyHealthBelow and ctx.enemyHealth >= reqs.enemyHealthBelow then
    return false
  end
  if reqs.aeonActive and not ctx.aeonActive then
    return false
  end
  if reqs.targetEntangled and not ctx.targetEntangled then
    return false
  end
  --if reqs.hasAfflictions then
  --for _, aff in ipairs(reqs.hasAfflictions) do
  -- if not ctx.afflictions[aff] then return false end
  --end
  --end
  if reqs.hasAfflictions and not self:hasAffs(target, reqs.hasAfflictions) then
    return false
  end
  return true
end

function TAROT:checkStrategyRequirements(reqs, target)
  local affs = AFFLICTION_TRACKER and AFFLICTION_TRACKER[target] or {}
  local hp = ENEMY_STATUS and ENEMY_STATUS[target] and ENEMY_STATUS[target].hp or 100
  local entangled = ROOM_STATE[target] and ROOM_STATE[target].entangled or false
  local aeon = self.aeonTracking.awaiting
  local rubs = self.state.deathRubCounts[target] or 0
  if reqs.enemyHealthBelow and hp >= reqs.enemyHealthBelow then
    return false
  end
  if reqs.aeonActive and not aeon then
    return false
  end
  if reqs.targetEntangled and not entangled then
    return false
  end
  if reqs.deathRubCount and rubs < reqs.deathRubCount then
    return false
  end
  --if reqs.hasAfflictions then
  --for _, aff in ipairs(reqs.hasAfflictions) do
  --  if not affs[aff] then return false end
  --end
  --end
  if reqs.hasAfflictions and not self:hasAffs(target, reqs.hasAfflictions) then
    return false
  end
  return true
end

function TAROT:executeStrategySteps(steps, target)
  for _, step in ipairs(steps) do
    if step.action == "rub" and step.card == "death" then
      send("rub death on " .. target)
    elseif step.card == "moon" and step.affliction then
      send("fling moon at " .. target .. " " .. step.affliction)
    elseif step.card then
      send("fling " .. step.card .. " at " .. target)
    end
  end
end

function TAROT:hasAff(target, affName)
  return AFFLICTION_TRACKER and AFFLICTION_TRACKER[target] and AFFLICTION_TRACKER[target][affName]
end

function TAROT:hasAffs(target, affList)
  for _, aff in ipairs(affList) do
    if not self:hasAff(target, aff) then
      return false
    end
  end
  return true
end

function TAROT:testStrategies()
  if not TAROT or not TAROT.STRATEGY then
    cecho("\n<red>[DEBUG] TAROT.STRATEGY not loaded.")
    return
  end

  cecho("\n<white>[DEBUG] Loaded strategies:")
  for name, strat in pairs(TAROT.STRATEGY) do
    cecho(string.format("\n<cyan> - %s", name))
  end
end


return
  (
    function()
      local M = {}

      function M.reset()
        TAROT = TAROT or {}
        cecho("\n<white>[TAROT] Strategy values resetting...")
        --7 total for insta
        TAROT.STRATEGY =
          {
            deathCombo =
              {
                name = "Death Rub Setup",
                tags = {"kill", "affliction"},
                requirements =
                  {
                    hasAfflictions = {"aeon", "paralysis", "shivering"},
                    targetEntangled = true,
                    enemyHealthBelow = 30,
                  },
                steps =
                  {
                    {card = "death", action = "rub"},
                    {card = "moon", affliction = "asthma"},
                    {card = "death", action = "rub"},
                  },
              },
            devil_aeon_combo =
              {
                name = "Devil Aeon Setup",
                tags = {"opener", "burst"},
                requirements = {devilActive = true, hasCard = "aeon"},
                steps =
                  {
                    {card = "aeon", devil = true},
                    {
                      dynamic = true,
                      options =
                        {
                          condition =
                            function(ctxTarget)
                              return TAROT:hasAff(ctxTarget, "aeon")
                            end,
                          thenSteps = {{card = "moon"}, {card = "moon"}},
                          elseSteps = {{card = "aeon"}, {card = "moon"}},
                        },
                    },
                  },
              },
            visionLock =
              {
                name = "Vision Lock",
                tags = {"lock"},
                requirements = {hasAfflictions = {"hallucinations", "stupidity"}, aeonActive = true},
                steps =
                  {{card = "heretic"}, {card = "moon", affliction = "paralysis"}, {card = "devil"}},
              },
            deathExecute =
              {
                name = "Death Execute",
                tags = {"execute", "kill"},
                requirements =
                  {deathRubCount = 5, hasAfflictions = {"aeon", "paralysis", "entangled"}},
                steps = {{card = "death", action = "rub"}, {card = "death", action = "rub"}},
              },
          }
      end

      return M
    end
  )()
--EXAMPLE:  TAROT:evaluateStrategies("EnemyName")