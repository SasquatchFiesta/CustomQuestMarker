-- Create table for tags (only needed if quest type tags are used)
local _, QuestTags = {}, {Elite = "+", Group = "G", Dungeon = "D", Raid = "R", PvP = "P", Daily = "!", Heroic = "H", Repeatable = "?"}

local function QuestFunc()

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
                -- Add ** as its own tag if not matched
                local customTag = matched and "" or "**"

                

                title = string.format("[%s%s%s]%s %s",
                    level,
                    questTag and QuestTags[questTag] or "",
                    isDaily and QuestTags.Daily or "",
                    customTag,
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