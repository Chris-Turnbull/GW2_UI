local _, GW = ...
local L = GW.L

local function setFont(fontObject, font, size, style, shadowX, shadowY, shadowA, r, g, b, shadowR, shadowG, shadowB)
    if not fontObject then return end

    local _, oldSize, oldStyle = fontObject:GetFont()

    if not size then
        size = oldSize
    end

    if not style then
        style = oldStyle == "OUTLINE" and "THINOUTLINE" or oldStyle -- keep outlines thin
    end

    fontObject:SetFont(font, size, style)

    if shadowX and shadowY then
        fontObject:SetShadowOffset(shadowX, shadowY)
        fontObject:SetShadowColor(shadowR or 0, shadowG or 0, shadowB or 0, shadowA or 1)
    end
    if r and g and b then
        fontObject:SetTextColor(r, g, b)
    end
end

local function LoadFonts()
    local normal = L["FONT_NORMAL"]
    local bold = L["FONT_BOLD"]
    local narrow = L["FONT_NARROW"]
    local narrowBold = L["FONT_NARROW_BOLD"]
    --local light = L["FONT_LIGHT"]
    local damage = L["FONT_DAMAGE"]

    -- game engine fonts
    UNIT_NAME_FONT = damage
    DAMAGE_TEXT_FONT = bold
    STANDARD_TEXT_FONT = normal

    -- default values
    UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 14
    CHAT_FONT_HEIGHTS = {6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}

    setFont(ChatFontNormal, narrow, nil, nil, 0.75, -0.75, 1)
    --setFont(NumberFontNormal, narrow, 12, "", 1.25, -1.25, 1)
    setFont(SystemFont_Tiny, normal)
    setFont(SystemFont_Small, narrow)
    setFont(SystemFont_Outline_Small, narrow)
    setFont(SystemFont_Outline, normal)
    setFont(SystemFont_Shadow_Small, normal)
    setFont(SystemFont_InverseShadow_Small, normal)
    setFont(SystemFont_Med1, normal)
    setFont(SystemFont_Shadow_Med1, normal)
    setFont(SystemFont_Shadow_Med1_Outline, normal)
    setFont(SystemFont_Med2, normal)
    setFont(SystemFont_Shadow_Med2, normal)
    setFont(SystemFont_Med3, normal)
    setFont(SystemFont_Shadow_Med3, normal)
    setFont(SystemFont_Large, bold)
    setFont(SystemFont_Shadow_Large, bold)
    setFont(SystemFont_Shadow_Large_Outline, bold)
    setFont(SystemFont_Huge1, normal)
    setFont(SystemFont_Shadow_Huge1, normal)
    setFont(SystemFont_OutlineThick_Huge2, bold)
    setFont(SystemFont_Shadow_Outline_Huge2, narrow)
    setFont(SystemFont_Shadow_Huge3, normal)
    setFont(SystemFont_OutlineThick_Huge4, bold)
    setFont(SystemFont_OutlineThick_WTF, normal)
    setFont(SystemFont_Huge2, normal)
    setFont(SpellFont_Small, normal)
    setFont(InvoiceFont_Med, normal)
    setFont(InvoiceFont_Small, normal)
    setFont(AchievementFont_Small, normal)
    setFont(ReputationDetailFont, normal)
    setFont(FriendsFont_Normal, normal)
    setFont(FriendsFont_Small, normal)
    setFont(FriendsFont_Large, bold)
    setFont(FriendsFont_UserText, narrow)
    setFont(GameFont_Gigantic, normal)
    setFont(ChatBubbleFont, normal)
    setFont(Fancy12Font, normal)
    setFont(Fancy14Font, normal)
    setFont(Fancy22Font, normal)
    setFont(Fancy24Font, normal)
    setFont(GameTooltipHeader, bold, 14, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(Tooltip_Med, normal, 12, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(Tooltip_Small, normal, 10, "", -1, -1, 1, 1, 1, 1, 0, 0, 0)
    setFont(NumberFont_Shadow_Small, narrow)
    setFont(NumberFont_OutlineThick_Mono_Small, narrow)
    setFont(NumberFont_Shadow_Med, narrow)
    setFont(NumberFont_Normal_Med, narrow)
    setFont(NumberFont_Outline_Med, narrow)
    setFont(NumberFont_Outline_Large, narrow)
    setFont(NumberFont_Outline_Huge, narrowBold)
    setFont(ErrorFont, narrow, 12, "", 0.75, -0.75, 0.5)
    setFont(ZoneTextFont, narrow, 32, "", 1.25, -1.25, 0.75)
    setFont(SubZoneTextFont, narrow, 24, "", 1.25, -1.25, 0.75)
    setFont(PVPInfoTextFont, narrow, 16, "", 1.25, -1.25, 0.75)
    setFont(RaidWarningFrameSlot1, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidWarningFrameSlot2, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidBossEmoteFrameSlot1, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(RaidBossEmoteFrameSlot2, narrow, nil, "", 0.75, -0.75, 0.75)
    setFont(MailFont_Large, normal)
    setFont(BossEmoteNormalHuge, normal)
    setFont(CoreAbilityFont, normal)
    setFont(DestinyFontHuge, normal)
    setFont(DestinyFontMed, normal)
    setFont(FriendsFont_11, normal)
    setFont(Game10Font_o1, normal)
    setFont(Game120Font, normal)
    setFont(Game12Font, normal)
    setFont(Game13FontShadow, normal)
    setFont(Game15Font_o1, normal)
    setFont(Game16Font, normal)
    setFont(Game18Font, normal)
    setFont(Game24Font, normal)
    setFont(Game30Font, normal)
    setFont(Game40Font, normal)
    setFont(Game42Font, normal)
    setFont(Game46Font, normal)
    setFont(Game48Font, normal)
    setFont(Game48FontShadow, normal)
    setFont(Game60Font, normal)
    setFont(Game72Font, normal)
    setFont(GameFontHighlightMedium, normal)
    setFont(GameFontHighlightSmall2, normal)
    setFont(GameFontNormalHuge2, normal)
    setFont(GameFontNormalLarge, normal)
    setFont(GameFontNormalLarge2, normal)
    setFont(GameFontNormalMed1, normal)
    setFont(GameFontNormalMed2, normal)
    setFont(GameFontNormalMed3, normal)
    setFont(GameFontNormalSmall2, normal)
    setFont(GameTooltipHeader, normal)
    setFont(Number11Font, narrow)
    setFont(Number11Font, narrow)
    setFont(Number12Font, narrow)
    setFont(Number12Font_o1, narrow)
    setFont(Number13Font, narrow)
    setFont(Number13FontGray, narrow)
    setFont(Number13FontWhite, narrow)
    setFont(Number13FontYellow, narrow)
    setFont(Number14FontGray, narrow)
    setFont(Number14FontWhite, narrow)
    setFont(Number15Font, narrowBold)
    setFont(Number18Font, narrowBold)
    setFont(Number18FontWhite, narrowBold)
    setFont(NumberFont_OutlineThick_Mono_Small, narrow)
    setFont(NumberFont_Shadow_Small, normal)
    setFont(NumberFontNormalSmall, normal)
    setFont(PriceFont, normal)
    setFont(PVPArenaTextString, normal)
    setFont(PVPInfoTextString, normal)
    setFont(QuestFont, normal)
    setFont(QuestFont_Enormous, normal)
    setFont(QuestFont_Huge, normal)
    setFont(QuestFont_Large, normal)
    setFont(QuestFont_Shadow_Huge, normal)
    setFont(QuestFont_Shadow_Small, normal)
    setFont(QuestFont_Super_Huge, normal)
    setFont(SubSpellFont, normal)
    setFont(SubZoneTextString, normal)
    setFont(SystemFont_Huge1_Outline, normal)
    setFont(SystemFont_Outline, normal)
    setFont(SystemFont_Shadow_Huge4, normal)
    setFont(SystemFont_Shadow_Large2, normal)
    setFont(ZoneTextString, normal)

    --RaidBossEmoteFrame.timings["RAID_NOTICE_MIN_HEIGHT"] = 12
    --RaidBossEmoteFrame.timings["RAID_NOTICE_MAX_HEIGHT"] = 12
    --RaidBossEmoteFrame.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0
    --RaidBossEmoteFrame.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0

    --RaidWarningFrame.timings["RAID_NOTICE_MIN_HEIGHT"] = 12
    --RaidWarningFrame.timings["RAID_NOTICE_MAX_HEIGHT"] = 12
    --RaidWarningFrame.timings["RAID_NOTICE_SCALE_UP_TIME"] = 0
    --RaidWarningFrame.timings["RAID_NOTICE_SCALE_DOWN_TIME"] = 0

    RaidWarningFrame:SetSize(640, 48)
    RaidBossEmoteFrame:SetSize(640, 56)
end
GW.LoadFonts = LoadFonts
