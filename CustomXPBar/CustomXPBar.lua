local frame = CustomXPBarFrame
local bar = CreateFrame("StatusBar", nil, frame)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:SetStatusBarColor(0, 0.6, 1)
bar:SetAllPoints(frame)
bar:SetMinMaxValues(0, 100)
bar:SetValue(0)

-- Text for XP and level
local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER", bar, "CENTER", 0, 0)

-- Save and restore position
local function SavePosition()
    local point, _, relativePoint, xOfs, yOfs = frame:GetPoint()
    CustomXPBarDB = { point = point, relativePoint = relativePoint, x = xOfs, y = yOfs }
end

local function LoadPosition()
    if CustomXPBarDB then
        frame:ClearAllPoints()
        frame:SetPoint(CustomXPBarDB.point, UIParent, CustomXPBarDB.relativePoint, CustomXPBarDB.x, CustomXPBarDB.y)
    end
end

-- Update XP bar display
local function UpdateXPBar()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local level = UnitLevel("player")

    bar:SetMinMaxValues(0, maxXP)
    bar:SetValue(currentXP)

    text:SetText(string.format("Level: %d - %d / %d XP", level, currentXP, maxXP))
end

-- Hide the default Blizzard XP bar
local function HideBlizzardXPBar()
    if MainMenuBarExpBar then
        MainMenuBarExpBar:Hide()
        MainMenuBarExpBar:UnregisterAllEvents()
        MainMenuBarExpBar:SetScript("OnUpdate", nil)
        MainMenuBarExpBar:SetScript("OnShow", function(self) self:Hide() end)
    end
end

-- Setup frame
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition()
end)

frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        LoadPosition()
        HideBlizzardXPBar()
    end
    UpdateXPBar()
end)
