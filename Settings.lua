local addonName, addonTable = ...
local frame

local function NewSlider(parent, label, min, max, defaultValue, savedVarKey)
    local holder = CreateFrame("Frame", nil, parent)
    holder:SetHeight(40)
    holder:SetPoint("LEFT", parent, "LEFT", 30, 0)
    holder:SetPoint("RIGHT", parent, "RIGHT", -30, 0)

    holder.Label = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    holder.Label:SetJustifyH("RIGHT")
    holder.Label:SetJustifyV("MIDDLE")
    holder.Label:SetPoint("LEFT", 20, 0)
    holder.Label:SetPoint("RIGHT", holder, "CENTER", -50, 0)
    holder.Label:SetText(label)

    holder.ValueText = holder:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    holder.ValueText:SetJustifyH("LEFT")
    holder.ValueText:SetJustifyV("MIDDLE")
    holder.ValueText:SetPoint("LEFT", holder, "RIGHT", -35, 0)
    holder.ValueText:SetText(TSBHCDB[savedVarKey] or defaultValue)

    holder.Slider = CreateFrame("Slider", nil, holder, "UISliderTemplate")
    holder.Slider:SetPoint("LEFT", holder, "CENTER", -32, 0)
    holder.Slider:SetPoint("RIGHT", -45, 0)
    holder.Slider:SetHeight(20)
    holder.Slider:SetMinMaxValues(min, max)
    holder.Slider:SetValueStep(1)
    holder.Slider:SetObeyStepOnDrag(true)
    holder.Slider:SetValue(TSBHCDB[savedVarKey] or defaultValue)

    holder.Slider:SetScript("OnValueChanged", function()
        local value = holder.Slider:GetValue()
        local numHistoryItems = #TSBHCDB["BrowsingHistory"]
        if value < numHistoryItems then
            local difference = numHistoryItems - value
            for i = numHistoryItems, 1, -1 do
                if difference > 0 then
                    table.remove(TSBHCDB["BrowsingHistory"], i)
                    difference = difference - 1
                end
            end
        end
        holder.ValueText:SetText(value)
        TSBHCDB[savedVarKey] = value
    end)

    function holder:GetValue()
        return holder.Slider:GetValue()
    end

    function holder:SetValue(value)
        return holder.Slider:SetValue(value)
    end

    holder:SetScript("OnMouseWheel", function(_, delta)
        if holder.Slider:IsEnabled() then
            holder.Slider:SetValue(holder.Slider:GetValue() + delta)
        end
    end)

    return holder
end

local function SlashHandler(msg)
    local cmd, rest = msg:match("^(%S*)%s*(.-)$")
    cmd = cmd:lower()

    if cmd == "" then
        if frame and frame:IsVisible() then frame:Hide(); return end
        if not frame then
            frame = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")

            frame.versionLabel = frame:CreateFontString()
            frame.versionLabel:SetFontObject(GameFontHighlight)
            frame.versionLabel:SetText(C_AddOns.GetAddOnMetadata(addonName, "Version"))
            frame.versionLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -15, -30)

            frame:SetToplevel(true)
            table.insert(UISpecialFrames, frame:GetName())
            frame:SetSize(300, 200)
            frame:SetPoint("CENTER")
            frame:Raise()

            frame:SetMovable(true)
            frame:SetClampedToScreen(true)
            frame:RegisterForDrag("LeftButton")
            frame:SetScript("OnDragStart", function()
            frame:StartMoving()
            frame:SetUserPlaced(false)
            end)
            frame:SetScript("OnDragStop", function()
            frame:StopMovingOrSizing()
            frame:SetUserPlaced(false)
            end)

            ButtonFrameTemplate_HidePortrait(frame)
            ButtonFrameTemplate_HideButtonBar(frame)
            frame.Inset:Hide()
            frame:EnableMouse(true)
            frame:SetScript("OnMouseWheel", function() end)

            frame:SetTitle(addonName)

            local maxHistoryItemsSlider = NewSlider(frame, "Max History Items", 5, 50, 30, "MAX_HISTORY_ITEMS")
            maxHistoryItemsSlider:Show()
        else
            frame:Show()
        end
    end
end

SLASH_TRADESKILLBROWSINGHISTORY1 = "/tsbh"
SlashCmdList["TRADESKILLBROWSINGHISTORY"] = SlashHandler