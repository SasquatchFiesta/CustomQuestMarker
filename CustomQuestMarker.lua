-- Create table for tags (only needed if quest type tags are used)
local _, QuestTags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "!", Heroic = "H", Repeatable = "?"}

-- Initialize saved variables
if not CustomQuestMarkerSettings then
    CustomQuestMarkerSettings = {
        customTag = "**"
    }
end

-- Initialize customTag variable from saved settings
local customTag = CustomQuestMarkerSettings.customTag or "**"

-- Declare QuestFunc first (forward declaration)
local QuestFunc

-- Register the slash command
SLASH_CUSTOMQUESTMARKER1 = "/cqm"

-- Create the slash command handler function
SlashCmdList["CUSTOMQUESTMARKER"] = function(msg)
    -- Check if a message was provided
    if msg == "" then
        -- Display current custom tag if no argument provided
        print("|cff00ff00CustomQuestMarker:|r Current custom tag: |cffff00ff'" .. tostring(customTag) .. "'|r")
        print("|cff00ff00Usage:|r /cqm \"your custom tag including spaces\"")
        print("|cff00ff00Example:|r /cqm \" **\" (for space before)")
        print("|cff00ff00Example:|r /cqm \"** \" (for space after)")
        print("|cff00ff00Example:|r /cqm \" ** \" (for spaces both sides)")
        return
    end
    
    -- Handle quoted strings to preserve leading/trailing whitespace
    local processedMsg = msg
    if string.sub(msg, 1, 1) == '"' and string.sub(msg, -1) == '"' and string.len(msg) > 1 then
        -- Remove surrounding quotes but preserve internal whitespace
        processedMsg = string.sub(msg, 2, -2)
    end
    
    -- Update the customTag variable (preserving all whitespace)
    customTag = processedMsg
    
    -- Save to saved variables
    CustomQuestMarkerSettings.customTag = customTag
    
    -- Confirm the change to the player (show with quotes to indicate exact spacing)
    print("|cff00ff00CustomQuestMarker:|r Custom tag changed to: |cffff00ff'" .. customTag .. "'|r")
    
    -- Force a quest log update to show the new tag immediately
    if QuestLogScrollFrame and QuestFunc then
        QuestFunc() -- Call our quest function to refresh the display
    end
end

-- Define QuestFunc function
QuestFunc = function()
    local buttons = QuestLogScrollFrame.buttons
    local QuestButtons = #buttons
    local QuestScrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
    local QuestEntries, _ = GetNumQuestLogEntries()
    -- Go through quest log
    for i = 1, QuestButtons do
        local QuestIndex = i + QuestScrollOffset
        local QuestTitle = buttons[i]
        if QuestIndex <= QuestEntries then
            local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(QuestIndex)
            -- Add quest type
            if not isHeader or title then
                if not suggestedGroup or suggestedGroup == 0 then suggestedGroup = nil end
                 
                local matched = true          
                if questID and questID >= 26035 then
                    matched = false
                end
                -- Use the customizable customTag variable instead of hardcoded "**"
                local questCustomTag = matched and "" or customTag
               
                title = string.format("[%s%s%s]%s%s",
                    level,
                    questTag and QuestTags[questTag] or "",
                    isDaily and QuestTags.Daily or "",
                    questCustomTag,
                    title),
                    questTag, isDaily, isComplete
            end
            -- Show quest title with level
            if not isHeader then
                QuestTitle:SetText(title)
                QuestLogTitleButton_Resize(QuestTitle)
            end
        end
    end
end

hooksecurefunc("QuestLog_Update", QuestFunc)
QuestLogScrollFrameScrollBar:HookScript('OnValueChanged', QuestFunc)

-- Event handler to load settings when addon is loaded
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "CustomQuestMarker" then
        -- Reload customTag from saved variables in case it was changed
        if CustomQuestMarkerSettings and CustomQuestMarkerSettings.customTag then
            customTag = CustomQuestMarkerSettings.customTag
        end
        -- Unregister the event since we only need it once
        self:UnregisterEvent("ADDON_LOADED")
    end
end)