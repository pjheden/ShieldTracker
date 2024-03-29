function Init()
  print("ShieldTracker: init");
  shieldHealth = {
    ["Power Word: Shield"] = 942,
    ["Mana Shield"] = 570,
    ["Ice Barrier"] = 826
  }

  currentShields = {}
  counter = 1
  DEBUG = false
  local f = CreateFrame("Frame");
  -- Step 3: Register so you listen to damage taken
  f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  -- Step 1: On buff event check if the spell is a shield spell
  f:SetScript("OnEvent", OnEvent)

  -- prioritized TODO:
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
  local playerName = UnitName("player")
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
  -- firstArg is some unknown variable, but it seems that the return arugments
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
      if DEBUG then
        print("============")
        print("Current Shield Name: " .. currentShields[i].Name)
        print("Current Shield HP: " .. currentShields[i].HP)
        print("============")
      end
      -- Update UI
      local maxShieldHealth = shieldHealth[currentShields[i].Name]
      local hpPerc = currentShields[i].HP / maxShieldHealth
      SetShieldHealth(currentShields[i].BarIndex, hpPerc)
      break
    end
  end
end

function UpdateCounter()
  counter = counter + 1
  if counter == 4 then counter = 1 end
end
-- NEW SHIELD ON TARGET
function OnAuraApplied(...)
  -- Kolla att det är en aura vi bryr oss om
  -- Add to currentShields list
  local _, shieldName = ...
  if DEBUG then print("OnAuraApplied: " .. shieldName) end
  local currentShieldHealth = shieldHealth[shieldName]
  if currentShieldHealth ~= nil then
    curShield = {
      ["HP"] = currentShieldHealth,
      ["Name"] = shieldName,
      ["BarIndex"] = counter
    }
    table.insert(currentShields, curShield)
    -- Update UI
    ShowBar(counter, GetColor("red"))
    UpdateCounter()
  end
end

-- CAST SAME SHIELD AGAIN
function OnAuraRefreshed(...)
  local _, shieldName = ...
  if DEBUG then print("OnAuraRefreshed: " .. shieldName) end
  -- Get health from DB
  local currentShieldHealth = shieldHealth[shieldName]
  if currentShieldHealth == nil then return end
  -- Check if we have it in our list of shields
  for i = 1, #currentShields + 1 do
    if shieldName == currentShields[i].Name then
      -- Update shield data
      currentShields[i].HP = currentShieldHealth
      -- Update UI
      SetShieldHealth(currentShields[i].BarIndex, 1.0)
    end
  end

end

-- REMOVED, EXPIRED, OUT OF HEALTH
function OnAuraRemoved(...)
  local _, shieldName = ...
  if DEBUG then print("OnAuraRemoved: " .. shieldName) end
  -- Check if we have it in our list of shields
  for i = 1, #currentShields + 1 do
    if shieldName == currentShields[i].Name then
      print("MACKE SHIELDA MIG FÖR FAN")
      -- TODO: Play sound if right aura?
      -- Update UI
      HideBar(currentShields[i].BarIndex)
      table.remove(currentShields, i)

    end
  end

end

function OnCombatUpdate()
  ParseLogMessage(CombatLogGetCurrentEventInfo())
end
