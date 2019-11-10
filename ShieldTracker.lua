function Init()
  print("ShieldTracker: init");
  shieldHealth = {
    ["Power Word: Shield"] = 942,
    ["Mana Shield"] = 570,
    ["Ice Barrier"] = 826
  }

  currentShields = {}

  local f = CreateFrame("Frame");
  -- Step 3: Register so you listen to damage taken
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  -- Step 1: On buff event check if the spell is a shield spell
  f:SetScript("OnEvent", OnEvent)

  -- prioritized TODO:
  -- 1. Set recepientName to actual player in ParseLogMessage()
  -- 2. Graphical representation of shield HP instead of print
  -- 3. Play sound on break
  -- 4 Rename addon to "WillItPop"
  -- 5. Adjust shield hp on spellpower / talents
  -- 6. Shield health on other players
end

function OnEvent(self, event, ...)
  if event == "COMBAT_LOG_EVENT_UNFILTERED" then
    OnCombatUpdate()
  end
end

local function ParseLogMessage(timestamp, event, hideCaster, sourceGUID,
   sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName,
   recipientFlags, recipientRaidFlags, ...)
  -- TODO: get current player name
  local playerName = UnitName('player')
  if recipientName == playerName then
    if event == "SPELL_ABSORBED" then
      OnSpellAbsorbed(...)
    elseif event == "SPELL_AURA_APPLIED" then
      OnAuraApplied(...)
    elseif event == "SPELL_AURA_REFRESH" then
      OnAuraRefreshed(...)
    elseif event == "SPELL_AURA_REMOVED" then
      OnAuraRemoved(...)
    end
  end
end

function OnSpellAbsorbed(...)
  -- firstARg is some unknown variable, but it seems that the return arugments
  -- are different if it is 0 compared to non zero. Has something to do with
  -- if it is melee dmg or caster dmg.
  local firstArg = ...
  if firstArg == 0 then
    local _, _, _, _, _, _, _, shieldID, shieldName, _, dmg = ...
    UpdateShieldHealth(shieldName, dmg)
  else
    local _, _, _, _, shieldID, shieldName, _, dmg = ...
    UpdateShieldHealth(shieldName, dmg)
  end
end

function UpdateShieldHealth(name, dmg)
  for i = 1, #currentShields + 1 do
    if name == currentShields[i].Name then
      currentShields[i].HP = currentShields[i].HP - dmg
      print("============")
      print("Current Shield Name: " .. currentShields[i].Name)
      print("Current Shield HP: " .. currentShields[i].HP)
      print("============")
      break
    end
  end
end

-- NEW SHIELD ON TARGET
function OnAuraApplied(...)
  -- Kolla att det är en aura vi bryr oss om
  -- Add to currentShields list
  local _, shieldName = ...
  print("OnAuraApplied: " .. shieldName)
  local currentShieldHealth = shieldHealth[shieldName]
  if currentShieldHealth ~= nil then
    curShield = {
      ["HP"] = currentShieldHealth,
      ["Name"] = shieldName
    }
    table.insert(currentShields, curShield)
  end
end

-- CAST SAME SHIELD AGAIN
function OnAuraRefreshed(...)
  local _, shieldName = ...
  print("OnAuraRefreshed: " .. shieldName)
  -- Get health from DB
  local currentShieldHealth = shieldHealth[shieldName]
  if currentShieldHealth == nil then return end
  -- Check if we have it in our list of shields
  for i = 1, #currentShields + 1 do
    if shieldName == currentShields[i].Name then
      -- Update shield data
      currentShields[i].HP = currentShieldHealth
    end
  end

end

-- REMOVED, EXPIRED, OUT OF HEALTH
function OnAuraRemoved(...)
  local _, shieldName = ...
  print("OnAuraRemoved: "..shieldName)
  -- Check if we have it in our list of shields
  for i = 1, #currentShields + 1 do
    if shieldName == currentShields[i].Name then
      table.remove(currentShields, i)
      print("MACKE SHIELDA MIG FÖR FAN")
      -- TODO: Play sound if right aura?
      break
    end
  end

end

function OnCombatUpdate()
  ParseLogMessage(CombatLogGetCurrentEventInfo())
end
