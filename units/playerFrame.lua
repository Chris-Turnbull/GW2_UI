local _, GW = ...
local GetSetting = GW.GetSetting
local RegisterMovableFrame = GW.RegisterMovableFrame
local AddToAnimation = GW.AddToAnimation
local AddToClique = GW.AddToClique
local createNormalUnitFrame = GW.createNormalUnitFrame
local IsIn = GW.IsIn
local CommaValue = GW.CommaValue
local Diff = GW.Diff

local function updateHealthTextString(self, health, healthPrecentage)
    local healthString = ""

    if self.healthTextSetting == "PREC" then
        healthString = CommaValue(healthPrecentage * 100) .. "%"
    elseif self.healthTextSetting == "VALUE" then
        healthString = CommaValue(health)
    elseif self.healthTextSetting == "BOTH" then
        healthString = CommaValue(health) .. " - " .. CommaValue(healthPrecentage * 100) .. "%"
    end

    self.healthString:SetText(healthString)
end
GW.AddForProfiling("unitframes", "updateHealthTextString", updateHealthTextString)

local function updateHealthData(self)
    local health = UnitHealth(self.unit)
    local healthMax = UnitHealthMax(self.unit)
    local absorb = UnitGetTotalAbsorbs(self.unit)
    local prediction = UnitGetIncomingHeals(self.unit) or 0
    local healthPrecentage = 0
    local absorbPrecentage = 0
    local predictionPrecentage = 0

    if health > 0 and healthMax > 0 then
        healthPrecentage = health / healthMax
    end

    if absorb > 0 and healthMax > 0 then
        absorbPrecentage = absorb / healthMax
    end

    if prediction > 0 and healthMax > 0 then
        predictionPrecentage = prediction / healthMax
    end

    local animationSpeed = math.min(1, math.max(0.2, 2 * Diff(self.healthValue, healthPrecentage)))

    -- absorb calc got inlined here because nothing else uses this
    local absbarbg = self.absorbbarbg
    local absbar = self.absorbbar
    if absorb == 0 then
        -- very common case; short-circuit this for performance
        absbarbg:SetAlpha(0)
        absbar:SetAlpha(0)
    else
        local absorbAmount = healthPrecentage + absorbPrecentage
        local absorbAmount2 = absorbPrecentage - (1 - healthPrecentage)

        absbarbg:SetWidth(math.min((self.barWidth - 1), math.max(1, self.barWidth * absorbAmount)))
        absbar:SetWidth(math.min(self.barWidth, math.max(1, self.barWidth * absorbAmount2)))

        absbarbg:SetTexCoord(0, math.min(1, 1 * absorbAmount), 0, 1)
        absbar:SetTexCoord(0, math.min(1, 1 * absorbAmount), 0, 1)

        absbarbg:SetAlpha(math.max(0, math.min(1, (1 * (absorbPrecentage / 0.1)))))
        absbar:SetAlpha(math.max(0, math.min(1, (1 * (absorbPrecentage / 0.1)))))
    end

    --prediction calc
    local predictionbar = self.predictionbar
    if prediction == 0 then
        predictionbar:SetAlpha(0)
    else
        local predictionAmount = healthPrecentage + predictionPrecentage

        predictionbar:SetWidth(math.min(self.barWidth, math.max(1, self.barWidth * predictionAmount)))
        predictionbar:SetTexCoord(0, math.min(1, 1 * predictionAmount), 0, 1)
        predictionbar:SetAlpha(math.max(0, math.min(1, (1 * (predictionPrecentage / 0.1)))))
    end

    GW.healthBarAnimation(self, healthPrecentage, true)
    if animationSpeed == 0 then
        GW.healthBarAnimation(self, healthPrecentage)
        updateHealthTextString(self, health, healthPrecentage)
    else
        self.healthValueStepCount = 0
        AddToAnimation(
            self:GetName() .. self.unit,
            self.healthValue,
            healthPrecentage,
            GetTime(),
            animationSpeed,
            function(step)
                GW.healthBarAnimation(self, step)

                local hvsc = self.healthValueStepCount
                if hvsc % 5 == 0 then
                    updateHealthTextString(self, healthMax * step, step)
                end
                self.healthValueStepCount = hvsc + 1
                self.healthValue = step
            end,
            nil,
            function()
                updateHealthTextString(self, health, healthPrecentage)
            end
        )
    end
end

local function unitFrameData(self)
    local level = UnitLevel(self.unit)
    local name = UnitName(self.unit)

    if UnitIsGroupLeader(self.unit) then
        name = "|TInterface/AddOns/GW2_UI/textures/party/icon-groupleader:18:18|t" .. name
    end

    self.nameString:SetText(name)
    self.levelString:SetText(level)

    if self.classColor then
        local _, englishClass = UnitClass(self.unit)
        local color = GW.GWGetClassColor(englishClass, true)

        self.healthbar:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarSpark:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarFlash:SetVertexColor(color.r, color.g, color.b, color.a)
        self.healthbarFlashSpark:SetVertexColor(color.r, color.g, color.b, color.a)

        self.nameString:SetTextColor(color.r + 0.3, color.g + 0.3, color.b + 0.3, color.a)
    else
        self.healthbar:SetVertexColor(0.207, 0.392, 0.16, 1)
        self.healthbarSpark:SetVertexColor(0.207, 0.392, 0.16, 1)
        self.healthbarFlash:SetVertexColor(0.207, 0.392, 0.16, 1)
        self.healthbarFlashSpark:SetVertexColor(0.207, 0.392, 0.16, 1)
        self.nameString:SetTextColor(0.207, 0.392, 0.16, 1)
    end

    SetPortraitTexture(self.portrait, self.unit)
end

local function player_OnEvent(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        unitFrameData(self)
        updateHealthData(self)
        GW.updatePowerValues(self, false)
    elseif IsIn(event, "PLAYER_LEVEL_UP", "GROUP_ROSTER_UPDATE", "UNIT_PORTRAIT_UPDATE") then
        unitFrameData(self)
    elseif IsIn(event, "UNIT_HEALTH", "UNIT_MAXHEALTH", "UNIT_ABSORB_AMOUNT_CHANGED", "UNIT_HEAL_PREDICTION") then
        updateHealthData(self)
    elseif IsIn(event, "UNIT_MAXPOWER", "UNIT_POWER_FREQUENT", "UPDATE_SHAPESHIFT_FORM", "ACTIVE_TALENT_GROUP_CHANGED") then
        GW.updatePowerValues(self, false)
    elseif IsIn(event, "WAR_MODE_STATUS_UPDATE", "PLAYER_FLAGS_CHANGED", "UNIT_FACTION") then
        GW.PlayerSelectPvp(self)
    elseif event == "RESURRECT_REQUEST" then
        PlaySound(SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER, "Master")
    end
end

local function TogglePlayerFrameASettings()
    if not GwPlayerUnitFrame then return end
    GwPlayerUnitFrame.altBg:SetShown(GetSetting("PLAYER_AS_TARGET_FRAME_ALT_BACKGROUND"))
    GwPlayerUnitFrame.classColor = GetSetting("player_CLASS_COLOR")
    GwPlayerUnitFrame.healthTextSetting = GetSetting("PLAYER_UNIT_HEALTH")

    updateHealthData(GwPlayerUnitFrame)
    unitFrameData(GwPlayerUnitFrame)
end
GW.TogglePlayerFrameASettings = TogglePlayerFrameASettings

local function LoadPlayerFrame()
    local NewUnitFrame = createNormalUnitFrame("GwPlayerUnitFrame")
    NewUnitFrame.unit = "player"
    NewUnitFrame.type = "NormalTarget"

    RegisterMovableFrame(NewUnitFrame, PLAYER, "player_pos", "GwTargetFrameTemplateDummy", nil, {"default", "scaleable"})

    NewUnitFrame:ClearAllPoints()
    NewUnitFrame:SetPoint("TOPLEFT", NewUnitFrame.gwMover)

    NewUnitFrame:SetAttribute("*type1", "target")
    NewUnitFrame:SetAttribute("*type2", "togglemenu")
    NewUnitFrame:SetAttribute("unit", "player")
    RegisterUnitWatch(NewUnitFrame)
    NewUnitFrame:EnableMouse(true)
    NewUnitFrame:RegisterForClicks("AnyDown")

    NewUnitFrame.altBg = CreateFrame("Frame", nil, NewUnitFrame, "GwAlternativeUnitFrameBackground")

    NewUnitFrame.mask = UIParent:CreateMaskTexture()
    NewUnitFrame.mask:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)

    NewUnitFrame.mask:SetTexture(186178, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    NewUnitFrame.mask:SetSize(58, 58)
    NewUnitFrame.portrait:AddMaskTexture(NewUnitFrame.mask)

    AddToClique(NewUnitFrame)

    -- add pvp marker
    NewUnitFrame.pvp = CreateFrame("Frame", nil, NewUnitFrame)
    NewUnitFrame.pvp:SetSize(128, 128)
    NewUnitFrame.pvp:SetFrameLevel(2)
    NewUnitFrame.pvp:SetAlpha(0.44)
    NewUnitFrame.pvp:SetFrameStrata("BACKGROUND")
    NewUnitFrame.pvp:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 0)
    NewUnitFrame.pvp.ally = NewUnitFrame.pvp:CreateTexture(nil, "BACKGROUND")
    NewUnitFrame.pvp.ally:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    NewUnitFrame.pvp.ally:SetSize(72, 68)
    NewUnitFrame.pvp.ally:SetTexCoord(0, 1, 0, 0.5)
    NewUnitFrame.pvp.ally:SetPoint("CENTER", NewUnitFrame.pvp, "CENTER", 0, 5)
    NewUnitFrame.pvp.ally:Hide()

    NewUnitFrame.pvp.horde = NewUnitFrame.pvp:CreateTexture(nil, "BACKGROUND")
    NewUnitFrame.pvp.horde:SetTexture("Interface/AddOns/GW2_UI/textures/globe/pvpmode")
    NewUnitFrame.pvp.horde:SetSize(78, 78)
    NewUnitFrame.pvp.horde:SetTexCoord(0, 1, 0.51, 1)
    NewUnitFrame.pvp.horde:SetPoint("CENTER", NewUnitFrame.portrait, "CENTER", 0, 5)
    NewUnitFrame.pvp.horde:Hide()

    NewUnitFrame:SetScript("OnEvent", player_OnEvent)

    NewUnitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    NewUnitFrame:RegisterEvent("WAR_MODE_STATUS_UPDATE")
    NewUnitFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
    NewUnitFrame:RegisterEvent("RESURRECT_REQUEST")
    NewUnitFrame:RegisterEvent("PLAYER_LEVEL_UP")
    NewUnitFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    NewUnitFrame:RegisterEvent("UNIT_PORTRAIT_UPDATE")
    NewUnitFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    NewUnitFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NewUnitFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_FACTION", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    NewUnitFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
    NewUnitFrame:SetScript("OnEnter", GW.PlayerFrame_OnEnter)
    NewUnitFrame:SetScript("OnLeave", function(self)
        GameTooltip_Hide()
        if self.pvp.pvpFlag then
            self.pvp:fadeOut()
        end
    end)

    -- grab the TotemFramebuttons to our own Totem Frame
    if PlayerFrame and TotemFrame then
        GW.Create_Totem_Bar()
    end

    -- setup anim to flash the PvP marker
    local pvp = NewUnitFrame.pvp
    local pagIn = pvp:CreateAnimationGroup("fadeIn")
    local pagOut = pvp:CreateAnimationGroup("fadeOut")
    local fadeOut = pagOut:CreateAnimation("Alpha")
    local fadeIn = pagIn:CreateAnimation("Alpha")

    pagOut:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(0.33)
    end)

    fadeOut:SetFromAlpha(1.0)
    fadeOut:SetToAlpha(0.33)
    fadeOut:SetDuration(0.1)
    fadeIn:SetFromAlpha(0.33)
    fadeIn:SetToAlpha(1.0)
    fadeIn:SetDuration(0.1)

    pvp.fadeOut = function()
        pagIn:Stop()
        pagOut:Stop()
        pagOut:Play()
    end
    pvp.fadeIn = function(self)
        self:SetAlpha(1)
        pagIn:Stop()
        pagOut:Stop()
        pagIn:Play()
    end

    if not GetSetting("PLAYER_SHOW_PVP_INDICATOR") then pvp:Hide() end

    PlayerFrame:Kill()

    --hide unsed things from default target frame
    NewUnitFrame.castingbarBackground:Hide()
    NewUnitFrame.castingString:Hide()
    NewUnitFrame.castingTimeString:Hide()
    NewUnitFrame.castingbar:Hide()
    NewUnitFrame.castingbarSpark:Hide()
    NewUnitFrame.castingbarNormal:Hide()
    NewUnitFrame.castingbarNormalSpark:Hide()
    NewUnitFrame.raidmarker:Hide()
    NewUnitFrame.prestigebg:Hide()
    NewUnitFrame.prestigeString:Hide()

    TogglePlayerFrameASettings()

    return NewUnitFrame
end
GW.LoadPlayerFrame = LoadPlayerFrame