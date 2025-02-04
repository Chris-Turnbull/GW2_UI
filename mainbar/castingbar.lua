local _, GW = ...
local lerp = GW.lerp
local GetSetting = GW.GetSetting
local TimeCount = GW.TimeCount
local RegisterMovableFrame = GW.RegisterMovableFrame
local animations = GW.animations
local AddToAnimation = GW.AddToAnimation
local StopAnimation = GW.StopAnimation
local IsIn = GW.IsIn

-- For testing basic implementation of DRAGONFLIGHT segmented casting bar
local TEST_SEGMENT_BAR = false

local CASTINGBAR_TEXTURES = {
    YELLOW = {
        NORMAL = {
            L = 0,
            R = 0.5,
            T = 0.25,
            B = 0.50,
        },
        HIGHLIGHT = {
            L = 0,
            R = 0.5,
            T = 0.5,
            B = 0.75,
        }
    },
    RED = {
        NORMAL = {
            L = 0,
            R = 0.5,
            T = 0.75,
            B = 1,
        },
        HIGHLIGHT = {
            L = 0.5,
            R = 1,
            T = 0,
            B = 0.25,
        }
    },
    GREEN = {
        NORMAL = {
            L = 0.5,
            R = 1,
            T = 0.25,
            B = 0.50,
        },
        HIGHLIGHT = {
            L = 0.5,
            R = 1,
            T = 0.5,
            B = 0.75,
        }
    },
  }

---- DUMMY FUNCTION REMOVE LATER
local function GetCastingSegments()
    return {
        {
            p = 0.5,
            text = "I",
        },
        {
            p = 0.75,
            text = "II",
        },
        {
            p = 1,
            text = "III",
        },
    }
end


-- DRAGONFLIGHT SEGMENTBAR
local function createNewBarSegment(self)
    local segment = CreateFrame("Frame", self:GetName() .. "Segment" .. #self.segments + 1, self, "GwCastingBarSegmentSep")

    segment.rank:SetFont(UNIT_NAME_FONT, 12)
    segment.rank:SetShadowOffset(1, -1)
    self.segments[#self.segments + 1] = segment

    return segment
end

local function setCastingBarSegment(self, index, precentage, rankText)
  local segment = self.segments[index] or createNewBarSegment(self)

  segment:SetPoint("TOPLEFT", self, "TOPLEFT", self:GetWidth() * precentage, 0)
  segment.rank:SetText(rankText)
end
--


local function barValues(self, name, icon)
    self.name:SetText(name)
    self.icon:SetTexture(icon)
    self.latency:Show()
end
GW.AddForProfiling("castingbar", "barValues", barValues)

local function barReset(self)
    if animations[self.animationName] then
        animations[self.animationName].completed = true
        animations[self.animationName].duration = 0
    end
end
GW.AddForProfiling("castingbar", "barReset", barReset)

local function AddFinishAnimation(self, isStopped)
    local highlightColor = isStopped and CASTINGBAR_TEXTURES.RED.HIGHLIGHT or self.bar.barHighLightCoords
    self.animating = true
    self.highlight:SetTexCoord(highlightColor.L, highlightColor.R, highlightColor.T, highlightColor.B)
    self.highlight:Show()
    self.highlight:SetWidth(176)
    self.spark:Hide()

    if isStopped then
        self.bar:SetWidth(176)
        self.bar:SetTexCoord(CASTINGBAR_TEXTURES.RED.NORMAL.L, CASTINGBAR_TEXTURES.RED.NORMAL.R, CASTINGBAR_TEXTURES.RED.NORMAL.T, CASTINGBAR_TEXTURES.RED.NORMAL.B)
    end

    AddToAnimation(
        self.animationName .. "Complete",
        0,
        1,
        GetTime(),
        0.2,
        function()
            self.highlight:SetVertexColor(1, 1, 1, lerp(1, 0.7, animations[self.animationName .. "Complete"].progress))
        end,
        nil,
        function()
            self.animating = false
            if not self.isCasting then
                if self:GetAlpha() > 0 then
                    UIFrameFadeOut(self, 0.2, 1, 0)
                    self.highlight:Hide()
                    self.isCasting = false
                    self.isChanneling = false
                end
            end
        end
    )
end

local function castBar_OnEvent(self, event, unitID, ...)
    local spell, icon, startTime, endTime, isTradeSkill, castID, spellID
    local barTexture = CASTINGBAR_TEXTURES.YELLOW.NORMAL
    local barHighlightTexture = CASTINGBAR_TEXTURES.YELLOW.HIGHLIGHT
    if event == "PLAYER_ENTERING_WORLD" then
        local nameChannel = UnitChannelInfo(self.unit)
        local nameSpell = UnitCastingInfo(self.unit)
        if nameChannel then
            event = "UNIT_SPELLCAST_CHANNEL_START"
        elseif nameSpell then
            event = "UNIT_SPELLCAST_START"
        else
            barReset(self)
        end
    end

    if unitID ~= self.unit or not self.showCastbar then
        return
    end

    if IsIn(event, "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE", "UNIT_SPELLCAST_DELAYED") then
        if IsIn(event, "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_UPDATE") then
            spell, _, icon, startTime, endTime, isTradeSkill, _, spellID = UnitChannelInfo(self.unit)
            self.isChanneling = true
            self.isCasting = false
            barTexture = CASTINGBAR_TEXTURES.GREEN.NORMAL
            barHighlightTexture = CASTINGBAR_TEXTURES.GREEN.HIGHLIGHT
            self.bar:SetTexCoord(barTexture.L, barTexture.R, barTexture.T, barTexture.B)

        else
            spell, _, icon, startTime, endTime, isTradeSkill, castID, _, spellID = UnitCastingInfo(self.unit)
            self.bar:SetTexCoord(barTexture.L, barTexture.R, barTexture.T, barTexture.B)
            self.isChanneling = false
            self.isCasting = true
        end

        if TEST_SEGMENT_BAR then
            self.castSegmentData = GetCastingSegments()
            for k, v in pairs(self.castSegmentData) do
                setCastingBarSegment(self, k, v.p, v.text)
            end
        end

        self.bar.barCoords = barTexture
        self.bar.barHighLightCoords = barHighlightTexture

        if not spell or (not self.showTradeSkills and isTradeSkill) then
            barReset(self)
            return
        end

        if self.showDetails then
            barValues(self, spell, icon)
        end

        self.spellID = spellID
        self.castID = castID
        self.startTime = startTime / 1000
        self.endTime = endTime / 1000
        barReset(self)
        self.spark:Show()
        self.highlight:Hide()
        StopAnimation(self.animationName)
        AddToAnimation(
            self.animationName,
            0,
            1,
            self.startTime,
            self.endTime - self.startTime,
            function()
                if self.showDetails then
                    self.time:SetText(TimeCount(self.endTime - GetTime(), true))
                end

                local p = self.isChanneling and (1 - animations[self.animationName].progress) or animations[self.animationName].progress
                self.latency:ClearAllPoints()
                self.latency:SetPoint(self.isChanneling and "LEFT" or "RIGHT", self, self.isChanneling and "LEFT" or "RIGHT")

                self.bar:SetWidth(math.max(1, p * 176))
                self.bar:SetVertexColor(1,1,1,1)
                self.spark:SetWidth(math.min(15, math.max(1, p * 176)))
                self.bar:SetTexCoord(self.bar.barCoords.L, lerp(self.bar.barCoords.L,self.bar.barCoords.R, p), self.bar.barCoords.T, self.bar.barCoords.B)

                if TEST_SEGMENT_BAR then
                    if self.castSegmentData then
                        for _, v in pairs(self.castSegmentData) do

                        if v.p <= p then
                            self.highlight:SetTexCoord(self.bar.barHighLightCoords.L, lerp(self.bar.barHighLightCoords.L, self.bar.barHighLightCoords.R, v.p), self.bar.barHighLightCoords.T, self.bar.barHighLightCoords.B)
                            self.highlight:SetWidth(math.max(1, v.p * 176))
                            self.highlight:Show()
                        end

                        end
                    end
                end

                local lagWorld = select(4, GetNetStats()) / 1000
                lagWorld = math.max(lagWorld, 1 * GetCVar("SpellQueueWindow") / 1000)
                local sqw = GetSetting("PLAYER_CASTBAR_SHOW_SPELL_QUEUEWINDOW") and (tonumber(GetCVar("SpellQueueWindow")) or 0) / 1000 or 0
                self.latency:SetWidth(math.max(0.0001, math.min(1, ((sqw + lagWorld) / (self.endTime - self.startTime)))) * 176)
            end,
            "noease"
        )

        if self:GetAlpha() < 1 then
            UIFrameFadeIn(self, 0.1, 0, 1)
        end
    elseif IsIn(event, "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_STOP") then
        if (event == "UNIT_SPELLCAST_STOP" and self.castID == select(1, ...)) or (event == "UNIT_SPELLCAST_CHANNEL_STOP" and self.isChanneling) then
            if self.animating == nil or self.animating == false then
                UIFrameFadeOut(self, 0.2, 1, 0)
            end
            barReset(self)
            self.isCasting = false
            self.isChanneling = false
        end
    elseif event == "UNIT_SPELLCAST_INTERRUPTED" or event == "UNIT_SPELLCAST_FAILED" then
        if self:IsShown() and self.isCasting and select(1, ...) == self.castID then
            if self.showDetails then
                if event == "UNIT_SPELLCAST_FAILED" then
                    self.name:SetText(FAILED)
                else
                    self.name:SetText(INTERRUPTED)
                end
            end
            AddFinishAnimation(self, true)
            self.isCasting = false
            self.isChanneling = false
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and self.spellID == select(2, ...) and not self.isChanneling then
        AddFinishAnimation(self, false)
    end
end

local function petCastBar_OnEvent(self, event, unit, ...)
    if event == "UNIT_PET" then
        if unit == "player" then
            self.showCastbar = UnitIsPossessed("pet")
        end
        return
    end
    castBar_OnEvent(self, event, unit, ...)
end

local function TogglePlayerEnhancedCastbar(self, setShown)
    self.name:SetShown(setShown)
    self.icon:SetShown(setShown)
    self.latency:SetShown(setShown)
    self.time:SetShown(setShown)

    self.showDetails = setShown
end
GW.TogglePlayerEnhancedCastbar = TogglePlayerEnhancedCastbar

local function LoadCastingBar(castingBarType, name, unit, showTradeSkills)
    castingBarType:Kill()

    local GwCastingBar = CreateFrame("Frame", name, UIParent, "GwCastingBar")
    GwCastingBar.name:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.name:SetShadowOffset(1, -1)
    GwCastingBar.time:SetFont(UNIT_NAME_FONT, 12)
    GwCastingBar.time:SetShadowOffset(1, -1)

    GwCastingBar:SetAlpha(0)

    GwCastingBar.unit = unit
    GwCastingBar.showCastbar = true
    GwCastingBar.spellID = nil
    GwCastingBar.isChanneling = false
    GwCastingBar.isCasting = false
    GwCastingBar.animationName = name
    GwCastingBar.showTradeSkills = showTradeSkills
    GwCastingBar.showDetails = GetSetting("CASTINGBAR_DATA")

    GwCastingBar.segments = {}

    TogglePlayerEnhancedCastbar(GwCastingBar, GwCastingBar.showDetails)

    if name == "GwCastingBarPlayer" then
        RegisterMovableFrame(GwCastingBar, SHOW_ARENA_ENEMY_CASTBAR_TEXT, "castingbar_pos", "GwCastFrameDummy", nil, {"default", "scaleable"})
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBar.gwMover)
    else
        GwCastingBar:ClearAllPoints()
        GwCastingBar:SetPoint("TOPLEFT", GwCastingBarPlayer.gwMover, "TOPLEFT", 0, 35)
    end

    GwCastingBar:SetScript("OnEvent", unit == "pet" and petCastBar_OnEvent or castBar_OnEvent)

    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    GwCastingBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    GwCastingBar:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    if unit == "pet" then
        GwCastingBar:RegisterEvent("UNIT_PET")
        GwCastingBar.showCastbar = UnitIsPossessed(unit)
    end
end
GW.LoadCastingBar = LoadCastingBar
