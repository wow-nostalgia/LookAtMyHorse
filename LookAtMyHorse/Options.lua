local addonName, addon = ...
local Core = addon.Core
local Utils = addon.Utils

local f = CreateFrame("Frame", "LookAtMyHorseOptionsFrame", UIParent)
f:SetSize(600, 300)
f:SetPoint("CENTER")
f:SetBackdrop({
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    edgeSize = 32,
})
f:EnableMouse(true)
f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", f.StopMovingOrSizing)
f:SetFrameStrata("HIGH")
f:Hide()

local bg = f:CreateTexture(nil, "BACKGROUND")
bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
bg:SetPoint("TOPLEFT", 8, -8)
bg:SetPoint("BOTTOMRIGHT", -8, 8)

local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -15)
title:SetText("LookAtMyHorse")

local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)
close:SetScript("OnClick", function()
    Core:CheckMountUpdate(true)
    f:Hide()
end)


if not LookAtMyHorseDB then
    LookAtMyHorseDB = { FlyMounts = {}, GroundMounts = {} }
end

local listWidth, listHeight = 250, 180
local itemHeight = 20

local function CreateMountColumn(parent, xOffset, labelText, dbList, dbKey)

    -- label
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("TOPLEFT", xOffset, -40)
    label:SetText(labelText)

    -- input box (single-line)
    local input = CreateFrame("EditBox", dbKey.."_EditBox", parent, "InputBoxTemplate")
    input:SetSize(240, 20)
    input:SetPoint("TOPLEFT", xOffset, -60)
    input:SetAutoFocus(false)
    input:SetText("")

    hooksecurefunc("ChatEdit_InsertLink", function(text)
        if input:IsVisible() and input:HasFocus() and IsShiftKeyDown() and ChatEdit_GetActiveWindow() == nil then

            local name = text:match("%[(.-)%]")  -- витягуємо текст між [ і ]
            if name then
                input:Insert(name)
            else
                input:Insert(text)
            end
        end
    end)

    -- add button
    local addBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    addBtn:SetSize(26, 20)
    addBtn:SetPoint("LEFT", input, "RIGHT", 6, 0)
    addBtn:SetText("+")

    -- ScrollFrame + content
    local scroll = CreateFrame("ScrollFrame", dbKey.."_ScrollFrame", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", xOffset, -90)
    scroll:SetSize(listWidth, listHeight)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    content:SetSize(listWidth, listHeight)
    scroll:SetScrollChild(content)

    -- store created frames in table for update
    local col = {
        input = input,
        addBtn = addBtn,
        scroll = scroll,
        content = content,
        list = dbList,
        key = dbKey,
    }

    -- function to rebuild list UI
    function col:Refresh()
        -- clear existing children
        for _, child in ipairs({ self.content:GetChildren() }) do
            child:Hide()
            child:SetParent(nil)
        end

        local y = -4
        for i = 1, #self.list do
            local name = self.list[i]

            -- row frame
            local row = CreateFrame("Frame", nil, self.content)
            row:SetSize(listWidth, itemHeight)
            row:SetPoint("TOPLEFT", 4, y)

            -- text label
            local txt = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            txt:SetPoint("LEFT", 0, 0)
            txt:SetWidth(listWidth - 28)
            txt:SetJustifyH("LEFT")
            txt:SetText(name)

            -- remove button
            local rem = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
            rem:SetSize(18, 18)
            rem:SetPoint("RIGHT", row, "RIGHT", -2, 0)
            rem:SetText("-")

            -- closure capture index
            rem:SetScript("OnClick", function()
                table.remove(self.list, i)
                -- if per-character saved table
                LookAtMyHorseDB[self.key] = self.list
                self:Refresh()
            end)

            y = y - itemHeight
        end

        -- adjust content height
        local contentHeight = math.max(listHeight, (#self.list) * itemHeight + 8)
        
        content:SetHeight(contentHeight)


        local sb = scroll.ScrollBar
        if sb then
            local max = math.max(0, contentHeight - listHeight)
            sb:SetMinMaxValues(0, max)
            sb:SetValue(0) 
        end
    end

    -- add button logic
    addBtn:SetScript("OnClick", function()
        local text = (input:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", "")
        if text ~= "" then
            table.insert(col.list, text)
            LookAtMyHorseDB[col.key] = col.list
            input:SetText("")
            col:Refresh()
        end
    end)

    -- enter to add
    input:SetScript("OnEnterPressed", function()
        addBtn:Click()
    end)

    -- initial refresh
    col:Refresh()

    return col
end


local flyCol = CreateMountColumn(f, 20, "Літаючі маунти:", LookAtMyHorseDB.FlyMounts, "FlyMounts")
local groundCol = CreateMountColumn(f, 310, "Наземні маунти:", LookAtMyHorseDB.GroundMounts, "GroundMounts")

f:SetScript("OnShow", function()
    flyCol.list = LookAtMyHorseDB.FlyMounts
    groundCol.list = LookAtMyHorseDB.GroundMounts
    flyCol:Refresh()
    groundCol:Refresh()
end)


SLASH_LOOKATMYHORSE1 = "/look-at-my-horse"
SlashCmdList["LOOKATMYHORSE"] = function()
    f:Show()
end
