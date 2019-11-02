function Init()
  print("ShieldTracker: init");
  local f = CreateFrame("Frame");
  -- Step 0: Register events to listen to buffs on player
  f:RegisterEvent("UNIT_AURA")
  -- Step 1: On buff event check if the spell is a shield spell
  f:SetScript("OnEvent",
    function(self, event, ...)
      if event == "UNIT_AURA" then
        local unitTarget , arg2, arg3, arg4 = ...
        print("UNIT_AURA")
        print("unitTarget " .. unitTarget)
        print("arg2 " .. arg2)
        print("arg3 " .. arg3)
        print("arg4 " .. arg4)
      end
    end)
  -- f:SetScript("OnEvent",
  -- 	function(self, event, ...)
  --       if event === "UNIT_AURA" then
  --         print("UNIT_AURA")
  --       end
  --     end
  -- 	end)



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
  --

  -- Step 2: Get the health of the shield spell and set shield variabes
  -- Step 3: Register so you listen to damage taken
  -- Step 4: On damage taken, update shield variables
  -- Step 5: Visualize health on shield based on shield variables (TEXT / number on screen / bar on screen)
  --
  --
  -- Step 6: Play sound when shield break
end
