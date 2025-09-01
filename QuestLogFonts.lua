local function ChangeQuestLogFonts()
    -- Customize these values to your preference
    local newFont = "Fonts\\ARIALN.TTF"  -- Change to your preferred font
    local questListSize = 16  -- Size specifically for quest list titles on the left
    local titleSize = 14  -- Regular title size for quest details
    local textSize = 12   -- Reasonable text size
    local titleFlags = ""  -- Flags for quest titles
    local textFlags = ""  -- Different flags for quest text/descriptions
    
    -- Quest Log Title Text (use title flags)
    if QuestLogTitleText then
        QuestLogTitleText:SetFont(newFont, titleSize, titleFlags)
    end
    
    -- Quest Log Description Text (use text flags) 
    if QuestLogDescriptionText then
        QuestLogDescriptionText:SetFont(newFont, textSize, textFlags)
    end
    
    -- Quest Log Objectives Text (use text flags)
    if QuestLogObjectivesText then
        QuestLogObjectivesText:SetFont(newFont, textSize, textFlags)
    end
    
    -- Quest Log Reward Title Text (use title flags)
    if QuestLogRewardTitleText then
        QuestLogRewardTitleText:SetFont(newFont, titleSize, titleFlags)
    end
    
    -- Quest Log Reward Text (use text flags)
    if QuestLogRewardText then
        QuestLogRewardText:SetFont(newFont, textSize, textFlags)
    end
    
    -- Try to find and change ALL possible quest log text elements
    local questLogFrame = QuestLogFrame
    if questLogFrame then
        -- Scan all child frames for FontString objects
        local function ApplyFontToChildren(frame)
            if not frame then return end
            
            for i = 1, frame:GetNumChildren() do
                local child = select(i, frame:GetChildren())
                if child then
                    -- Apply fonts based on specific element types
                    if child:IsObjectType("FontString") then
                        local name = child:GetName() or ""
                        local lowerName = string.lower(name)
                        
                        -- Target quest list titles specifically (left side)
                        if string.find(lowerName, "questlog") and (string.find(lowerName, "title") or string.find(lowerName, "quest")) then
                            child:SetFont(newFont, questListSize, titleFlags)
                        -- Regular quest detail titles  
                        elseif string.find(lowerName, "title") or string.find(lowerName, "header") then
                            child:SetFont(newFont, titleSize, titleFlags)
                        else
                            -- Use text flags and size for description/body text
                            child:SetFont(newFont, textSize, textFlags)
                        end
                    end
                    -- Recursively check children
                    ApplyFontToChildren(child)
                end
            end
            
            -- Also check regions
            for i = 1, frame:GetNumRegions() do
                local region = select(i, frame:GetRegions())
                if region and region:IsObjectType("FontString") then
                    local name = region:GetName() or ""
                    local lowerName = string.lower(name)
                    
                    -- Target quest list titles specifically (left side)
                    if string.find(lowerName, "questlog") and (string.find(lowerName, "title") or string.find(lowerName, "quest")) then
                        region:SetFont(newFont, questListSize, titleFlags)
                    -- Regular quest detail titles
                    elseif string.find(lowerName, "title") or string.find(lowerName, "header") then
                        region:SetFont(newFont, titleSize, titleFlags)
                    else
                        -- Use text flags and size for description/body text
                        region:SetFont(newFont, textSize, textFlags)
                    end
                end
            end
        end
        
        ApplyFontToChildren(questLogFrame)
    end
end

-- Create slash command for manual testing
SLASH_QUESTFONT1 = "/questfont"
SlashCmdList["QUESTFONT"] = function()
    ChangeQuestLogFonts()
end

-- Hook the font changes to the existing addon's event system
local fontFrame = CreateFrame("Frame")
fontFrame:RegisterEvent("ADDON_LOADED")
fontFrame:RegisterEvent("QUEST_LOG_UPDATE")

fontFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "CustomQuestMarker" then
            -- Delay the font change slightly to ensure UI is ready
            C_Timer.After(1, ChangeQuestLogFonts)
        end
    elseif event == "QUEST_LOG_UPDATE" then
        ChangeQuestLogFonts()
    end
end)

-- Hook into when the quest log frame is shown
local function HookQuestLogFrame()
    if QuestLogFrame then
        QuestLogFrame:HookScript("OnShow", function()
            ChangeQuestLogFonts()
        end)
    end
end

-- Try to hook immediately, or wait for UI to load
if QuestLogFrame then
    HookQuestLogFrame()
else
    local hookFrame = CreateFrame("Frame")
    hookFrame:RegisterEvent("VARIABLES_LOADED")
    hookFrame:SetScript("OnEvent", function()
        HookQuestLogFrame()
        hookFrame:UnregisterAllEvents()
    end)
end