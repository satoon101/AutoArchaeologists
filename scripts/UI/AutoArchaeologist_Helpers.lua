include("AutoAutoArchaeologist_Constants")

DigLocationsByPlotID = nil
DigLocationsByUnitID = {}

function GetDigSiteData()
    DigLocationsByPlotID = {}
    local iW, iH = Map.GetGridSize()
    for x = 0, iW - 1 do
        for y = 0, iH - 1 do
            local plot = Map.GetPlot(x, y)
            local resourceType = plot:GetResourceType()
            if (
                resourceType == ANTIQUITY_SITE_INDEX
                or resourceType == SHIPWRECK_INDEX
            ) then
                DigLocationsByPlotID[plot:GetIndex()] = false
            end
        end
    end
end

function FindClosestDigSite(playerID, unitID)
    local unit = UnitManager.GetUnit(playerID, unitID)
    local x = unit:GetX()
    local y = unit:GetY()
    local closestPlotID = nil
    local closestDistance = nil
    for plotID, value in pairs(DigLocationsByPlotID) do
        if value == false then
            local plot = Map.GetPlotByIndex(plotID)
            local x2 = plot:GetX()
            local y2 = plot:GetY()
            local distance = Map.GetPlotDistance(x, y, x2, y2)
            if (
                closestPlotID == nil or
                distance < closestDistance
            ) then
                closestPlotID = plotID
                closestDistance = distance
            end
        end
    end

    return closestPlotID
end

function ProcessArchaeologist(playerID, unitID)
    local plotID = DigLocationsByUnitID[unitID]
    local plot = Map.GetPlotByIndex(plotID)
    local unit = UnitManager.GetUnit(playerID, unitID)
    local params = {
        [UnitOperationTypes.PARAM_X] = plot:GetX(),
        [UnitOperationTypes.PARAM_Y] = plot:GetY(),
    }
    UnitManager.RequestOperation(unit, UnitOperationTypes.MOVE_TO, params)
    UnitManager.RequestOperation(unit, UnitOperationTypes.EXCAVATE, {})
end

print("=== Auto AutoArchaeologists (Helpers) Loaded ===")
