local addonName, addonTable = ...
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        if not TSBHCDB then
            TSBHCDB = {}
            TSBHCDB["MAX_HISTORY_ITEMS"] = 30
            TSBHCDB["LAST_RECIPE"] = {}
            TSBHCDB["BrowsingHistory"] = {}
        end
        eventFrame:UnregisterEvent(event)
    end
end)