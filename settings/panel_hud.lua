local _, GW = ...
local L = GW.L
local addOption = GW.AddOption
local addOptionButton = GW.AddOptionButton
local addOptionSlider = GW.AddOptionSlider
local addOptionDropdown = GW.AddOptionDropdown
local createCat = GW.CreateCat
local GetSetting = GW.GetSetting
local InitPanel = GW.InitPanel

local function LoadHudPanel(sWindow)
    local p = CreateFrame("Frame", nil, sWindow.panels, "GwSettingsPanelScrollTmpl")
    p.header:SetFont(DAMAGE_TEXT_FONT, 20)
    p.header:SetTextColor(255 / 255, 241 / 255, 209 / 255)
    p.header:SetText(UIOPTIONS_MENU)
    p.sub:SetFont(UNIT_NAME_FONT, 12)
    p.sub:SetTextColor(181 / 255, 160 / 255, 128 / 255)
    p.sub:SetText(L["Edit the modules in the Heads-Up Display for more customization."])

    createCat(UIOPTIONS_MENU, L["Edit the HUD modules."], p, 3, nil, {p})

    addOption(p.scroll.scrollchild, L["Show HUD background"], L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"], "HUD_BACKGROUND", GW.ToggleHudBackground )
    addOption(p.scroll.scrollchild, L["Dynamic HUD"], L["Enable or disable the dynamically changing HUD background."], "HUD_SPELL_SWAP", nil, nil, {["HUD_BACKGROUND"] = true})
    addOption(p.scroll.scrollchild, L["AFK Mode"], L["When you go AFK, display the AFK screen."], "AFK_MODE", GW.ToggelAfkMode)
    addOption(p.scroll.scrollchild, L["Mark Quest Reward"], L["Marks the most valuable quest reward with a gold coin."], "QUEST_REWARDS_MOST_VALUE_ICON", function() GW.ResetQuestRewardMostValueIcon() end)
    addOption(p.scroll.scrollchild, L["XP Quest Percent"], L["Shows the xp you got from that quest in % based on your current needed xp for next level."], "QUEST_XP_PERCENT")
    addOptionSlider(
        p.scroll.scrollchild,
        L["Maximum lines of 'Copy Chat Frame'"],
        L["Set the maximum number of lines displayed in the Copy Chat Frame"],
        "CHAT_MAX_COPY_CHAT_LINES",
        nil,
        50,
        500,
        nil,
        0,
        {["CHATFRAME_ENABLED"] = true},
        1
    )
    addOption(p.scroll.scrollchild, L["Toggle Compass"], L["Enable or disable the quest tracker compass."], "SHOW_QUESTTRACKER_COMPASS", function() GW.ShowRlPopup = true end, nil, {["QUESTTRACKER_ENABLED"] = true})
    addOption(p.scroll.scrollchild, L["Fade Menu Bar"], L["The main menu icons will fade when you move your cursor away."], "FADE_MICROMENU", function() GW.ShowRlPopup = true end)
    addOption(p.scroll.scrollchild, DISPLAY_BORDERS, nil, "BORDER_ENABLED", GW.ToggleHudBackground)
    addOption(p.scroll.scrollchild, L["Show Coordinates on World Map"], L["Show Coordinates on World Map"], "WORLDMAP_COORDS_TOGGLE", GW.ToggleWorldMapCoords)
    addOption(p.scroll.scrollchild, L["Show FPS on minimap"], L["Show FPS on minimap"], "MINIMAP_FPS", GW.ToogleMinimapFpsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(p.scroll.scrollchild, L["Show Coordinates on Minimap"], L["Show Coordinates on Minimap"], "MINIMAP_COORDS_TOGGLE", GW.ToogleMinimapCoorsLable, nil, {["MINIMAP_ENABLED"] = true}, "Minimap")
    addOption(p.scroll.scrollchild, L["Fade Group Manage Button"], L["The Group Manage Button will fade when you move the cursor away."], "FADE_GROUP_MANAGE_FRAME", function() GW.ShowRlPopup = true end, nil, {["PARTY_FRAMES"] = true})
    addOption(
        p.scroll.scrollchild,
        L["Pixel Perfect Mode"],
        L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."],
        "PIXEL_PERFECTION",
        function()
            C_CVar.SetCVar("useUiScale", "0")
            GW.PixelPerfection()
        end
    )

    local encounterfKeys, encounterVales = {}, {}
    local settingstable = GetSetting("boss_frame_extra_energy_bar")
    for encounterId, _ in pairs(GW.bossFrameExtraEnergyBar) do
        if encounterId and EJ_GetEncounterInfo(encounterId) then
            local encounterName, _, _, _, _, instanceId = EJ_GetEncounterInfo(encounterId)
            local instanceName = instanceId and EJ_GetInstanceInfo(instanceId)
            local name = format("%s |cFF888888(%s)|r", encounterName, instanceName or UNKNOWN)
            tinsert(encounterfKeys, encounterId)
            tinsert(encounterVales, name)

            if settingstable[encounterId] == nil then
                local newTable = GW.copyTable(nil, settingstable)
                newTable[encounterId] = {
                    enable = true,
                    npcIds = GW.copyTable(nil, GW.bossFrameExtraEnergyBar[encounterId].npcIds),
                }

                GW.SetSetting("boss_frame_extra_energy_bar", newTable)
                settingstable = GetSetting("boss_frame_extra_energy_bar")
            end

            GW.bossFrameExtraEnergyBar[encounterId].enable = settingstable[encounterId].enable
        end
    end

    addOptionDropdown(
        p.scroll.scrollchild,
        L["Boss frames: Separate Energy Bar"],
        L["If enabled, enabled bosses’ energy bars will be shown separately from their health bar."],
        "boss_frame_extra_energy_bar",
        function(toSet, id)
            GW.bossFrameExtraEnergyBar[id].enable = toSet
        end,
        encounterfKeys,
        encounterVales,
        nil,
        nil,
        true,
        nil,
        "encounter"
    )

    addOptionDropdown(
        p.scroll.scrollchild,
        COMBAT_TEXT_LABEL,
        COMBAT_SUBTEXT,
        "GW_COMBAT_TEXT_MODE",
        function() GW.ShowRlPopup = true end,
        {"GW2", "BLIZZARD", "OFF"},
        {GW.addonName, "Blizzard", OFF .. " / " .. OTHER .. " " .. ADDONS},
        nil,
        nil,
        nil,
        "FloatingCombatText"
    )
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Use Blizzard colors"], nil, "GW_COMBAT_TEXT_BLIZZARD_COLOR", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOption(p.scroll.scrollchild, COMBAT_TEXT_LABEL .. L[": Show numbers with commas"], nil, "GW_COMBAT_TEXT_COMMA_FORMAT", nil, nil, {["GW_COMBAT_TEXT_MODE"] = "GW2"}, "FloatingCombatText")
    addOptionSlider(
        p.scroll.scrollchild,
        L["HUD Scale"],
        L["Change the HUD size."],
        "HUD_SCALE",
        GW.UpdateHudScale,
        0.5,
        1.5,
        nil,
        2
    )
    addOptionButton(p.scroll.scrollchild, L["Apply to all"], L["Applies the UI scale to all frames which can be scaled in 'Move HUD' mode."], nil, function()
        local scale = GetSetting("HUD_SCALE")
        for _, mf in pairs(GW.scaleableFrames) do
            mf.gw_frame:SetScale(scale)
            mf:SetScale(scale)
            GW.SetSetting(mf.gw_Settings .."_scale", scale)
        end
    end)
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Show Role Bar"],
        L["Whether to display a floating bar showing your group or raid's role composition. This can be moved via the 'Move HUD' interface."],
        "ROLE_BAR",
        GW.UpdateRaidCounterVisibility,
        {"ALWAYS", "NEVER", "IN_GROUP", "IN_RAID", "IN_RAID_IN_PARTY"},
        {
            ALWAYS,
            NEVER,
            AGGRO_WARNING_IN_PARTY,
            L["In raid"],
            L["In group or in raid"],
        }
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Minimap details"],
        L["Always show Minimap details."],
        "MINIMAP_HOVER",
        GW.SetMinimapHover,
        {"NONE", "ALL", "CLOCK", "ZONE", "COORDS", "CLOCKZONE", "CLOCKCOORDS", "ZONECOORDS"},
        {
            NONE_KEY,
            ALL,
            TIMEMANAGER_TITLE,
            ZONE,
            L["Coordinates"],
            TIMEMANAGER_TITLE .. " + " .. ZONE,
            TIMEMANAGER_TITLE .. " + " .. L["Coordinates"],
            ZONE .. " + " .. L["Coordinates"]
        },
        nil,
        {["MINIMAP_ENABLED"] = true},
        nil,
        "Minimap"
    )
    addOptionSlider(
        p.scroll.scrollchild,
        L["Minimap Scale"],
        L["Change the Minimap size."],
        "MINIMAP_SCALE",
        function()
            local size = GetSetting("MINIMAP_SCALE")
            Minimap:SetSize(size, size)
            Minimap.gwMover:SetSize(size, size)
        end,
        160,
        420,
        nil,
        0,
        {["MINIMAP_ENABLED"] = true},
        1
    )
    addOptionDropdown(
        p.scroll.scrollchild,
        L["Auto Repair"],
        L["Automatically repair using the following method when visiting a merchant."],
        "AUTO_REPAIR",
        nil,
        {"NONE", "PLAYER", "GUILD"},
        {
            NONE_KEY,
            PLAYER,
            GUILD,
        }
    )
    addOptionSlider(
        p.scroll.scrollchild,
        GW.NewSign .. L["Extended Vendor"],
        L["The number of pages shown in the merchant frame. Set 1 to disable."],
        "EXTENDED_VENDOR_NUM_PAGES",
        function() GW.ShowRlPopup = true end,
        1,
        6,
        nil,
        0,
        nil,
        1
    )

    InitPanel(p, true)
end
GW.LoadHudPanel = LoadHudPanel
