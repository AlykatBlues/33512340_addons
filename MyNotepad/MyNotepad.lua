-- Addon Initialization
local frame = CreateFrame("Frame", "MyNotepadFrame", UIParent)
frame:SetSize(500, 400)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
})
frame:SetBackdropColor(0, 0, 0, 1)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide() -- Hide by default

-- Title Bar
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", frame, "TOP", 0, -10)
title:SetText("My Notepad")

-- Notes List
local notesList = CreateFrame("ScrollFrame", "MyNotepadList", frame, "UIPanelScrollFrameTemplate")
notesList:SetSize(150, 320)
notesList:SetPoint("LEFT", frame, "LEFT", 10, 0)

local notesContent = CreateFrame("Frame", nil, notesList)
notesContent:SetSize(150, 320)
notesList:SetScrollChild(notesContent)

-- Text Editor
local editBox = CreateFrame("EditBox", nil, frame)
editBox:SetMultiLine(true)
editBox:SetSize(300, 220)
editBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -70)
editBox:SetFontObject("GameFontHighlight")
editBox:SetTextInsets(10, 10, 10, 10)
editBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 5,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
editBox:SetBackdropColor(0, 0, 0, 1)
editBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
editBox:SetAutoFocus(false)

-- Note Title Editor
local titleEditBox = CreateFrame("EditBox", nil, frame)
titleEditBox:SetSize(300, 30)
titleEditBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -40)
titleEditBox:SetFontObject("GameFontHighlight")
titleEditBox:SetTextInsets(10, 10, 10, 10)
titleEditBox:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 5,
    edgeSize = 12,
    insets = { left = 2, right = 2, top = 2, bottom = 2 }
})
titleEditBox:SetBackdropColor(0, 0, 0, 1)
titleEditBox:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
titleEditBox:SetAutoFocus(false)
titleEditBox:SetText("Note Title")

-- Save Button
local saveButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
saveButton:SetSize(80, 30)
saveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
saveButton:SetText("Save")

-- Delete Button
local deleteButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
deleteButton:SetSize(80, 30)
deleteButton:SetPoint("BOTTOMLEFT", saveButton, "BOTTOMRIGHT", 10, 0)
deleteButton:SetText("Delete")

-- Close Button
local closeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
closeButton:SetSize(80, 30)
closeButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
closeButton:SetText("Close")
closeButton:SetScript("OnClick", function()
    frame:Hide()
end)

-- Notes Data Initialization
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "MyNotepad" then
        if type(MyNotepadDB) ~= "table" then
            MyNotepadDB = {} -- Reset to a valid table
        end
    end
end)

-- Function to Refresh Notes List
local function refreshNotesList()
    for _, child in ipairs({notesContent:GetChildren()}) do
        child:Hide()
    end

    local offset = 0
    for noteTitle, _ in pairs(MyNotepadDB) do
        local button = CreateFrame("Button", nil, notesContent, "UIPanelButtonTemplate")
        button:SetSize(130, 30)
        button:SetPoint("TOPLEFT", notesContent, "TOPLEFT", 0, -offset)
        button:SetText(noteTitle)
        button:SetScript("OnClick", function()
            titleEditBox:SetText(noteTitle)
            editBox:SetText(MyNotepadDB[noteTitle])
        end)
        offset = offset + 35
    end
end

-- Save Button Logic
saveButton:SetScript("OnClick", function()
    if not MyNotepadDB then
        print("Error: Notes database is not initialized!")
        return
    end

    local noteTitle = titleEditBox:GetText()
    if noteTitle == "" then
        print("Error: Note title cannot be empty!")
        return
    end

    MyNotepadDB[noteTitle] = editBox:GetText()
    print("Saved note: " .. noteTitle)
    titleEditBox:SetText("") -- Clear the title box
    editBox:SetText("") -- Clear the content box
    refreshNotesList()
end)

-- Delete Button Logic
deleteButton:SetScript("OnClick", function()
    if not MyNotepadDB then
        print("Error: Notes database is not initialized!")
        return
    end

    local noteTitle = titleEditBox:GetText()
    if noteTitle == "" or not MyNotepadDB[noteTitle] then
        print("Error: Note title does not exist!")
        return
    end

    MyNotepadDB[noteTitle] = nil -- Remove the note
    titleEditBox:SetText("") -- Clear the title box
    editBox:SetText("") -- Clear the content box
    print("Deleted note: " .. noteTitle)
    refreshNotesList() -- Refresh the list of notes
end)

-- On-Screen Button
local button = CreateFrame("Button", "MyNotepadButton", UIParent, "UIPanelButtonTemplate")
button:SetSize(100, 30)
button:SetPoint("TOP", UIParent, "TOP", 0, -50)
button:SetText("Notepad")
button:SetMovable(true)
button:RegisterForDrag("LeftButton")
button:SetScript("OnDragStart", function(self) self:StartMoving() end)
button:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
button:SetScript("OnClick", function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        refreshNotesList()
    end
end)

-- Debug message to confirm addon loaded
print("MyNotepad addon loaded!")
