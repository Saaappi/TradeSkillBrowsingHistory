local addonTable = select(2, ...)
local maxEntries = 30
local dropdown

local function IsRecipeInHistory(recipeID)
    for _, recipe in ipairs(TSBHCDB["BrowsingHistory"]) do
        if recipe[2] == recipeID then
            return true
        end
    end
    return false
end

local function GetRecipeHistoryTextByID(recipeID)
    for _, recipe in ipairs(TSBHCDB["BrowsingHistory"]) do
        if recipe[2] == recipeID then
            return recipe[1]
        end
    end
    return nil
end

do
    local selectedValue = 1

    function addonTable.IsSelected(value)
        return value == selectedValue
    end

    function addonTable.SetSelected(value)
        selectedValue = value
        local text = GetRecipeHistoryTextByID(value)
        if text then
            dropdown:SetText(text)
        end
        dropdown:SetShown(value)
        C_TradeSkillUI.OpenRecipe(value)
        TSBHCDB["LAST_POSITION"] = #TSBHCDB.BrowsingHistory
    end

    EventRegistry:RegisterCallback("ProfessionsFrame.Show", function()
        if not dropdown then
            dropdown = CreateFrame("DropdownButton", "TradeskillBrowsingHistoryDropdown", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "WowStyle1DropdownTemplate")
            MenuUtil.HookTooltipScripts(dropdown, function()
                GameTooltip:SetText("TradeSkill Browsing History")
                GameTooltip:AddLine("Select entries from your browsing history to quickly return to previously browsed recipes.", 1, 1, 1, 1, true)
            end)

            dropdown:EnableMouseWheel(true)
            dropdown:SetWidth(180)
            dropdown:SetPoint("BOTTOMRIGHT", ProfessionsFrame.CraftingPage.RecipeList.FilterDropdown, "TOPRIGHT", 0, 12)
            dropdown:Show()
        end

        if next(TSBHCDB["BrowsingHistory"]) then
            for _, recipe in ipairs(TSBHCDB["BrowsingHistory"]) do
                if recipe[2] == TSBHCDB["LAST_RECIPE"] then
                    addonTable.SetSelected(TSBHCDB["LAST_RECIPE"])
                    break
                end
            end
        end

        MenuUtil.CreateRadioMenu(dropdown, addonTable.IsSelected, addonTable.SetSelected, unpack(TSBHCDB["BrowsingHistory"]))
        dropdown:Show()

        -- If the player has a last recipe recorded, then open
        -- that recipe when the tradeskill window is opened
        if TSBHCDB["LAST_RECIPE"] and TSBHCDB["LAST_RECIPE"] ~= 0 then
            C_TradeSkillUI.OpenRecipe(TSBHCDB["LAST_RECIPE"])
        end
    end)
end

EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", function(_, recipe)
    if recipe.recipeID ~= TSBHCDB["LAST_RECIPE"] then
        TSBHCDB["LAST_RECIPE"] = recipe.recipeID
        if not IsRecipeInHistory(recipe.recipeID) then
            local numEntries = #TSBHCDB["BrowsingHistory"]
            if (numEntries + 1) > maxEntries then
                table.remove(TSBHCDB["BrowsingHistory"], numEntries)
            end
            table.insert(TSBHCDB["BrowsingHistory"], 1, {
                date("%H:%M:%S") .. " |T" .. recipe.icon .. ":0|t " .. recipe.name,
                recipe.recipeID
            })
        end
        MenuUtil.CreateRadioMenu(dropdown, addonTable.IsSelected, addonTable.SetSelected, unpack(TSBHCDB["BrowsingHistory"]))
        addonTable.SetSelected(recipe.recipeID)
    end
end)