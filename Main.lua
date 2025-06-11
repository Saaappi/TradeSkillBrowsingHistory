local addonTable = select(2, ...)
local maxHistoryEntries = 30
local selectedRecipeID = 1
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
    TSBHCDB.LAST_POSITION = #TSBHCDB.BrowsingHistory
end

-- Helper: Create or refresh the dropdown menu
local function UpdateOrCreateDropdown()
    if not dropdown then
        dropdown = CreateFrame("DropdownButton", "TradeskillBrowsingHistoryDropdown", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "WowStyle1DropdownTemplate")
        dropdown:EnableMouseWheel(true)
        dropdown:SetWidth(180)
        dropdown:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "TOPRIGHT", 0, 12)
        MenuUtil.HookTooltipScripts(dropdown, function()
            GameTooltip:SetText("TradeSkill Browsing History")
            GameTooltip:AddLine("Select entries from your browsing history to quickly return to previously browsed recipes.", 1, 1, 1, 1, true)
        end)
    end

    MenuUtil.CreateRadioMenu(dropdown, addonTable.IsSelected, addonTable.SetSelected, unpack(TSBHCDB["BrowsingHistory"]))
    dropdown:Show()
end

-- Update browsing history when recipe is selected
local function UpdateBrowsingHistory(recipe)
    if recipe.recipeID == TSBHCDB.LAST_RECIPE then return end

    TSBHCDB.LAST_RECIPE = recipe.recipeID

    if not IsRecipeInHistory(recipe.recipeID) then
        if #TSBHCDB["BrowsingHistory"] >= maxHistoryEntries then
            table.remove(TSBHCDB["BrowsingHistory"])
        end

        table.insert(TSBHCDB["BrowsingHistory"], 1, {
            date("%H:%M:%S") .. " |T" .. recipe.icon .. ":0|t " .. recipe.name,
            recipe.recipeID
        })
    end

    UpdateOrCreateDropdown()
    addonTable.SetSelected(recipe.recipeID)
end

-- Register a callback for the TradeSkill frame OnShow
EventRegistry:RegisterCallback("ProfessionsFrame.Show", function()
    UpdateOrCreateDropdown()

    if next(TSBHCDB.BrowsingHistory) then
        for _, entry in ipairs(TSBHCDB.BrowsingHistory) do
            if entry[2] == TSBHCDB.LAST_RECIPE then
                addonTable.SetSelected(TSBHCDB.LAST_RECIPE)
                break
            end
        end
    end

    if TSBHCDB.LAST_RECIPE and TSBHCDB.LAST_RECIPE ~= 0 then
        C_TradeSkillUI.OpenRecipe(TSBHCDB.LAST_RECIPE)
    end
end)

-- Watch for recipe selection
EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", function(_, recipe)
    UpdateBrowsingHistory(recipe)
end)