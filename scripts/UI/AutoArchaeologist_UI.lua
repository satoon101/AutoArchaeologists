-- ===========================================================================
--  Auto Archaeologist - UI Script
--  Provides Auto Archaeologist UI scripts.
-- ===========================================================================

print("=== Auto Archaeologists (UI) Loading ===")

include("AutoArchaeologist_Helpers")

FinishedInitialization = false

function LoadProcessAllArchaeologists()
    FinishedInitialization = true
    ProcessAllArchaeologists()
end

function ProcessAllArchaeologists(playerID)
    if playerID == nil then
        playerID = Game.GetLocalPlayer()
    end

    local player = Players[playerID]
    if player == nil or not player:IsHuman() then
        return
    end

    local civics = player:GetCulture()
    if not civics:HasCivic(CULTURAL_HERITAGE_INDEX) then
        return
    end

    if DigLocationsByPlotID == nil then
        GetDigSiteData()
    end

    local units = player:GetUnits()
    for _, unit in units:Members() do
        if unit:GetType() == ARCHAEOLOGIST_INDEX then
            local unitID = unit:GetID()
            if DigLocationsByUnitID[unitID] ~= nil then
                local plotID = DigLocationsByUnitID[unitID]
                local plot = Map.GetPlotByIndex(plotID)
                local resourceType = plot:GetResourceType()
                if (
                    resourceType ~= ANTIQUITY_SITE_INDEX
                    and resourceType ~= SHIPWRECK_INDEX
                ) then
                    DigLocationsByPlotID[plotID] = nil
                    DigLocationsByUnitID[unitID] = nil
                end
            end

            if DigLocationsByUnitID[unitID] == nil then
                local plotID = FindClosestDigSite(playerID, unitID)
                if plotID ~= nil then
                    DigLocationsByPlotID[plotID] = unitID
                    DigLocationsByUnitID[unitID] = plotID
                end
            end

            if DigLocationsByUnitID[unitID] ~= nil then
                ProcessArchaeologist(playerID, unitID)
            end
        end
    end
end

Events.LoadGameViewStateDone.Add(LoadProcessAllArchaeologists)
Events.PlayerTurnActivated.Add(ProcessAllArchaeologists)

function ProcessNewArchaeologist(playerID, unitID)
    if not FinishedInitialization then
        return
    end

    local plotID = FindClosestDigSite(playerID, unitID)
    if plotID ~= nil then
        DigLocationsByPlotID[plotID] = unitID
        DigLocationsByUnitID[unitID] = plotID
        ProcessArchaeologist(playerID, unitID)
    end
end

Events.UnitAddedToMap.Add(ProcessNewArchaeologist)

print("=== Auto Archaeologists (UI) Loaded ===")
