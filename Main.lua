local addonTable = select(2, ...)
local eventFrame = CreateFrame("Frame")
local selectedRecipeID = 1
local locale = GetLocale()
local isInitialOpen = false
local font = CreateFont("TSBHDropdownFont")
local dropdown

-- Helper: check if recipe is already in the history
local function IsRecipeInHistory(recipeID)
    for _, entry in ipairs(TSBHCDB["BrowsingHistory"]) do
        if entry[2] == recipeID then return true end
    end
    return false
end

-- Helper: Get display text by the recipe ID
local function GetRecipeHistoryByID(recipeID)
    for _, entry in ipairs(TSBHCDB["BrowsingHistory"]) do
        if entry[2] == recipeID then return entry[1] end
    end
    return nil
end

-- Selection logic
function addonTable.IsSelected(value)
    return value == selectedRecipeID
end

function addonTable.SetSelected(value)
    selectedRecipeID = value
    local text = GetRecipeHistoryByID(selectedRecipeID)
    if text then dropdown:SetText(text) end
    dropdown:SetShown(true)

    C_TradeSkillUI.OpenRecipe(selectedRecipeID)
end

-- Helper: Create or refresh the dropdown menu
local function UpdateOrCreateDropdown()
    font:SetFont("Interface\\AddOns\\TradeSkillBrowsingHistory\\Fonts\\" .. TSBHDB["FONT"] .. ".ttf", TSBHDB["FONT_SIZE"], "")

    if not dropdown then
        dropdown = CreateFrame("DropdownButton", "TradeskillBrowsingHistoryDropdown", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "WowStyle1DropdownTemplate")
        dropdown.Text:SetFontObject(font)
        dropdown:EnableMouseWheel(true)
        dropdown:SetWidth(180)
        dropdown:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "TOPRIGHT", 0, 12)
        MenuUtil.HookTooltipScripts(dropdown, function()
            GameTooltip:SetText("TradeSkill Browsing History")
            GameTooltip:AddLine(addonTable.L[locale], 1, 1, 1, 1, true)
        end)
    end

    dropdown:SetupMenu(function(_, rootDescription)
        for _, recipe in ipairs(TSBHCDB["BrowsingHistory"]) do
            local radio = rootDescription:CreateRadio(recipe[1], addonTable.IsSelected, addonTable.SetSelected, recipe[2])
            radio:AddInitializer(function(button, description, menu)
                button.fontString:SetFontObject(font)
            end)
        end
    end)

    dropdown:Show()
end

-- Update browsing history when recipe is selected
local function UpdateBrowsingHistory(recipe)
    if recipe.recipeID == TSBHCDB["LAST_RECIPE"][addonTable.professionID] then return end

    if not IsRecipeInHistory(recipe.recipeID) then
        if #TSBHCDB["BrowsingHistory"] >= TSBHCDB["MAX_HISTORY_ITEMS"] then
            table.remove(TSBHCDB["BrowsingHistory"])
        end

        table.insert(TSBHCDB["BrowsingHistory"], 1, {
            date("%H:%M:%S") .. "  |T" .. recipe.icon .. ":0|t " .. recipe.name,
            recipe.recipeID
        })
    end

    UpdateOrCreateDropdown()
    addonTable.SetSelected(recipe.recipeID)

    TSBHCDB["LAST_RECIPE"][addonTable.professionID] = recipe.recipeID
end

-- Watch for recipe selection
EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", function(_, recipe)
    if isInitialOpen then
        isInitialOpen = false
        return
    end

    C_Timer.After(0.2, function()
        local info = ProfessionsFrame.GetProfessionInfo()
        if info then
            addonTable.professionID = info.parentProfessionID
            UpdateBrowsingHistory(recipe)
        end
    end)
end)

-- This is necessary because the ProfessionsFrame.Show event doesn't
-- fire on every show, only the first one.
eventFrame:RegisterEvent("TRADE_SKILL_SHOW")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "TRADE_SKILL_SHOW" then
        UpdateOrCreateDropdown()

        isInitialOpen = true

        C_Timer.After(0.2, function()
            local info = ProfessionsFrame.GetProfessionInfo()
            if info then
                addonTable.professionID = info.parentProfessionID
                if next(TSBHCDB.BrowsingHistory) then
                    for _, entry in ipairs(TSBHCDB.BrowsingHistory) do
                        if entry[2] == TSBHCDB["LAST_RECIPE"][addonTable.professionID] then
                            addonTable.SetSelected(TSBHCDB["LAST_RECIPE"][addonTable.professionID])
                            break
                        end
                    end
                end

                if TSBHCDB["LAST_RECIPE"][addonTable.professionID] and TSBHCDB["LAST_RECIPE"][addonTable.professionID] ~= 0 then
                    C_TradeSkillUI.OpenRecipe(TSBHCDB["LAST_RECIPE"][addonTable.professionID])
                end
            end
        end)
    end
end)