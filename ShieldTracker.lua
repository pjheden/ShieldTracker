function Init()
  print("ShieldTracker: init");
  shieldHealth = {
    ["Power Word: Shield"] = 942,
    ["Mana Shield"] = 570,
    ["Ice Barrier"] = 826
  }
  currentShield = {
    ["HP"] = 0,
    ["Name"] = ""
  }


  local f = CreateFrame("Frame");
  -- Step 0: Register events to listen to buffs on player
  f:RegisterEvent("UNIT_AURA")
  -- Step 3: Register so you listen to damage taken
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  -- Step 1: On buff event check if the spell is a shield spell
  f:SetScript("OnEvent", OnEvent)

  -- TOP LEVEL:
  -- NECESSARY
  -- * Register to correct events,
  -- * Store or get data of shield spell and HP,
  -- * Visualize health of shield,
  --
  -- EXTRA
  -- * Play sound on break
  -- * Shield health on other players
  -- * (Store what players have what talents)
end


function OnEvent(self, event, ...)
  if event == "UNIT_AURA" then
    OnUnitAura(...)
  elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
    OnCombatUpdate()
  end
end

function OnUnitAura(...)
  local unitTarget = ...
  if unitTarget ~= "player" then
    return
  end
  print("unitTarget " .. unitTarget)

  -- Iterate over player buffs to look for shield
  for i=1,50 do
    -- TODO: bug where shield hp refreshes whern another aura is added
    local name, _, _, _, duration, expirationTime, source, _, _, spellID = UnitAura("player", i)
    if name == nil then
      print("No more auras, name == nil")
      break
    end
    -- TODO: add other spells and maybe use spellID instead
    local currentShieldHealth = shieldHealth[name]
    if currentShieldHealth ~= nil then
      -- Step 2: Get the health of the shield spell and set shield variables
      print("Power shield found on player, setting shield variables!")
      currentShield.HP = currentShieldHealth
      currentShield.Name = name
      break
    end
  end
end

-- TODO rename this
local function ParseLogMessage(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, ...)
  -- TODO: get current player name
  if (recipientName == "Icebag" or recipientName == "Mardur") and event == "SPELL_ABSORBED" then
    -- TODO: find better method to do this
    local firstArg = ...
    if firstArg == 0 then
      local _, _, _, _, _, _, _, shieldID, shieldName, _, dmg = ...
      print("Current Shield HP BEFORE: " .. currentShield.HP)
      currentShield.HP = currentShield.HP - dmg
      print("Current Shield HP AFTER: " .. currentShield.HP)
    else
      local _, _, _, _, shieldID, shieldName, _, dmg = ...
      print("Current Shield HP BEFORE: " .. currentShield.HP)
      -- -- Step 4: On damage taken, update shield variables
      currentShield.HP = currentShield.HP - dmg
      -- Step 5: Visualize health on shield based on shield variables (TEXT / number on screen / bar on screen)
      print("Current Shield HP AFTER: " .. currentShield.HP)
    end

  elseif (recipientName == "Icebag" or recipientName == "Mardur") and event == "SPELL_AURA_REMOVED" then
    local _, spellName = ...
    if spellName == currentShield.Name then
      print("MACKE SHIELDA MIG FÖR FAN")
      -- TODO: Play sound if right aura?
    end

  end
end

function OnCombatUpdate()
  ParseLogMessage(CombatLogGetCurrentEventInfo())
end
