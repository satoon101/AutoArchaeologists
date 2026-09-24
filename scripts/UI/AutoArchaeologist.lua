-- ===========================================================================
--  Auto Archaeologist - UI Script
--  Provides Auto Archaeologist UI scripts.
-- ===========================================================================

print("=== Auto Archaeologists (UI) Loading ===")

include("AutoArchaeologist_Helpers")

MovementEnabled = false

function LoadProcessAllArchaeologists()
    local playerID = Game.GetLocalPlayer()
    ProcessAllArchaeologists(playerID)
end

function ProcessAllArchaeologists(playerID)
    local player = Players[playerID]
    if player == nil or not player:IsHuman() then
        return
    end

    MovementEnabled = true
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

function DisableMovement()
    MovementEnabled = false
end

Events.PlayerTurnDeactivated.Add(DisableMovement)

function ProcessNewArchaeologist(playerID, unitID)
    if not MovementEnabled then
        return
    end

    local player = Players[playerID]
    if player == nil or not player:IsHuman() then
        return
    end

    local unit = UnitManager.GetUnit(playerID, unitID)
    if unit == nil or unit:GetType() ~= ARCHAEOLOGIST_INDEX then
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
