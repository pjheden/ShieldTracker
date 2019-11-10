BarConfig = {
    height = 24,
    width = 116,
    borderScale = 1.1
}

function InitUI ()
  print("ShieldTracker: initUI")

  local shieldBar = CreateFrame("Frame", "ShieldTrackerBar", UIParent) --Ignored ParentUI
  shieldBar:SetSize(BarConfig.width, BarConfig.height*3)
	shieldBar:SetMovable(true)
  print("After creating frame")

  shieldBar:SetPoint("CENTER", 0, 0)

  CreateNewBar(1, GetColor("red"))
  CreateNewBar(2, GetColor("green"))
  CreateNewBar(3, GetColor("blue"))

  SetShieldHealth(1, 0.5)
  RemoveBar(2)
  SetShieldHealth(3, 0.1)
end

function GetColor(name)
  if name == "red" then
    -- red
    return {["R"]=1.0, ["G"]=0.0, ["B"]=0.0, ["A1"]=1.0}
  elseif name == "green" then
    -- green
    return {["R"]=0.0, ["G"]=1.0, ["B"]=0.0, ["A"]=1.0}
  else
    -- blue
    return {["R"]=0.0, ["G"]=0.0, ["B"]=1.0, ["A"]=1.0}
  end
end

function CreateNewBar(index, color)
  -- create colorful bar
  local barBackground = ShieldTrackerBar:CreateTexture(
                        "ShieldTrackerBarBackground" .. index,
                        "BACKGROUND")
  barBackground:SetSize(BarConfig.width, BarConfig.height)
  barBackground:SetColorTexture(color.R, color.G, color.B, color.A)
  barBackground:SetPoint("LEFT", 0, index*BarConfig.height)

  -- create border
  local barBorder = ShieldTrackerBar:CreateTexture(
                    "ShieldTrackerBarBorder"..index,
                    "OVERLAY")
  barBorder:SetWidth(_G["ShieldTrackerBarBackground"..index]:GetWidth() * BarConfig.borderScale)
  barBorder:SetHeight(_G["ShieldTrackerBarBackground"..index]:GetHeight() * BarConfig.borderScale)
  barBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
  barBorder:SetPoint("CENTER", 0, index*BarConfig.height)
end

function SetShieldHealth(index, hpPerc)
  local minWidth = 0
  local maxWidth = BarConfig.width
  _G["ShieldTrackerBarBackground"..index]:SetWidth(maxWidth * hpPerc)
end

function RemoveBar(index)
  -- TODO: properly remove it
  _G["ShieldTrackerBarBackground"..index]:Hide(0)
  _G["ShieldTrackerBarBorder"..index]:Hide(0)
end

-- function OnUpdate(self, elapsed)
--   local r = math.random(80, 116)
--   ShieldTrackerBarBackground:SetWidth(r)
-- end
