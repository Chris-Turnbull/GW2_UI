-- zhTW localization
local L = LibStub("AceLocale-3.0"):NewLocale("GW2_UI", "zhTW")
if not L then return end

--Fonts
L["FONT_NORMAL"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
L["FONT_BOLD"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
L["FONT_NARROW"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
L["FONT_NARROW_BOLD"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
L["FONT_LIGHT"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"
L["FONT_DAMAGE"] = "Interface/AddOns/GW2_UI/fonts/chinese-font.ttf"

--Strings
L["Use the GW2 UI improved action bars."] = "使用 GW2 UI 風格加強型的快捷列。"
L["Fade Action Bars"] = "淡出快捷列"
L["Advanced Tooltips"] = "進階滑鼠提示"
L["Displays additional information in the tooltip (further information is displayed when the SHIFT key is pressed)"] = "在滑鼠提示中顯示更多資訊 (按住 SHIFT 鍵來顯示)"
L["Item Count"] = "物品數量"
L["Display how many of a certain item you have in your possession."] = "顯示某樣物品你擁有多少數量。"
L["Gender"] = "性別"
L["Displays the player character's gender."] = "顯示玩家角色的性別。"
L["Display guild ranks if a unit is a member of a guild."] = "如果單位有公會，顯示會階。"
L["Current Mount"] = "目前坐騎"
L["Display current mount the unit is riding."] = "顯示單位目前正在騎的坐騎資訊。"
L["Display player titles."] = "顯示玩家頭銜。"
L["Always Show Realm"] = "總是顯示伺服器"
L["Display the unit role in the tooltip."] = "在滑鼠提示中顯示單位的角色職責。"
L["Target Info"] = "目標資訊"
L["When in a raid group, show if anyone in your raid is targeting the current tooltip unit."] = "在團隊中時，顯示將目前的滑鼠提示單位選取為目標的人。"
L["Advanced Casting Bar"] = "進階施法條"
L["Enable or disable the advanced casting bar."] = "啟用或停用進階的施法條。"
L["AFK Mode"] = "AFK 模式"
L["When you go AFK, display the AFK screen."] = "AFK 時顯示暫離畫面。"
L["Alert Frames"] = "通知框架"
L["Cursor Anchor Left"] = "游標左側"
L["Only takes effect if the option 'Cursor Tooltips' is activated and the cursor anchor is NOT 'Cursor Anchor'"] = "只有啟用 '滑鼠提示跟隨游標'，而且跟隨游標位置不是 '游標指向點' 時才有效果。"
L["Cursor Anchor Offset X"] = "跟隨游標水平偏移"
L["Cursor Anchor Offset Y"] = "跟隨游標垂直偏移"
L["Cursor Anchor Right"] = "游標右側"
L["Apply UI scale to all scaleable frames"] = "套用介面縮放到所有可縮放的框架"
L["Applies the UI scale to all frames, which can be scaled in 'Move HUD' mode."] = "介面縮放大小套用到所有在 '移動介面' 模式中能夠縮放大小的框架。"
L["Ascending"] = "遞增"
L["Auras per row"] = "每列光環數量"
L["Aura Style"] = "光環樣式"
L["Auto Repair"] = "自動修裝"
L["Automatically repair using the following method when visiting a merchant."] = "和商人對話時，依據下列規則自動修理裝備。"
L["Reverse Bag Order"] = "反向背包順序"
L["Sort to Last Bag"] = "排序到最後的背包"
L["Compact Icons"] = "小圖示"
L["Action Button Labels"] = "顯示快捷鍵"
L["Enable or disable the action button assignment text"] = "啟用或停用快捷列上的按鍵提示文字。"
L["Enable the GW2 style casting bar."] = "使用 GW2 UI 風格的施法條。"
L["Changelog"] = "更新資訊"
L["Paragon"] = "巔峰"
L["Replace the default UI chat bubbles. (Only in not protected areas)"] = "取代預設的聊天泡泡。(只在允許更改聊天泡泡的區域/副本外面)"
L["Fade Chat"] = "淡出聊天視窗"
L["Allow the chat to fade when not in use."] = "非使用中時淡出聊天視窗。"
L["Enable the improved chat window."] = "使用加強型的聊天視窗。"
L["Replace the default character window."] = "取代預設的角色資訊視窗。"
L["Display the class color as the health bar."] = "血量條使用職業顏色。"
L["Use the class color instead of class icons."] = "使用職業顏色而不是職業圖示。"
L["Class Power"] = "職業特殊能量"
L["Enable the alternate class powers."] = "顯示職業特殊能量。"
L["Class Totems"] = "職業圖騰"
L["Toggle Compass"] = "顯示羅盤"
L["Enable or disable the quest tracker compass."] = "啟用或停用任務追蹤清單的羅盤。"
L["Copy of"] = "複製的"
L["Cursor Anchor"] = "游標指向點"
L["Cursor Anchor Type"] = "跟隨游標位置"
L["Only takes effect if the option 'Cursor Tooltips' is activated"] = "只有啟用 '滑鼠提示跟隨游標' 時才有效果。"
L["Only displays the debuffs that you are able to dispell."] = "只顯示你可以驅散的減益效果。"
L["Decode"] = "解析"
L["Descending"] = "遞減"
L["MoveAnything bag handling disabled."] = "已停用版面配置插件 MoveAnything 的背包調整功能。"
L["Join Discord"] = "加入 Discord"
L["Display Portrait Damage"] = "頭像上顯示傷害"
L["Display Portrait Damage on this frame"] = "在此框架頭像上面顯示傷害數字。"
L["Down"] = "下"
L["Down and right"] = "右下"
L["Dynamic HUD"] = "動態 HUD 背景"
L["Enable or disable the dynamically changing HUD background."] = "啟用或停用動態變換主要快捷列後方的 HUD 背景。"
L["Export"] = "匯出"
L["Export Profile"] = "匯出設定檔"
L["Profile string to share your settings:"] = "分享設定用的設定檔字串:"
L["Rested "] = "休息加成"
L[" (Resting)"] = " (休息中)"
L["Boss Button"] = "首領按鈕"
L["Fade Group Manage Button"] = "淡出隊伍管理按鈕"
L["The Group Manage Button will fade when you move the cursor away."] = "淡出隊伍管理按鈕，滑鼠游標靠近時才會顯示。"
L["Fade Menu Bar"] = "淡出微型選單"
L["The main menu icons will fade when you move your cursor away."] = "隱藏畫面左上角的微型選單，滑鼠游標靠近時才顯示。"
L["Modify the focus frame settings."] = "調整專注目標框架的設定。"
L["Enable the focus target frame replacement."] = "取代專注目標框架。"
L["Display the focus target frame."] = "顯示專注目標的目標框架。"
L["Fonts"] = "字型"
L["Replace the default fonts withGw2 UI fonts."] = "使用 GW2 UI 字型。"
L["Hide grid"] = "隱藏格子"
L["Show grid"] = "顯示格子"
L["Grid Size:"] = "格子大小:"
L["WM"] = "世界標記"
L["Edit the party and raid options to suit your needs."] = "編輯小隊和團隊選項以符合你的需求。"
L["Group Frames"] = "隊伍框架"
L["Replace the default UI group frames."] = "取代預設的團隊和小隊框架。"
L["Edit the group settings."] = "編輯隊伍設定。"
L[": Use Blizzard colors"] = ": 使用暴雪顏色"
L[": Show numbers with commas"] = ": 數字顯示逗號"
L["Health Globe"] = "血球"
L["Enable the health bar replacement."] = "取代血條。"
L["Display health as a percentage. Can be used as well as, or instead of Health Value."] = "顯示血量百分比，可以單獨顯示或和血量數值一起顯示。"
L["Show health as a numerical value."] = "顯示血量數值。"
L["Hide Empty Slots"] = "隱藏空欄位"
L["Hide the empty action bar slots."] = "隱藏空的快捷列欄位。"
L["Settings are not available in combat!"] = "戰鬥中無法設定!"
L["Horizontal"] = "水平"
L["Show HUD background"] = "顯示 HUD 背景"
L["The HUD background changes color in the following situations: In Combat, Not In Combat, In Water, Low HP, Ghost"] = "在這些情況下，主要快捷列後方的 HUD 背景會隨之變化: 戰鬥中、非戰鬥中、在水中、低血量、鬼魂狀態。"
L["Edit the modules in the Heads-Up Display for more customization."] = "編輯 HUD 模組，打造喜愛的介面。"
L["You can not move elements during combat!"] = "戰鬥中無法移動介面!"
L["HUD Scale"] = "介面縮放"
L["Change the HUD size."] = "更改介面大小。"
L["Edit the HUD modules."] = "編輯 HUD 介面模組。"
L["Import"] = "匯入"
L["Import string successfully decoded!"] = "匯入字串解析完成!"
L["Error decoding profile: Invalid or corrupt string!"] = "解析設定檔錯誤: 字串無效或已損毀!"
L["Error importing profile: Invalid or corrupt string!"] = "匯入設定檔錯誤: 字串無效或已損毀!"
L["Import Profile"] = "匯入設定檔"
L["Paste your profile string here to import the profile."] = "在這裡貼上設定檔字串來匯入設定檔。"
L["Import string successfully imported!"] = "字串匯入完成!"
L["Raid Indicators"] = "團隊光環圖示"
L["Edit raid aura indicators."] = "編輯團隊框架上面增益和減益效果的指示圖示。"
L["Show Spell Icons"] = "顯示法術圖示"
L["Show spell icons instead of monochrome squares."] = "顯示法術圖示，而不是單色的方塊。"
L["Show Remaining Time"] = "顯示剩餘時間"
L["Show the remaining aura time as an animated overlay."] = "用動畫效果顯示光環的剩餘時間。"
L["Edit %s raid aura indicator."] = "編輯%s團隊光環指示圖示。"
L["%s Indicator"] = "%s圖示"
L["Setup Chat"] = "設定聊天視窗"
L["This part sets up your chat window names, positions, and colors."] = "這部分會設定聊天視窗名稱、位置和顏色。"
L["Setup CVars"] = "設定 CVars 遊戲預設參數"
L["This part sets up your World of Warcraft default options."] = "這部分會設定魔獸世界選項的預設值。"
L["This short installation process will help you to set up all of the necessary settings used by GW2 UI."] = "這個簡短的安裝程序，會幫你設定好使用 GW2 UI 所有需要的設定，"
L["GW2 UI installation"] = "安裝 GW2 UI "
L["Complete"] = "結束"
L["You have now finished installing GW2 UI!"] = "GW2 UI 現在已經安裝完成了!"
L["Installation Complete"] = "安裝完成"
L["Start installation"] = "開始安裝"
L["Installation"] = "安裝程序"
L["Enable the unified inventory interface."] = "使用整合背包介面。"
L["Left"] = "左側"
L["Upcoming Level Rewards"] = "即將獲得的升級獎勵"
L["Main Bar Range Indicator"] = "主要快捷列超出範圍指示"
L["Map Coordinates"] = "地圖坐標"
L["Left Click to toggle higher precision coordinates."] = "點一下切換坐標的精確度。"
L["Micro Bar"] = "微型系統菜單"
L["Coordinates"] = "坐標"
L["Show Coordinates on Minimap"] = "小地圖顯示坐標"
L["Use the GW2 UI Minimap frame."] = "使用 GW2 UI 小地圖框架。"
L["Show FPS on minimap"] = "小地圖上顯示 FPS"
L["Minimap details"] = "小地圖資訊"
L["Always show Minimap details."] = "永遠顯示小地圖詳細資訊內容。"
L["Minimap Scale"] = "小地圖縮放"
L["Change the Minimap size."] = "更改小地圖大小。"
L["MODULES"] = "模組"
L["Modules"] = "模組"
L["Enable and disable components"] = "啟用或停用元件"
L["Enable or disable the modules you need and don't need."] = "啟用或停用需要和不需要使用的模組。"
L["Only on Mouse Over"] = "只有滑鼠指向時"
L["Cursor Tooltips"] = "滑鼠提示跟隨游標"
L["Anchor the tooltips to the cursor."] = "在滑鼠游標的位置顯示滑鼠提示。"
L["Move HUD"] = "移動介面"
L["No Guild"] = "沒有公會"
L["Use the GW2 UI improved Pet bar."] = "使用 GW2 UI 風格加強型的寵物列。"
L["Pixel Perfect Mode"] = "完美細緻模式"
L["Scales the UI into a Pixel Perfect Mode. This is dependent on screen resolution."] = "介面縮放成完全符合像素的模式，會依據畫面的解析度而定。"
L["Turn Pixel Perfect Mode On"] = "開啟完美細緻模式"
L["Show Shield Value"] = "顯示護盾值"
L["Move and resize the player auras."] = "移動和縮放玩家光環。"
L["Player Buff Growth Direction"] = "玩家增益圖示延伸方向"
L["Buff size"] = "增益圖示大小"
L["Player Debuffs Growth Direction"] = "玩家減益圖示延伸方向"
L["Debuff size"] = "減益圖示大小"
L["Modify the player frame settings."] = "調整玩家框架的設定。"
L["Dodge Bar Ability"] = "閃躲條技能"
L["Enter the spell ID which should be tracked by the dodge bar.\nIf no ID is entered, the default abilities based on your specialization and talents are tracked."] = "輸入閃躲條要追蹤的法術 ID。\n如果沒有輸入 ID，會依據你的專精和天賦來追蹤預設的技能。"
L["Player frame in group"] = "隊伍中也要顯示自己"
L["Show your player frame as part of the group"] = "在隊伍框架中顯示玩家自己。"
L["Display the power bars on the raid units."] = "顯示隊友的能量條。"
L["Show Profession Bag Coloring"] = "專業背包著色"
L["PROFILES"] = "設定檔"
L["Profiles"] = "設定檔"
L["Created: "] = "建立時間: "
L["\nCreated by: "] = "\n建立角色: "
L["Default Settings"] = "載入預設值"
L["Load the default addon settings to the current profile."] = "載入插件的預設設定到當前設定檔。"
L["Are you sure you want to load the default settings?\n\nAll previous settings will be lost."] = "是否確定要恢復為預設設定?\n\n將會失去先前更改過的所有設定。"
L["Are you sure you want to delete this profile?"] = "是否確定要刪除這個設定檔?"
L["Profiles are an easy way to share your settings across characters and realms."] = "設定檔可以讓多個角色和不同伺服器共用相同設定，是最簡單的方式。"
L["\nLast updated: "] = "\n上次更新: "
L["Load"] = "載入"
L["Text has not loaded."] = "看到這個訊息時表示我們忘記載入一些文字。不過不用擔心，會有一些適合的範例文字來告訴您相關資訊，就像現在這樣。"
L["Add and remove profiles."] = "新增和移除設定檔。"
L["Immersive Questing"] = "身歷其境的任務對話"
L["Enable the immersive questing view."] = "使用身歷其境的任務畫面。"
L["Required Items:"] = "需要物品:"
L["Enable the revamped and improved quest tracker."] = "使用重新製作加強型的任務追蹤清單。"
L["Skip"] = "繼續"
L["Set Raid Anchor"] = "設定團隊對齊點"
L["By growth direction"] = "依據延伸方向"
L["By position on screen"] = "依據畫面上的位置"
L["Set where the raid frame container should be anchored.\n\nBy position: Always the same as the container's position on screen.\nBy growth: Always opposite to the growth direction."] = "設定整個團隊框架要如何對齊。\n\n依據位置: 永遠和整個框架在畫面上的位置相同。\n依據延伸: 永遠和框架延伸的方向相反。"
L["Raid Auras"] = "團隊光環"
L["Edit which buffs and debuffs are shown."] = "編輯要顯示哪些增益和減益效果。"
L["Ignored Auras"] = "忽略光環"
L["A list of auras that should never be shown."] = "永遠不要顯示的光環名稱清單，使用逗號分隔。"
L["Missing Buffs"] = "缺少光環"
L["A list of buffs that should only be shown when they are missing."] = "只有缺少時才要顯示的光環名稱清單，使用逗號分隔。"
L["Show or hide auras and edit raid aura indicators."] = "顯示或隱藏光環，以及編輯增益/減益圖示。"
L["Show Aura Tooltips in Combat"] = "戰鬥中顯示光環的滑鼠提示"
L["Show tooltips of buffs and debuffs even when you are in combat."] = "即使是在戰鬥中也要顯示增益和減益效果的滑鼠提示說明。"
L["Set Raid Unit Height"] = "團隊單位高度"
L["Set the height of the raid units."] = "設定一個團隊單位的高度。"
L["Set Raid Unit Width"] = "團隊單位高度"
L["Set the width of the raid units."] = "設定一個團隊單位的寬度。"
L["Set Raid Frame Container Height"] = "團隊框架整體高度"
L["Set the maximum height that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next column."] = "設定整個團隊框架可以顯示的最大高度。\n\n單位框架會隨之縮小或移動到下一行。"
L["Set Raid Frame Container Width"] = "團隊框架整體寬度"
L["Set the maximum width that the raid frames can be displayed.\n\nThis will cause unit frames to shrink or move to the next row."] = "設定整個團隊框架可以顯示的最大寬度。\n\n單位框架會隨之縮小或移動到下一列。"
L["Set Raid Growth Direction"] = "設定團隊延伸方向"
L["Set the grow direction for raid frames."] = "設定團隊框架增長延伸的方向。"
L["%s and then %s"] = "先%s再%s"
L["Displays the Target Markers on the Raid Unit Frames"] = "在團隊框架上面顯示目標標記圖示"
L["Preview Raid Frames"] = "預覽團隊框架"
L["Click to toggle raid frame preview and cycle through different group sizes."] = "點一下切換預覽團隊框架，多次點擊切換不同的隊伍大小。"
L["Dungeon & Raid Debuffs"] = "地城 & 團隊減益"
L["Show important Dungeon & Raid debuffs"] = "顯示重要的地城 & 團隊減益效果。"
L["Sort Raid Frames by Role"] = "依角色職責排序團隊框架"
L["Sort raid unit frames by role (tank, heal, damage) instead of group."] = "依據角色職責排序團隊框架 (坦克、治療者、傷害輸出) 而不是隊伍。"
L["Set Raid Units per Column"] = "設定團隊每行數量"
L["Set the number of raid unit frames per column or row, depending on grow directions."] = "依據延伸方向，設定每一行或每一列的團隊框架單位數量。"
L["Show Country Flag"] = "顯示國旗"
L["Different Than Own"] = "和我不同的"
L["Display a country flag based on the unit's language"] = "根據玩家所使用的語言顯示國旗。"
L["Red Overlay"] = "覆蓋紅色"
L["Your items have been repaired for: %s"] = "已修理裝備，共支出: %s"
L["Your items have been repaired using guild bank funds for: %s"] = "已使用公會資金修理裝備，共支出: %s"
L["Replace the default mana/power bar."] = "取代法力/能量條。"
L["Loot to leftmost Bag"] = "拾取到最左側的背包"
L["Right"] = "右側"
L["Secure"] = "安全"
L["Selling junk"] = "賣垃圾"
L["Separate bags"] = "分離背包"
L["New Bag Name"] = "新背包名稱"
L["Right click to customize the bag title."] = "點一下右鍵自訂背包標題"
L["Save and Reload"] = "儲存並重新載入"
L["Lock HUD"] = "鎖定介面"
L["Display all of the target's debuffs."] = "顯示目標身上全部的減益效果。"
L["Display the target's buffs."] = "顯示目標的增益效果。"
L["Display the target's debuffs that you have inflicted."] = "顯示目標身上由你所施放的減益效果。"
L["Display Average Item Level"] = "顯示平均物品等級"
L["Display the average item level instead of prestige level for friendly units."] = "友方單位顯示平均物品等級，而不是聲望等級。"
L["Show Junk Icon"] = "顯示垃圾圖示"
L["Show Quality Color"] = "顯示品質顏色"
L["Show Scrap Icon"] = "顯示 Scrap 圖示"
L["Show Threat"] = "顯示仇恨值"
L["Show Upgrade Icon"] = "顯示升級圖示"
L["Scale with Right Click"] = "點一下右鍵來縮放大小"
L["Right click on a moverframe to show extra frame options"] = "在可移動的框架上面點右鍵以顯示更多選項。"
L["Extra Frame Options"] = "更多框架選項"
L["No extra frame options for '%s'"] = "'%s' 沒有更多的框架選項"
L["Scale"] = "縮放大小"
L["Stance Bar Position"] = "姿勢形態列位置"
L["Set the position of the stance bar (left or right from the main action bar)."] = "設定姿勢形態列的位置 (在主要快捷列的左側或右側)。"
L["Right Bar Width"] = "右方快捷列寬度"
L["Number of columns in the two extra right-hand action bars."] = "兩個右方額外快捷列的直行數。"
L["Enable the talents, specialization, and spellbook replacement."] = "取代預設的天賦、專精和法術書視窗。"
L["Targeted by:"] = "被關注:"
L["Show Combo Points on Target"] = "在目標框架顯示連擊點數"
L["Show combo points on target, below the health bar."] = "在目標框架的血條下方顯示連擊點數。"
L["Modify the target frame settings."] = "調整選取目標框架的設定。"
L["Enable the target frame replacement."] = "取代選取目標框架。"
L["Enable the target of target frame."] = "顯示選取目標的目標框架。"
L["Edit the target frame settings."] = "編輯選取目標框架的設定。"
L["Tooltips"] = "滑鼠提示"
L["Replace the default UI tooltips."] = "取代預設的滑鼠提示。"
L["Modifier for IDs"] = "顯示 ID 的組合按鍵"
L["Top"] = "上方"
L["Class Totems Growth Direction"] = "職業圖騰延伸方向"
L["Class Totems Sorting"] = "職業圖騰排序"
L["Retrieve your corpse"] = "撿屍體"
L["Up"] = "上"
L["New update available for download."] = "有新版本! 已有更新可供下載。"
L["New update available containing new features."] = "有新版本! 包含新功能的更新可供下載。"
L["A |cFFFF0000major|r update is available.\nIt's strongly recommended that you update."] = "有新版本! 包含|cFFFF0000重大更新|r可供下載。\n強烈建議更新插件。"
L["Up and right"] = "右上"
L["Sell junk automatically"] = "自動賣垃圾"
L["Vertical"] = "垂直"
L["Welcome"] = "歡迎使用"
L["Welcome to GW2 UI"] = "歡迎使用 GW2 UI"
L["GW2 UI is a full user interface replacement. We have built the user interface with a modular approach, this means that if you dislike a certain part of the addon - or have another you prefer for that function - you can just disable that part, while keeping the rest of the interface intact.\nSome of the modules available to you are an immersive questing window, a full inventory replacement, as well as a full character window replacement. There are many more that you can enjoy, just take a look in the settings menu to see what's available to you!"] = "GW2 UI 是一套完整的使用者介面，用來取代原本的遊戲介面。我們使用模組化的方式來建立這個使用者介面，意思是說，如果你不喜歡插件的某個部分，或是偏好使用其他插件的同類型功能，只要單獨停用該部分即可，仍然可以保持介面銜接的完整性。\nGW2 UI 提供的模組包含身歷其境的任務視窗，完整的背包和角色視窗替換介面，只要看一下設定選項，將會發現更多可供使用、你會喜愛的功能!"
L["What is 'Pixel Perfect'?\n\nGW2 UI has a built-in setting called 'Pixel Perfect Mode'. What this means for you is that your user interface will look as was intended, with crisper textures and better scaling. Of course, you can toggle this off in the settings menu should you prefer."] = "什麼是 '完美細緻'?\n\nGW2 UI 內建了一項設定叫做 '完美細緻模式'，擁有更清晰的材質和更佳的縮放大小處理，讓每一個像素都趨近完美，使用者介面看起來能夠完全符合你的期望。當然，完全可以依據你的喜好來開關這個設定。"
L["Show Coordinates on World Map"] = "世界地圖顯示坐標"
L["Show menu for placing world markers when in raids."] = "在團隊中時顯示世界標記工具。"
L["Zone Ability"] = "區域技能"
L["GW2 UI Update"] = "GW2 UI 更新"
L["Bar"] = "條列"
L["Top Left"] = "左上"
L["Top Right"] = "右上"
L["Center"] = "中間"
L["Player frame in target frame style"] = "目標框架樣式的播放器框架"
L["PvP Indicator"] = "PvP 提示器"
L["Invert target frame"] = "反轉選取目標框架"
L["Invert focus frame"] = "反轉專注目標框架"
L["Talking Head"] = "特寫框架"
L["Skins"] = "美化外觀"
L["Adjust Skin settings."] = "調整外觀設定."
L["Blizzard Class Colors"] = "暴雪預設職業顏色"
L["Popup notifications"] = "彈出通知"
L["Looking for Group notifications"] = "隊伍搜尋器通知"
L["Misc Frames"] = "其他"
L["Developed by"] = "程式設計"
L["With Contributions by"] = "貢獻"
L["Localised by"] = "翻譯"
L["QA Testing by"] = "品管測試"
L["Credits"] = "製作群"
L["Socket Frame"] = "珠寶插槽"
L["Grays"] = "垃圾"
L["Reset Character Data: Hold Shift + Right Click"] = "重置角色數據: 按住 Shift + 右鍵點擊"
L["Reset Session Data: Hold Ctrl + Right Click"] = "重置會話數據: 按住 Ctrl + 右鍵點擊"
L["Session:"] = "本次登入:"
L["Earned:"] = "賺取:"
L["Spent:"] = "花費:"
L["Deficit:"] = "赤字:"
L["Profit:"] = "利潤:"
L["Gossip Frame"] = "對話"
L["Saved Raid(s)"] = "已保存的團隊"
L["Saved Dungeon(s)"] = "已保存的地城"
L["Daily Reset"] = "每日重置"
L["Right Click to change Talent Specialization"] = "點右鍵更改天賦專精"
L["Legacy: Sorted by duration but auras can't cancel via right click in combat\nSecure: Not sorted but auras can cancel via right click in combat"] = "傳統: 依照時間排序，但是戰鬥中無法點右鍵取消光環。\n安全: 不會排序，但是戰鬥中可以點右鍵取消光環。"
L["Weekly Reset"] = "每週重置"
L["Conduits"] = "靈印"
