local _, GW = ...
local SetClassIcon = GW.SetClassIcon
local UpdatePvPTab = GW.UpdatePvPTab
local CreatePvPTab = GW.CreatePvPTab
local IsIn = GW.IsIn

local maxTalentRows = 7
local talentsPerRow = 3

local TAXIROUTE_LINEFACTOR = 32 / 30 -- Multiplying factor for texture coordinates
local TAXIROUTE_LINEFACTOR_2 = TAXIROUTE_LINEFACTOR / 2 -- Half o that

-- T        - Texture
-- C        - Canvas Frame (for anchoring)
-- sx,sy    - Coordinate of start of line
-- ex,ey    - Coordinate of end of line
-- w        - Width of line
-- relPoint - Relative point on canvas to interpret coords (Default BOTTOMLEFT)

local function drawRouteLine(T, C, sx, sy, ex, ey, w, relPoint)
    if (not relPoint) then
        relPoint = "BOTTOMLEFT"
    end

    -- Determine dimensions and center point of line
    local dx, dy = ex - sx, ey - sy
    local cx, cy = (sx + ex) / 2, (sy + ey) / 2

    -- Normalize direction if necessary
    if (dx < 0) then
        dx, dy = -dx, -dy
    end

    -- Calculate actual length of line
    local l = sqrt((dx * dx) + (dy * dy))

    -- Quick escape if it's zero length
    if (l == 0) then
        T:SetTexCoord(0, 0, 0, 0, 0, 0, 0, 0)
        T:SetPoint("BOTTOMLEFT", C, relPoint, cx, cy)
        T:SetPoint("TOPRIGHT", C, relPoint, cx, cy)
        return
    end

    -- Sin and Cosine of rotation, and combination (for later)
    local s, c = -dy / l, dx / l
    local sc = s * c

    -- Calculate bounding box size and texture coordinates
    local Bwid, Bhgt, BLx, BLy, TLx, TLy, TRx, TRy, BRx, BRy
    if (dy >= 0) then
        Bwid = ((l * c) - (w * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((w * c) - (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRy = (w / l) * sc, s * s, (l / w) * sc
        BRx, TLx, TLy, TRx = 1 - BLy, BLy, 1 - BRy, 1 - BLx
        TRy = BRx
    else
        Bwid = ((l * c) + (w * s)) * TAXIROUTE_LINEFACTOR_2
        Bhgt = ((w * c) + (l * s)) * TAXIROUTE_LINEFACTOR_2
        BLx, BLy, BRx = s * s, -(l / w) * sc, 1 + (w / l) * sc
        BRy, TLx, TLy, TRy = BLx, 1 - BRx, 1 - BLx, 1 - BLy
        TRx = TLy
    end

    -- Set texture coordinates and anchors
    T:ClearAllPoints()
    T:SetTexCoord(TLx, TLy, BLx, BLy, TRx, TRy, BRx, BRy)
    T:SetPoint("BOTTOMLEFT", C, relPoint, cx - Bwid, cy - Bhgt)
    T:SetPoint("TOPRIGHT", C, relPoint, cx + Bwid, cy + Bhgt)
end
GW.AddForProfiling("talents", "drawRouteLine", drawRouteLine)

local function hookTalentButton(self, container, row, index)
    --  self:SetAttribute('macrotext1', '/click PlayerTalentFrameTalentsTalentRow'..row..'Talent'..index)
    self:RegisterForClicks("AnyUp")
    --   self:SetAttribute("type", "macro");
    self:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (38)), -10 + ((-42 * index) + 40))

    self.mask = UIParent:CreateMaskTexture()
    self.mask:SetPoint("CENTER", self, "CENTER", 0, 0)

    self.mask:SetTexture(
        "Interface/AddOns/GW2_UI/textures/talents/passive_border",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    self.mask:SetSize(34, 34)
end
GW.AddForProfiling("talents", "hookTalentButton", hookTalentButton)

local function setLineRotation(self, from, to)
    local y1 = 0
    local y2 = 0

    if from == 1 then
        y1 = -18
    elseif from == 2 then
        y1 = -60
    elseif from == 3 then
        y1 = -103
    end
    if to == 1 then
        y2 = -18
    elseif to == 2 then
        y2 = -60
    elseif to == 3 then
        y2 = -103
    end

    drawRouteLine(self.line, self, 10, y1, 56, y2, 4, "TOPLEFT")
end
GW.AddForProfiling("talents", "setLineRotation", setLineRotation)

local function setSpecTabIconAndTooltip(tab)
    -- update spec-specific skill tab tooltip and icon
    local _, specName, _ = GetSpecializationInfo(GW.myspec)
    tab.gwTipLabel = specName
    local spec = GetSpecialization()
    if spec then
        local role = GetSpecializationRole(spec)
        tab.icon:SetTexture("Interface/AddOns/GW2_UI/textures/character/statsicon")
        if role == "DAMAGER" then
            tab.icon:SetTexCoord(0.75, 1, 0.75, 1)
        elseif role == "TANK" then
            tab.icon:SetTexCoord(0.75, 1, 0.5, 0.75)
        elseif role == "HEALER" then
            tab.icon:SetTexCoord(0.25, 0.5, 0.75, 1)
        else
            -- set default icon
            tab.icon:SetTexture("Interface/AddOns/GW2_UI/textures/talents/lock")
            tab.icon:SetTexCoord(0, 1, 0, 1)
        end
    end
end

local function updateActiveSpec()
    if InCombatLockdown() then
        return
    end

    setSpecTabIconAndTooltip(GwSpellbookMenu.tab3)

    for i = 1, GetNumSpecializations() do
        local container = _G["GwSpecFrame" .. i]

        container.specIndex = i
        if i == GW.myspec then
            container.active = true
            container.info:Hide()
            container.activeSpecTitle:Show()
            container.background:SetDesaturated(false)
        else
            container.active = false
            container.info:Show()
            container.activeSpecTitle:Hide()

            container.background:SetDesaturated(true)
        end
        local last = 0
        local lastIndex = 2
        for row = 1, maxTalentRows do
            local anySelected = false
            local allAvalible = false

            local sel = nil
            for index = 1, talentsPerRow do
                local button = _G["GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index]
                local talentID, _, texture, selected, available, spellid, _, _, _, _, known = GetTalentInfo(row, index, 1, false, "player")

                if not available then
                    allAvalible = false
                end
                if not selected then
                    anySelected = true
                end

                button.spellId = spellid
                button.icon:SetTexture(texture)

                button.talentID = talentID
                button.available = available
                button.known = known

                local ispassive = IsPassiveSpell(spellid)
                button:EnableMouse(true)
                if i ~= GW.myspec then
                    button:EnableMouse(false)
                end

                if ispassive then
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight")
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_highlight")
                    button.icon:AddMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/passive_outline")
                else
                    button.highlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight")
                    button.legendaryHighlight:SetTexture("Interface/AddOns/GW2_UI/textures/talents/active_highlight")
                    button.icon:RemoveMaskTexture(button.mask)
                    button.outline:SetTexture("Interface/AddOns/GW2_UI/textures/talents/background_border")
                end

                if i == GW.myspec and (selected or available) and not known then
                    button.highlight:Show()
                    button.legendaryHighlight:Hide()

                    if lastIndex ~= -1 then
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Show()
                        setLineRotation(_G["GwTalentLine" .. i .. "-" .. last .. "-" .. row], lastIndex, index)
                    else
                        _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Hide()
                    end

                    if selected then
                        sel = true
                        lastIndex = index
                    elseif index == talentsPerRow and not sel then
                        lastIndex = -1
                    end
                else
                    button.legendaryHighlight:Hide()
                    if known then
                        button.legendaryHighlight:Show()
                    end
                    button.highlight:Hide()
                end

                if i == GW.myspec and (selected or available or known) then
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                elseif i ~= GW.myspec then
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.1)
                    button:SetAlpha(0.5)
                else
                    button.icon:SetDesaturated(true)
                    button.icon:SetVertexColor(1, 1, 1, 0.4)
                end
            end

            if i == GW.myspec and allAvalible == true and anySelected == false then
                for index = 1, talentsPerRow do
                    local button = _G["GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index]
                    button.icon:SetDesaturated(false)
                    button.icon:SetVertexColor(1, 1, 1, 1)
                    button:SetAlpha(1)
                    button.highlight:Hide()
                end
            end

            if not sel then
                _G["GwTalentLine" .. i .. "-" .. last .. "-" .. row]:Hide()
            end

            last = row
        end
    end

    local hunterPetSpecId = GetSpecialization(false, true)
    local hunterPetContainerId = GetNumSpecializations() + 1
    if GW.myclass == "HUNTER" and hunterPetSpecId then
        local container = _G["GwSpecFrame" .. hunterPetContainerId]
        local _, name, description, icon, role = GetSpecializationInfo(hunterPetSpecId, false, true)

        container.roleIcon:ClearAllPoints()
        if role == "TANK" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -6, -6)
        elseif role == "HEALER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -8, -5)
        elseif role == "DAMAGER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps")
            container.roleIcon:SetSize(30, 30)
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -3, -10)
        end

        container.icon:SetTexture(icon)
        container.info.specTitle:SetText(PET_SPECIALIZATION .. ": " .. name)
        container.info.specDesc:SetText(description)

        _G["GwSpecFrame" .. hunterPetContainerId]:Show()
    elseif GW.myclass == "HUNTER" and _G["GwSpecFrame" .. hunterPetContainerId] then
        _G["GwSpecFrame" .. hunterPetContainerId]:Hide()
    end
end
GW.AddForProfiling("talents", "updateActiveSpec", updateActiveSpec)

local function loadTalents()
    local txR, txT, txH, txMH
    txR = 588 / 1024
    txH = 140
    txMH = 512
    local specs = GetNumSpecializations()
    if specs > 3 then
        txMH = 1024
    end

    local fnContainer_OnUpdate = function(self, elapsed)
        if MouseIsOver(self) then
            local r, _, _, _ = self.background:GetVertexColor()
            self.background:SetVertexColor(r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed), r + (1 * elapsed))
            return
        end
        self.background:SetVertexColor(0.7, 0.7, 0.7, 0.7)
    end
    local fnContainer_OnShow = function(self)
        self:SetScript("OnUpdate", fnContainer_OnUpdate)
    end
    local fnContainer_OnHide = function(self)
        self:SetScript("OnUpdate", nil)
    end
    local fnContainer_OnClick = function(self)
        if not self.active and C_SpecializationInfo.CanPlayerUseTalentSpecUI() then
            SetSpecialization(self.specIndex)
        end
    end
    for i = 1, GetNumSpecializations() do
        local container = CreateFrame("Button", "GwSpecFrame" .. i, GwSpecContainerFrame, "GwSpecFrame")

        container:RegisterForClicks("AnyUp")
        container.icon.mask = UIParent:CreateMaskTexture()
        container.icon.mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        container.icon.mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        container.icon.mask:SetSize(80, 80)
        container.icon:AddMaskTexture(container.icon.mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnShow", fnContainer_OnShow)
        container:SetScript("OnHide", fnContainer_OnHide)
        container:SetScript("OnClick", fnContainer_OnClick)
        container:SetPoint("TOPLEFT", GwSpecContainerFrame, "TOPLEFT", 10, (-140 * i) + 98)
        container.spec = i

        local _, name, description, icon, role = GetSpecializationInfo(i)

        container.roleIcon:ClearAllPoints()
        if role == "TANK" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-tank")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -6, -6)
        elseif role == "HEALER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-healer")
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -8, -5)
        elseif role == "DAMAGER" then
            container.roleIcon:SetTexture("Interface/AddOns/GW2_UI/textures/party/roleicon-dps")
            container.roleIcon:SetSize(30, 30)
            container.roleIcon:SetPoint("BOTTOMRIGHT", container.icon, "BOTTOMRIGHT", -3, -10)
        end

        container.activeSpecTitle:SetFont(DAMAGE_TEXT_FONT, 13)
        container.activeSpecTitle:SetTextColor(1, 1, 1, 1)
        container.activeSpecTitle:SetShadowColor(0, 0, 0, 1)
        container.activeSpecTitle:SetShadowOffset(1, -1)
        container.activeSpecTitle:SetText(name)
        container.icon:SetTexture(icon)
        container.info.specTitle:SetFont(DAMAGE_TEXT_FONT, 16)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:SetFont(UNIT_NAME_FONT, 14)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.info.specTitle:SetText(name)
        container.info.specDesc:SetText(description)
        container.iconHelperButton:SetScript("OnEnter", function(self)
            if not self:GetParent().active then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetParent().info.specTitle:GetText(), 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self:GetParent().info.specDesc:GetText(), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        container.iconHelperButton:SetScript("OnLeave", GameTooltip_Hide)

        txT = (i - 1) * txH
        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)

        local last = 0

        local fnTalentButton_OnEnter = function(self)
            if self:GetParent().active ~= true then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:SetTalent(self.talentID)
            GameTooltip:Show()
        end
        local fnTalentButton_OnDragStart = function(self)
            if InCombatLockdown() or self.isPassive then
                return
            end
            PickupSpell(self.spellId)
        end
        local fnTalentButton_OnClick = function(self)
            if IsModifiedClick("CHATLINK") then
                local link = GetSpellLink(self.spellId)
                ChatEdit_InsertLink(link)
                return
            end
            return LearnTalent(self.talentID)
        end
        for row = 1, maxTalentRows do
            local fistOnRow
            local line = CreateFrame("Frame", "GwTalentLine" .. i .. "-" .. last .. "-" .. row, container, "GwTalentLine")

            line:SetPoint("TOPLEFT", container, "TOPLEFT", 110 + ((65 * row) - (88)), -10)

            last = row

            for index = 1, talentsPerRow do
                local talentButton =
                    CreateFrame(
                    "Button",
                    "GwSpecFrameSpec" .. i .. "Teir" .. row .. "index" .. index,
                    container,
                    "GwTalentButton"
                )
                talentButton:SetScript("OnEnter", fnTalentButton_OnEnter)
                talentButton:SetScript("OnLeave", GameTooltip_Hide)
                talentButton:SetScript("OnDragStart", fnTalentButton_OnDragStart)
                talentButton:SetScript("OnClick", fnTalentButton_OnClick)

                talentButton:RegisterForDrag("LeftButton")

                hookTalentButton(talentButton, container, row, index)

                if fistOnRow == nil then
                    fistOnRow = talentButton
                end
            end
            if i == 1 then
                local numberDisplay = CreateFrame("Frame", "GwTalentsLevelLabel" .. row, GwSpecContainerFrame, "GwTalentsLevelLabel")
                numberDisplay.title:SetFont(DAMAGE_TEXT_FONT, 14)
                numberDisplay.title:SetTextColor(0.7, 0.7, 0.7, 1)
                numberDisplay.title:SetShadowColor(0, 0, 0, 0)
                numberDisplay.title:SetShadowOffset(1, -1)
                numberDisplay:SetPoint("BOTTOM", fistOnRow, "TOP", 0, 13)
                numberDisplay.title:SetText(select(3, GetTalentTierInfo(row, GetActiveSpecGroup())))
            end
        end
    end
    updateActiveSpec()

    local hunterPetContainerId = GetNumSpecializations() + 1

    if GW.myclass == "HUNTER" then
        local container = CreateFrame("Button", "GwSpecFrame" .. hunterPetContainerId, GwSpecContainerFrame, "GwSpecFrame")

        container.icon.mask = UIParent:CreateMaskTexture()
        container.icon.mask:SetPoint("CENTER", container.icon, "CENTER", 0, 0)
        container.icon.mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        container.icon.mask:SetSize(80, 80)
        container.icon:AddMaskTexture(container.icon.mask)
        container:SetScript("OnEnter", nil)
        container:SetScript("OnLeave", nil)
        container:SetScript("OnUpdate", nil)
        container:SetScript("OnShow", fnContainer_OnShow)
        container:SetScript("OnHide", fnContainer_OnHide)
        container:SetPoint("TOPLEFT", GwSpecContainerFrame, "TOPLEFT", 10, (-140 * hunterPetContainerId) + 98)
        container.spec = hunterPetContainerId

        container.info.specTitle:SetFont(DAMAGE_TEXT_FONT, 16)
        container.info.specTitle:SetTextColor(1, 1, 1, 1)
        container.info.specTitle:SetShadowColor(0, 0, 0, 1)
        container.info.specTitle:SetShadowOffset(1, -1)
        container.info.specDesc:SetFont(UNIT_NAME_FONT, 14)
        container.info.specDesc:SetTextColor(0.8, 0.8, 0.8, 1)
        container.info.specDesc:SetShadowColor(0, 0, 0, 1)
        container.info.specDesc:SetShadowOffset(1, -1)
        container.iconHelperButton:SetScript("OnEnter", function(self)
            if not self:GetParent().active then
                return
            end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetParent().info.specTitle:GetText(), 1, 1, 1)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(self:GetParent().info.specDesc:GetText(), 1, 1, 1, true)
            GameTooltip:Show()
        end)
        container.iconHelperButton:SetScript("OnLeave", GameTooltip_Hide)

        txT = (3 - 1) * txH
        container.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/art/" .. GW.myClassID)
        container.background:SetTexCoord(0, txR, txT / txMH, (txT + txH) / txMH)
    end
end
GW.AddForProfiling("talents", "loadTalents", loadTalents)

local function spellButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()

    if InClickBindingMode() and not self.canClickBind then
        GameTooltip:AddLine(CLICK_BINDING_NOT_AVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
        GameTooltip:Show();
        return;
    end
    if self.skillType == "TALENT" then
        GameTooltip:SetSpellByID(self.spellId)
    elseif not self.isFlyout and self.spellbookIndex then
        GameTooltip:SetSpellBookItem(self.spellbookIndex, self.booktype)
    elseif not self.spellbookIndex and self.spellId then
        GameTooltip:SetSpellByID(self.spellId)
    else
        local name, desc, _, _ = GetFlyoutInfo(self.spellId)
        GameTooltip:AddLine(name)
        GameTooltip:AddLine(desc)
    end
    if self.isFuture then
        if self.unlockLevel then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(UNLOCKS_AT_LEVEL:format(self.unlockLevel), 1, 1, 1)
        elseif GetSpellLevelLearned(self.spellId) > 0 then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(UNLOCKS_AT_LEVEL:format(GetSpellLevelLearned(self.spellId)), 1, 1, 1)
        end
    end
    GameTooltip:Show()
end
GW.AddForProfiling("talents", "spellButton_OnEnter", spellButton_OnEnter)

local function spellButton_OnDragStart(self)
    if InCombatLockdown() or self.isFuture then
        return
    end
    PickupSpellBookItem(self.spellbookIndex, self.booktype)
end
GW.AddForProfiling("talents", "spellButton_OnDragStart", spellButton_OnDragStart)

local function spellButton_ClickBindCast(self)
    if InClickBindingMode() then
        if ClickBindingFrame:HasNewSlot() and self.canClickBind then
            ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Spell, self.spellId);
        end
    end
end

local function spellButton_GlyphApply(self, unit, button, actionType)
    GW.Debug("in glyph application", unit, button, actionType)
    if HasPendingGlyphCast() then
        --local slotType, spellId = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
        local spellId = self.spellId
        if self.skillType == "SPELL" then
            if HasAttachedGlyph(spellId) then
                if IsPendingGlyphRemoval() then
                    StaticPopup_Show(
                        "CONFIRM_GLYPH_REMOVAL",
                        nil,
                        nil,
                        {name = GetCurrentGlyphNameForSpell(spellId), id = spellId}
                    )
                else
                    StaticPopup_Show(
                        "CONFIRM_GLYPH_PLACEMENT",
                        nil,
                        nil,
                        {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellId), id = spellId}
                    )
                end
            else
                AttachGlyphToSpell(spellId)
            end
        elseif self.skillType == "FLYOUT" then
            SpellFlyout:Toggle(spellId, self, "RIGHT", 1, false, self.offSpecID, true)
            SpellFlyout:SetBorderColor(181 / 256, 162 / 256, 90 / 256)
        end
    end
end
GW.AddForProfiling("talents", "spellButton_GlyphApply", spellButton_GlyphApply)

local spellButtonSecure_OnDragStart =
    [=[
    local isPickable = self:GetAttribute("ispickable")
    local spellId = self:GetAttribute("spell")

    if not spellId or not isPickable then
        return "clear", nil
    end

    return "clear", "spell", spellId
    ]=]

local function setButton(btn, spellId, skillType, icon, spellbookIndex, booktype)
    btn.isFuture = (skillType == "FUTURESPELL")
    btn.spellbookIndex = spellbookIndex
    btn.booktype = booktype
    btn.spellId = spellId
    btn.skillType = skillType
    btn.icon:SetTexture(icon)
    btn:SetAlpha(1)
    btn:Show()

    if btn.isFuture then
        btn.icon:SetDesaturated(true)
        btn.icon:SetAlpha(0.5)
    else
        btn.icon:SetDesaturated(false)
        btn.icon:SetAlpha(1)
    end
end
GW.AddForProfiling("talents", "setButton", setButton)

local function TalProfButton_OnModifiedClick(self)
    local slot = self.spellbookIndex
    local book = self.booktype
    if IsModifiedClick("CHATLINK") then
        if MacroFrameText and MacroFrameText:HasFocus() then
            local spell, subSpell = GetSpellBookItemName(slot, book)
            if spell and not IsPassiveSpell(slot, book) then
                if subSpell and strlen(subSpell) > 0 then
                    ChatEdit_InsertLink(spell .. "(" .. subSpell .. ")")
                else
                    ChatEdit_InsertLink(spell)
                end
            end
        else
            local profLink, profId = GetSpellTradeSkillLink(slot, book)
            if profId then
                ChatEdit_InsertLink(profLink)
            else
                ChatEdit_InsertLink(GetSpellLink(slot, book))
            end
        end
    elseif IsModifiedClick("PICKUPACTION") and not InCombatLockdown() and not IsPassiveSpell(slot, book) then
        PickupSpellBookItem(slot, book)
    end
end
GW.TalProfButton_OnModifiedClick = TalProfButton_OnModifiedClick

local function setActiveButton(btn, spellId, skillType, icon, spellbookIndex, booktype, name)
    setButton(btn, spellId, skillType, icon, spellbookIndex, booktype)

    local _, autostate = GetSpellAutocast(spellbookIndex, booktype)
    if autostate then
        btn.autocast:Show()
    else
        btn.autocast:Hide()
    end

    btn:SetAttribute("ispickable", false)
    btn.isFlyout = (skillType == "FLYOUT")
    if btn.isFlyout then
        btn.arrow:Show()
        btn:SetAttribute("*type1", "flyout")
        btn:SetAttribute("*type2", "flyout")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("flyout", spellId)
        btn:SetAttribute("flyoutDirection", "RIGHT")
    elseif not btn.isFuture and booktype == BOOKTYPE_PET then
        btn:SetAttribute("*type1", "spell")
        btn:SetAttribute("*type2", "macro")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("*macrotext2", "/petautocasttoggle " .. name)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    elseif not btn.isFuture then
        btn:SetAttribute("ispickable", true)
        btn:SetAttribute("*type1", "spell")
        btn:SetAttribute("*type2", "spell")
        btn:SetAttribute("spell", spellId)
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    else
        btn:SetAttribute("shift-type1", "modifiedClick")
        btn:SetAttribute("shift-type2", "modifiedClick")
    end

    btn:EnableMouse(true)
end
GW.AddForProfiling("talents", "setActiveButton", setActiveButton)

local function setPassiveButton(btn, spellId, skillType, icon, spellbookIndex, booktype, tab, name)
    setButton(btn, spellId, skillType, icon, spellbookIndex, booktype, tab, name)
    btn:SetAttribute("shift-type1", "modifiedClick")
    btn:SetAttribute("shift-type2", "modifiedClick")
    btn:EnableMouse(true)
end
GW.AddForProfiling("talents", "setPassiveButton", setPassiveButton)

local function checkForClickBinding(btn, spellId, fmSpellbook)
    btn.canClickBind = false
    if InClickBindingMode() then
        btn.SpellHighlightTexture:Hide();
        local spellBindable = spellId and C_ClickBindings.CanSpellBeClickBound(spellId) or false;
        local isDisabled = spellId and C_SpellBook.IsSpellDisabled(spellId)
        local isOffSpec = (btn.offSpecID ~= 0) and (btn.bookType == BOOKTYPE_SPELL);
        local canBind = spellBindable and (not isOffSpec) and (not isDisabled);
        if (canBind) then
            btn.canClickBind = true;
            if (ClickBindingFrame:HasEmptySlot()) then
                btn.ClickBindingHighlight:Show();
            end
            btn:SetAttribute("type1", "CustomClickCastClick") -- enable strict left-click clickBindCast
        else
            btn.ClickBindingIconCover:Show();
        end
    elseif fmSpellbook.glyphReason == nil then
        btn:SetAttribute("type1", nil)
        btn.ClickBindingHighlight:Hide()
    end
end

local function checkForGlyph(btn, spellId, fmSpellbook)
    if HasAttachedGlyph(spellId) then
        btn.GlyphIcon:Show()
        if IsPendingGlyphRemoval() and fmSpellbook.glyphReason then
            btn.AbilityHighlight:Show()
            btn.AbilityHighlightAnim:Play()
            btn:SetAttribute("type1", "GlyphApply") -- enable strict left-click glyph applying
        else
            btn.AbilityHighlightAnim:Stop()
            btn.AbilityHighlight:Hide()
            btn:SetAttribute("type1", nil)
        end
    else
        btn.GlyphIcon:Hide()
    end
    if fmSpellbook.glyphSlot == spellId then
        if (fmSpellbook.glyphReason == "USE_GLYPH") then
            btn.AbilityHighlight:Show()
            btn.AbilityHighlightAnim:Play()
            btn:SetAttribute("type1", "GlyphApply") -- enable strict left-click glyph applying
            fmSpellbook.glyphBtn = btn
        else
            btn.AbilityHighlightAnim:Stop()
            btn.AbilityHighlight:Hide()
            fmSpellbook.glyphBtn = nil
            fmSpellbook.glyphSlot = nil
            fmSpellbook.glyphIndex = nil
            btn:SetAttribute("type1", nil)

            if (fmSpellbook.glyphReason == "ACTIVATE_GLYPH") then
                btn.GlyphActivate:Show()
                btn.GlyphIcon:Show()
                btn.GlyphTranslation:Show()
                btn.GlyphActivateAnim:Play()
            end
        end
    end
end

local function CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
    local btn = passiveGroup.pool:Acquire()
    local row = math.floor((passiveIndex - 1) / 5)
    local col = (passiveIndex - 1) % 5
    btn:SetPoint("TOPLEFT", passiveGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
    setPassiveButton(btn, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)

    -- check for should glyph highlight
    if spellBookTabs == 2 or spellBookTabs == 3 then
        checkForGlyph(btn, spellId, fmSpellbook)
    end

    return passiveIndex + 1
end

local function CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
    local btn
    if BOOKTYPE == BOOKTYPE_PET or skillType == "FLYOUT" then
        btn = activeGroup.poolNSD:Acquire()
    else
        btn = activeGroup.pool:Acquire()
    end
    local row = math.floor((activeIndex - 1) / 5)
    local col = (activeIndex - 1) % 5
    btn:SetPoint("TOPLEFT", activeGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row))
    setActiveButton(btn, spellId, skillType, icon, spellIndex, BOOKTYPE, name)

    -- check for should glyph highlight
    if spellBookTabs == 2 or spellBookTabs == 3 then
        checkForGlyph(btn, spellId, fmSpellbook)
        checkForClickBinding(btn, spellId, fmSpellbook)
    end
    GW.RegisterCooldown(btn.cooldown)

    return activeIndex + 1
end

local function updateRegTab(fmSpellbook, fmTab, spellBookTabs)
    local _, _, offset, numSpells = GetSpellTabInfo(spellBookTabs)
    local btn

    local BOOKTYPE = BOOKTYPE_SPELL
    if spellBookTabs == 3 and (numSpells < 1 or GetSpecialization() == 5) then
        fmTab.groups["active"]:Hide()
        fmTab.groups["passive"]:Hide()
        fmTab.groups["lock"]:Show()
    elseif spellBookTabs == 3 and (numSpells >= 1 or GetSpecialization() < 5) then
        fmTab.groups["active"]:Show()
        fmTab.groups["passive"]:Show()
        fmTab.groups["lock"]:Hide()
    elseif spellBookTabs == 5 then
        BOOKTYPE = BOOKTYPE_PET
        numSpells = HasPetSpells()
        offset = 0
        if numSpells == nil then
            numSpells = 0
        end
        if numSpells == 0 then
            fmTab.groups["active"]:Hide()
            fmTab.groups["passive"]:Hide()
            fmTab.groups["lock"]:Show()
        else
            fmTab.groups["active"]:Show()
            fmTab.groups["passive"]:Show()
            fmTab.groups["lock"]:Hide()
        end
    end

    local activeIndex = 1
    local activeGroup = fmTab.groups["active"]
    local passiveIndex = 1
    local passiveGroup = fmTab.groups["passive"]

    activeGroup.pool:ReleaseAll()
    activeGroup.poolNSD:ReleaseAll()
    passiveGroup.pool:ReleaseAll()

    -- first add talent passives to not habe spaces between
    local talentPassiveSkills = {}
    if BOOKTYPE == BOOKTYPE_SPELL and spellBookTabs == 3 then
        for row = 1, maxTalentRows do
            for index = 1, talentsPerRow do
                local _, name, icon, selected, available, spellId = GetTalentInfo(row, index, 1, false, "player")
                if selected and available and spellId and IsPassiveSpell(spellId) then
                    local skillType = "TALENT"
                    btn = passiveGroup.pool:Acquire()
                    local row2 = math.floor((passiveIndex - 1) / 5)
                    local col = (passiveIndex - 1) % 5
                    btn:SetPoint("TOPLEFT", passiveGroup, "TOPLEFT", 4 + (50 * col), -37 + (-50 * row2))
                    setPassiveButton(btn, spellId, skillType, icon, nil, BOOKTYPE, spellBookTabs, name)
                    passiveIndex = passiveIndex + 1
                    talentPassiveSkills[spellId] = true
                end
            end
        end
    end

    for i = 1, numSpells do
        local spellIndex = i + offset
        local name, _ = GetSpellBookItemName(spellIndex, BOOKTYPE)
        if name == nil then
            name = ""
        end

        local skillType, spellId = GetSpellBookItemInfo(spellIndex, BOOKTYPE)
        if BOOKTYPE == BOOKTYPE_PET then
            _, _, _, _, _, _, spellId = GetSpellInfo(spellIndex, BOOKTYPE)
        end
        local icon = GetSpellBookItemTexture(spellIndex, BOOKTYPE)

        if IsPassiveSpell(spellIndex, BOOKTYPE) then
            if not talentPassiveSkills[spellId] then
                passiveIndex = CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
            end
        else
            activeIndex = CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, spellId, skillType, icon, spellIndex, BOOKTYPE, spellBookTabs, name)
        end
    end
    if spellBookTabs == 5 and GetSpecialization(false, true) then
        -- add spec spells
        local bonuses = {GetSpecializationSpells(GetSpecialization(false, true), nil, true)}
        for i = 1, #bonuses, 2 do
            if not IsSpellKnownOrOverridesKnown(bonuses[i], true) then
                local isPassive = IsPassiveSpell(bonuses[i])
                local name, _, icon = GetSpellInfo(bonuses[i])

                if isPassive then
                    if not talentPassiveSkills[bonuses[i]] then
                        passiveIndex = CreatePassiveSpellButton(passiveGroup, passiveIndex, fmSpellbook, bonuses[i], "FUTURESPELL", icon, nil, BOOKTYPE, spellBookTabs, name)
                    end
                else
                    activeIndex = CreateActiveSpellButton(activeGroup, activeIndex, fmSpellbook, bonuses[i], "FUTURESPELL", icon, nil, BOOKTYPE, spellBookTabs, name)
                end
            end
        end
    end
    talentPassiveSkills = nil

    local offY = (math.ceil((activeIndex - 1) / 5) * 50) + 66
    passiveGroup:ClearAllPoints()
    passiveGroup:SetPoint("TOPLEFT", fmTab, "TOPLEFT", -4, -offY)
end
GW.AddForProfiling("talents", "updateRegTab", updateRegTab)

local function updateTab(fmSpellbook)
    if InCombatLockdown() then
        return
    end

    for tab = 1, 5 do
        local fmTab = fmSpellbook.tabContainers[tab]
        if tab == 4 then
            UpdatePvPTab(fmTab)
        else
            updateRegTab(fmSpellbook, fmTab, tab)
        end
    end
end
GW.AddForProfiling("talents", "updateTab", updateTab)

local function spellMenu_OnUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateTab(self)
    self.queuedUpdateTab = false
end
GW.AddForProfiling("talents", "spellMenu_OnUpdate", spellMenu_OnUpdate)

local function queueUpdateTab(fm)
    if fm.queuedUpdateTab then
        return
    end

    fm.queuedUpdateTab = true
    fm:SetScript("OnUpdate", spellMenu_OnUpdate)
end
GW.AddForProfiling("talents", "queueUpdateTab", queueUpdateTab)

local function talentFrame_OnUpdate(self)
    self:SetScript("OnUpdate", nil)
    updateActiveSpec()
    self.queuedUpdateActiveSpec = false
end
GW.AddForProfiling("talents", "talentFrame_OnUpdate", talentFrame_OnUpdate)

local function queueUpdateActiveSpec(fm)
    if fm.queuedUpdateActiveSpec then
        return
    end

    fm.queuedUpdateActiveSpec = true
    fm:SetScript("OnUpdate", talentFrame_OnUpdate)
end
GW.AddForProfiling("talents", "queueUpdateActiveSpec", queueUpdateActiveSpec)

local function spellTab_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip_AddNormalLine(GameTooltip, self.gwTipLabel)
    GameTooltip:Show()
end
GW.AddForProfiling("talents", "spellTab_OnEnter", spellTab_OnEnter)

local function activePoolCommon_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")
    btn:Hide()
    btn.arrow:Hide()
    btn.autocast:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetScript("OnEvent", SpellButton_OnEvent) --spellButton_OnEvent??
    btn:SetAttribute("flyout", nil)
    btn:SetAttribute("flyoutDirection", nil)
    btn:SetAttribute("type1", nil)
    btn:SetAttribute("type2", nil)
    btn:SetAttribute("spell", nil)
    btn:SetAttribute("shift-type1", nil)
    btn:SetAttribute("shift-type2", nil)
    btn:SetAttribute("*macrotext2", nil)
    btn:SetAttribute("ispickable", nil)
    btn.GlyphApply = spellButton_GlyphApply
    btn.CustomClickCastClick = spellButton_ClickBindCast
    btn.isFuture = nil
    btn.spellbookIndex = nil
    btn.booktype = nil
    btn.spellId = nil
    btn.skillType = nil
    btn.isFlyout = nil
    btn.modifiedClick = TalProfButton_OnModifiedClick
    btn.canClickBind = false
end
GW.AddForProfiling("talents", "activePoolCommon_Resetter", activePoolCommon_Resetter)

local function activePool_Resetter(self, btn)
    activePoolCommon_Resetter(self, btn)
    btn:SetAttribute("_ondragstart", spellButtonSecure_OnDragStart)
end
GW.AddForProfiling("talents", "activePool_Resetter", activePool_Resetter)

local function activePoolNSD_Resetter(self, btn)
    activePoolCommon_Resetter(self, btn)
    btn:SetScript("OnDragStart", spellButton_OnDragStart)
end
GW.AddForProfiling("talents", "activePoolNSD_Resetter", activePoolNSD_Resetter)

local function passivePool_Resetter(_, btn)
    btn:EnableMouse(false)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:Hide()
    btn:SetScript("OnEnter", spellButton_OnEnter)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    btn:SetAttribute("shift-type1", nil)
    btn:SetAttribute("shift-type2", nil)
    btn.GlyphApply = spellButton_GlyphApply
    btn.isFuture = nil
    btn.spellbookIndex = nil
    btn.booktype = nil
    btn.spellId = nil
    btn.skillType = nil
    btn.modifiedClick = TalProfButton_OnModifiedClick

    if not btn.mask then
        btn.mask = UIParent:CreateMaskTexture()
        btn.mask:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
        btn.mask:SetTexture(
            "Interface/AddOns/GW2_UI/textures/talents/passive_border",
            "CLAMPTOBLACKADDITIVE",
            "CLAMPTOBLACKADDITIVE"
        )
        btn.mask:SetSize(40, 40)
        btn.icon:AddMaskTexture(btn.mask)
    end
end
GW.AddForProfiling("talents", "passivePool_Resetter", passivePool_Resetter)

local function updateButton(self)
    if self.spellbookIndex and self.booktype then
        local start, duration, _ = GetSpellCooldown(self.spellbookIndex, self.booktype)

        if start ~= nil and duration ~= nil then
            self.cooldown:SetCooldown(start, duration)
        end

        local _, autostate = GetSpellAutocast(self.spellbookIndex, self.booktype)

        self.autocast:SetShown(autostate)
    end
end
GW.AddForProfiling("talents", "updateButton", updateButton)

local function spellGroup_OnEvent(self)
    if not GwTalentFrame:IsShown() or not self.pool or not self.poolNSD or not GW.inWorld then
        return
    end

    for btn in self.pool:EnumerateActive() do
        updateButton(btn)
    end
    for btn in self.poolNSD:EnumerateActive() do
        updateButton(btn)
    end
end
GW.AddForProfiling("talents", "spellGroup_OnEvent", spellGroup_OnEvent)

local function toggleSpellBook(bookType)
    if InCombatLockdown() then
        return
    end
    if bookType == BOOKTYPE_PROFESSION then
        GwCharacterWindow:SetAttribute("windowpanelopen", "professions")
    elseif bookType == BOOKTYPE_PET then
        GwCharacterWindow:SetAttribute("windowpanelopen", "petbook")
    else
        -- BOOKTYPE_SPELL or any other type
        GwCharacterWindow:SetAttribute("windowpanelopen", "spellbook")
    end
end
GW.AddForProfiling("talents", "toggleSpellBook", toggleSpellBook)

local function toggleTalentFrame()
    if InCombatLockdown() then
        return
    end
    GwCharacterWindow:SetAttribute("keytoggle", true)
    GwCharacterWindow:SetAttribute("windowpanelopen", "talents")
end
GW.AddForProfiling("talents", "toggleTalentFrame", toggleTalentFrame)

local function spellBook_OnEvent(self, event, ...)
    if IsIn(event, "SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB", "PLAYER_GUILD_UPDATE", "PLAYER_SPECIALIZATION_CHANGED", "PLAYER_LEVEL_UP", "") then
        if not GwTalentFrame:IsShown() or not GW.inWorld then
            return
        end
        queueUpdateTab(self)
    elseif IsIn(event, "USE_GLYPH", "ACTIVATE_GLYPH") then
        -- open and highlight glyphable spell
        local slot = ...
        GW.Debug("in event", event, slot, IsPendingGlyphRemoval())
        GwCharacterWindow:SetAttribute("windowpanelopen", "spellbook")
        if IsPendingGlyphRemoval() then
            self.glyphSlot = -1 -- highlight/cancel all
        else
            self.glyphSlot = slot
        end
        if event == "ACTIVATE_GLYPH" then
            self.glyphCasting = true
        else
            self.glyphCasting = nil
        end
        self.glyphReason = event
        queueUpdateTab(self) -- if already open OnShow won't fire again so queue here to be sure
    elseif event == "CANCEL_GLYPH_CAST" then
        -- dehiglight glyphable spell
        GW.Debug("in event", event)
        if self.glyphBtn then
            self.glyphBtn.AbilityHighlightAnim:Stop()
            self.glyphBtn.AbilityHighlight:Hide()
            self.glyphBtn:SetAttribute("type1", nil)
            self.glyphBtn = nil
        end
        if self.glyphSlot == -1 then
            queueUpdateTab(self)
        end
        self.glyphSlot = nil
        self.glyphReason = nil
    elseif event == "CURRENT_SPELL_CAST_CHANGED" then
        if self.glyphCasting and not IsCastingGlyph() then
            self.glyphBtn = nil
            self.glyphSlot = nil
            self.glyphReason = nil
            self.glyphCasting = nil
            queueUpdateTab(self)
        end
    end
end
GW.AddForProfiling("talents", "spellBook_OnEvent", spellBook_OnEvent)

local function createRegTab(fmSpellbook, tab)
    local container = CreateFrame("Frame", nil, fmSpellbook, "GwSpellbookContainerTab")
    local actGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    local psvGroup = CreateFrame("Frame", nil, container, "GwSpellbookButtonGroup")
    container.groups = {
        ["active"] = actGroup,
        ["passive"] = psvGroup
    }

    actGroup:ClearAllPoints()
    actGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
    actGroup.label.title:SetFont(DAMAGE_TEXT_FONT, 14)
    actGroup.label.title:SetTextColor(1, 1, 1, 1)
    actGroup.label.title:SetShadowColor(0, 0, 0, 1)
    actGroup.label.title:SetShadowOffset(1, -1)
    actGroup.label.title:SetText(ACTIVE_PETS)
    actGroup.pool = CreateFramePool("Button", actGroup, "GwSpellbookActiveButton", activePool_Resetter)
    actGroup.poolNSD = CreateFramePool("Button", actGroup, "GwSpellbookActiveButtonNSD", activePoolNSD_Resetter)
    actGroup:SetScript("OnEvent", spellGroup_OnEvent)
    actGroup:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    actGroup:RegisterEvent("PET_BAR_UPDATE")

    psvGroup:ClearAllPoints()
    psvGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -72)
    psvGroup.label.title:SetFont(DAMAGE_TEXT_FONT, 14)
    psvGroup.label.title:SetTextColor(1, 1, 1, 1)
    psvGroup.label.title:SetShadowColor(0, 0, 0, 1)
    psvGroup.label.title:SetShadowOffset(1, -1)
    psvGroup.label.title:SetText(SPELL_PASSIVE)
    psvGroup.pool = CreateFramePool("Button", psvGroup, "GwSpellbookPassiveButton", passivePool_Resetter)

    if tab == 3 or tab == 5 then
        local lockGroup = CreateFrame("Frame", nil, container, "GwSpellbookLockGroup")
        container.groups["lock"] = lockGroup
        lockGroup:ClearAllPoints()
        lockGroup:SetPoint("TOPLEFT", container, "TOPLEFT", -4, -31)
        lockGroup.info:SetFont(DAMAGE_TEXT_FONT, 14)
        lockGroup.info:SetTextColor(1, 1, 1, 1)
        lockGroup.info:SetShadowColor(0, 0, 0, 1)
        lockGroup.info:SetShadowOffset(1, -1)
        lockGroup.info:SetText(tab == 3 and format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, 10) or SPELL_FAILED_NO_PET)
    end

    return container
end
GW.AddForProfiling("talents", "createRegTab", createRegTab)

local function LoadTalents(tabContainer)
    local fmGTF = CreateFrame("Frame", "GwTalentFrame", tabContainer, "SecureHandlerStateTemplate,GwTalentFrame")
    fmGTF.title:SetFont(DAMAGE_TEXT_FONT, 14)
    fmGTF.title:SetTextColor(1, 1, 1, 1)
    fmGTF.title:SetShadowColor(0, 0, 0, 1)
    fmGTF.title:SetShadowOffset(1, -1)
    fmGTF.title:SetText(SPECIALIZATION)
    fmGTF:SetScript(
        "OnEvent",
        function(self)
            if not self:IsShown() or not GW.inWorld then
                return
            end
            queueUpdateActiveSpec(self)
        end
    )
    fmGTF:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    fmGTF:RegisterEvent("PET_SPECIALIZATION_CHANGED")
    fmGTF:RegisterEvent("PLAYER_LEARN_PVP_TALENT_FAILED")
    fmGTF:RegisterEvent("PLAYER_LEARN_TALENT_FAILED")
    fmGTF:RegisterEvent("PLAYER_PVP_TALENT_UPDATE")
    fmGTF:RegisterEvent("PLAYER_TALENT_UPDATE")
    fmGTF:RegisterEvent("SPEC_INVOLUNTARILY_CHANGED")
    fmGTF:RegisterEvent("TALENTS_INVOLUNTARILY_RESET")
    fmGTF:RegisterEvent("UNIT_MODEL_CHANGED")
    fmGTF:RegisterEvent("UNIT_LEVEL")

    CreateFrame("Frame", "GwSpecContainerFrame", GwTalentFrame)
    GwSpecContainerFrame:SetPoint("TOPLEFT", GwTalentFrame, "TOPLEFT")
    GwSpecContainerFrame:SetPoint("BOTTOMRIGHT", GwTalentFrame, "BOTTOMRIGHT")

    local fmSpellbook = CreateFrame("Frame", "GwSpellbookMenu", GwTalentFrame, "GwSpellbookMenu")
    -- TODO: change this to do all attribute stuff on container instead of menu
    GwCharacterWindow:SetFrameRef("GwSpellbookMenu", fmSpellbook)

    fmSpellbook.tabContainers = {}
    fmSpellbook.queuedUpdateTab = false
    fmSpellbook:SetScript("OnEvent", spellBook_OnEvent)
    fmSpellbook:RegisterEvent("SPELLS_CHANGED")
    fmSpellbook:RegisterEvent("LEARNED_SPELL_IN_TAB")
    fmSpellbook:RegisterEvent("PLAYER_GUILD_UPDATE")
    fmSpellbook:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    fmSpellbook:RegisterEvent("USE_GLYPH")
    fmSpellbook:RegisterEvent("CANCEL_GLYPH_CAST")
    fmSpellbook:RegisterEvent("ACTIVATE_GLYPH")
    fmSpellbook:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    fmSpellbook:RegisterEvent("PLAYER_LEVEL_UP")
    SpellBookFrame:UnregisterAllEvents()

    for tab = 1, 5 do
        if tab == 4 then
            fmSpellbook.tabContainers[tab] = CreatePvPTab(fmSpellbook)
        else
            fmSpellbook.tabContainers[tab] = createRegTab(fmSpellbook, tab)
        end
        fmSpellbook:SetFrameRef("GwSpellbookContainerTab" .. tab, fmSpellbook.tabContainers[tab])
    end

    fmSpellbook.tabContainers[2]:Show()

    loadTalents()
    updateTab(fmSpellbook)

    fmSpellbook.tab1:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab1:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',1)
        ]=]
    )
    fmSpellbook.tab2:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab2:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',2)
        ]=]
    )
    fmSpellbook.tab3:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab3:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',3)
        ]=]
    )
    fmSpellbook.tab4:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab4:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',4)
        ]=]
    )
    fmSpellbook.tab5:SetFrameRef("GwSpellbookMenu", fmSpellbook)
    fmSpellbook.tab5:SetAttribute(
        "_onclick",
        [=[
        self:GetFrameRef('GwSpellbookMenu'):SetAttribute('tabopen',5)
        ]=]
    )

    fmSpellbook:SetFrameRef("GwspellbookTab1", fmSpellbook.tab1)
    fmSpellbook:SetFrameRef("GwspellbookTab2", fmSpellbook.tab2)
    fmSpellbook:SetFrameRef("GwspellbookTab3", fmSpellbook.tab3)
    fmSpellbook:SetFrameRef("GwspellbookTab4", fmSpellbook.tab4)
    fmSpellbook:SetFrameRef("GwspellbookTab5", fmSpellbook.tab5)
    fmSpellbook:SetFrameRef("GwSpecContainerFrame", GwSpecContainerFrame)
    fmSpellbook.UnselectAllTabs = function()
        fmSpellbook.tab1.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive")
        fmSpellbook.tab2.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive")
        fmSpellbook.tab3.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive")
        fmSpellbook.tab4.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive")
        fmSpellbook.tab5.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg_inactive")
    end
    fmSpellbook.SelectTab = function(_, tab)
        local frame
        if tab == 1 then
            frame = fmSpellbook.tab1
        elseif tab == 2 then
            frame = fmSpellbook.tab2
        elseif tab == 3 then
            frame = fmSpellbook.tab3
        elseif tab == 4 then
            frame = fmSpellbook.tab4
        elseif tab == 5 then
            frame = fmSpellbook.tab5
        end
        frame.background:SetTexture("Interface/AddOns/GW2_UI/textures/talents/spellbooktab_bg")
    end
    fmSpellbook:SetAttribute(
        "_onattributechanged",
        [=[
            if name ~= 'tabopen' then return end
            
            self:GetFrameRef('GwSpellbookContainerTab1'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab2'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab3'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab4'):Hide()
            self:GetFrameRef('GwSpellbookContainerTab5'):Hide()
            self:CallMethod("UnselectAllTabs")
        
            if value == 1 then
                self:GetFrameRef('GwSpellbookContainerTab1'):Show()
                self:CallMethod("SelectTab", 1)
                return
            elseif value == 2 then
                self:GetFrameRef('GwSpellbookContainerTab2'):Show()
                self:CallMethod("SelectTab", 2)
                return
            elseif value == 3 then
                self:GetFrameRef('GwSpellbookContainerTab3'):Show()
                self:CallMethod("SelectTab", 3)
                return
            elseif value == 4 then
                self:GetFrameRef('GwSpellbookContainerTab4'):Show()
                self:CallMethod("SelectTab", 4)
                return
            elseif value == 5 then
                self:GetFrameRef('GwSpellbookContainerTab5'):Show()
                self:CallMethod("SelectTab", 5)
                return
            end
        ]=]
    )
    fmSpellbook:SetAttribute("tabOpen", 2)

    local _, specName = GetSpecializationInfo(GW.myspec)
    fmSpellbook.tab1.gwTipLabel = GENERAL_SPELLS
    fmSpellbook.tab2.gwTipLabel = GW.myLocalizedClass
    fmSpellbook.tab3.gwTipLabel = specName
    fmSpellbook.tab4.gwTipLabel = PVP_LABEL_PVP_TALENTS
    fmSpellbook.tab5.gwTipLabel = PET

    fmSpellbook.tab1:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab1:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab2:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab2:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab3:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab3:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab4:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab4:SetScript("OnLeave", GameTooltip_Hide)
    fmSpellbook.tab5:SetScript("OnEnter", spellTab_OnEnter)
    fmSpellbook.tab5:SetScript("OnLeave", GameTooltip_Hide)

    -- set tab 2/3 to class/spec icon
    SetClassIcon(fmSpellbook.tab2.icon, GW.myClassID)
    setSpecTabIconAndTooltip(fmSpellbook.tab3)

    GwTalentFrame:HookScript(
        "OnShow",
        function()
            if InCombatLockdown() then
                return
            end
            updateTab(fmSpellbook)
            updateActiveSpec()
        end
    )

    -- TODO: not sure if we want these or not
    hooksecurefunc("ToggleTalentFrame", toggleTalentFrame)
    hooksecurefunc("ToggleSpellBook", toggleSpellBook)

    return GwTalentFrame
end
GW.LoadTalents = LoadTalents
