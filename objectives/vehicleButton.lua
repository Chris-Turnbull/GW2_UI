local _, GW = ...

local size = 128

local function SetPosition(_,_,anchor)
    if anchor == "MinimapCluster" or anchor == _G.MinimapCluster then
        _G.VehicleSeatIndicator:ClearAllPoints()
        _G.VehicleSeatIndicator:SetPoint("TOPLEFT", _G.VehicleSeatIndicator.gwMover, 'TOPLEFT', 0, 0)
    end
end

local function VehicleSetUp(vehicleID)
    _G.VehicleSeatIndicator:SetSize(GW.Scale(size), GW.Scale(size))

    local _, numSeatIndicators = GetVehicleUIIndicator(vehicleID)

    if numSeatIndicators then
        local fourth = size / 4

        for i = 1, numSeatIndicators do
            local button = _G["VehicleSeatIndicatorButton" .. i]
            local buttonSize = GW.Scale(fourth)
            button:SetSize(buttonSize, buttonSize)

            local _, xOffset, yOffset = GetVehicleUIIndicatorSeat(vehicleID, i)
            button:ClearAllPoints()
            button:SetPoint("CENTER", button:GetParent(), "TOPLEFT", xOffset * size, -yOffset * size)
        end
    end
end

local function LoadVehicleButton()
    if not _G.VehicleSeatIndicator.PositionVehicleFrameHooked then
        hooksecurefunc(VehicleSeatIndicator, "SetPoint", SetPosition)
        hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", VehicleSetUp)
        GW.RegisterMovableFrame(_G.VehicleSeatIndicator, BINDING_HEADER_VEHICLE, "VEHICLE_SEAT_POS", "VerticalActionBarDummy", nil, nil, nil, true)
        _G.VehicleSeatIndicator.PositionVehicleFrameHooked = true
    end

    _G.VehicleSeatIndicator:SetSize(GW.Scale(size), GW.Scale(size))

    if _G.VehicleSeatIndicator.currSkin then
        VehicleSetUp(_G.VehicleSeatIndicator.currSkin)
    end
end
GW.LoadVehicleButton = LoadVehicleButton