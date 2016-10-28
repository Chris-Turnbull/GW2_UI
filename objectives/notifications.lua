local cTitle =''
local cDesc = ''
local currentNotificationKey = ''

local icons = {}
icons['QUEST'] ={tex ='icon-objective', l=0,r=1,t=0.25,b=0.5}
icons['EVENT'] ={tex='icon-objective',l=0,r=1,t=0.5,b=0.75}
icons['SCENARIO'] ={tex='icon-objective',l=0,r=1,t=0.75,b=1}
icons['BOSS'] ={tex='icon-boss',l=0,r=1,t=0,b=1}

local function prioritys(a,b)
    
    if a=='SCENARIO' and b=='EVENT' then return false end
    if a=='SCENARIO' and b=='BOSS' then return false end
        
    return true
    
end

function gwRemoveNotification(key)
    if currentNotificationKey==key then
        currentNotificationKey=''
    
        GwObjectivesNotification:SetHeight(1)
       
        addToAnimation('notificationToggle', 70,1,GetTime(),0.2,function(step) 
                GwObjectivesNotification:SetHeight(step)
        end,nil, function()
            GwObjectivesNotification:Hide() 
        end)
        
        gwQuestTrackerLayoutChanged()
 
    end
end
function gwSetObjectiveNotification(key, title, desc, color)
    
    if color==nil then color = {r=1,g=1,b=1} end
    
    if currentNotificationKey==key or not prioritys() then return end

    currentNotificationKey = key
    
    if icons[key]~=nil then
         GwObjectivesNotification.icon:SetTexture('Interface\\AddOns\\GW2_UI\\textures\\'..icons[key].tex)
         GwObjectivesNotification.icon:SetTexCoord(icons[key].l,icons[key].r,icons[key].t,icons[key].b)   
    else
        GwObjectivesNotification.icon:SetTexture(nil)
    end
    
    GwObjectivesNotification.title:SetText(title)
    GwObjectivesNotification.title:SetTextColor(color.r,color.g,color.b)
    GwObjectivesNotification.desc:SetText(desc)
    
    if not GwObjectivesNotification:IsShown() then
        GwObjectivesNotification:Show()
        addToAnimation('notificationToggle', 1,70,GetTime(),1,function(step) 
            GwObjectivesNotification:SetHeight(step)
        end)
    end
    
    gwQuestTrackerLayoutChanged()
    
end