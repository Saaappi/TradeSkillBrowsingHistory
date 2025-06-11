local addonName, addonTable = ...
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, loadedAddon)
    if event == "ADDON_LOADED" and loadedAddon == addonName then
        if not TSBHCDB then
            TSBHCDB = {}
            TSBHCDB["LAST_POSITION"] = 1
            TSBHCDB["LAST_RECIPE"] = 0
            TSBHCDB["BrowsingHistory"] = {}
        end
        eventFrame:UnregisterEvent(event)
    end
end)