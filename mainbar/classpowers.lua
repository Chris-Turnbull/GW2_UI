local _, GW = ...
local AddToAnimation = GW.AddToAnimation
local animations = GW.animations

local MAX_COMBO_POINTS = 5

local function animFlare(f, scale, offset, duration, rotate)
    scale = scale or 32
    offset = offset or 0
    duration = duration or 0.5
    rotate = rotate or false
    local ff = f.flare
    local pwr = f.gwPower
    ff:ClearAllPoints()
    ff:SetPoint("CENTER", f, "LEFT", (scale * pwr) + offset, 0)
    AddToAnimation(
        "POWER_FLARE_ANIM",
        1,
        0,
        GetTime(),
        duration,
        function()
            local p = animations["POWER_FLARE_ANIM"]["progress"]
            ff:SetAlpha(p)
            if rotate then
                ff:SetRotation(1 * p)
            end
        end
    )
end

local function powerCombo(self, event, ...)
    local pType = select(2, ...)
    if event ~= "CLASS_POWER_INIT" and pType ~= "COMBO_POINTS" then
        return
    end

    local old_power = self.gwPower
    old_power = old_power or -1

    local pwr = GetComboPoints("player", "target")
    local p = pwr - 1

    self.gwPower = pwr

    self.background:SetTexCoord(0, 1, 0.125 * (MAX_COMBO_POINTS - 1), 0.125 * MAX_COMBO_POINTS)
    self.fill:SetTexCoord(0, 1, 0.125 * p, 0.125 * (p + 1))

    if old_power < pwr and event ~= "CLASS_POWER_INIT" then
        animFlare(self, 40)
    end
end

local function setComboBar(f)
    f:SetHeight(40)
    f:SetWidth(320)
    f.background:SetHeight(32)
    f.background:SetWidth(256)
    f.background:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-bg")
    f.background:SetTexCoord(0, 1, 0.5, 1)
    f.flare:SetWidth(128)
    f.flare:SetHeight(128)
    f.flare:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo-flash")
    f.fill:SetHeight(40)
    f.fill:SetWidth(320)
    f.fill:SetTexture("Interface\\AddOns\\GW2_UI\\textures\\altpower\\combo")

    f:SetScript("OnEvent", powerCombo)
    powerCombo(f, "CLASS_POWER_INIT")
    f:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    f:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
end

local function setRogue(f)
    setComboBar(f)
    return true
end

-- DRUID
local function setDruid(f)
    local form = f.gwPlayerForm
    local barType = "none"

    if form == 3 then
        barType = "combo"
    end

    if barType == "combo" then
        setComboBar(f)
        return true
    else
        return false
    end
end
GW.AddForProfiling("classpowers", "setDruid", setDruid)

local function selectType(f)
    f:SetScript("OnEvent", nil)
    f:UnregisterAllEvents()

    local pClass = f.gwPlayerClass

    f.gwPower = -1
    local showBar = false

    if pClass == 4 then
        showBar = setRogue(f)
    elseif pClass == 11 then
        showBar = setDruid(f)
    end
    if showBar then
        f:Show()
    else
        f:Hide()
    end
end

local function barChange_OnEvent(self, event, ...)
    local f = self:GetParent()
    if event == "UPDATE_SHAPESHIFT_FORM" then
        -- this event fires often when form hasn't changed; check old form against current form
        -- to prevent touching the bar unnecessarily (which causes annoying anim flickering)
        local s = nil
        for i = 1, GetNumShapeshiftForms() do
            local _, isActive = GetShapeshiftFormInfo(i)
            if isActive then
                s = i
            end
        end
        if f.gwPlayerForm == s then
            return
        end
        f.gwPlayerForm = s
        selectType(f)
    end
end

local function LoadClassPowers()
    local _, _, pClass = UnitClass("player")

    local cpf = CreateFrame("Frame", "GwPlayerClassPower", UIParent, "GwPlayerClassPower")
    ComboFrame:SetScript("OnShow", function() ComboFrame:Hide() end)

    cpf.gwPlayerClass = pClass

    for i = 1, GetNumShapeshiftForms() do
        local _, isActive = GetShapeshiftFormInfo(i)
        if isActive then
            cpf.gwPlayerForm = i
        end
    end

    cpf.decay:SetScript("OnEvent", barChange_OnEvent)
    cpf.decay:RegisterEvent("PLAYER_ENTERING_WORLD")
    cpf.decay:RegisterEvent("CHARACTER_POINTS_CHANGED")
    cpf.decay:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

    selectType(cpf)
end
GW.LoadClassPowers = LoadClassPowers