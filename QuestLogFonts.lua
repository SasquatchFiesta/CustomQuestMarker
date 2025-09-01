-- Font customization variables
local fontsEnabled = false  -- Default to OFF

-- Font settings with defaults
local fontSettings = {
    font = "Fonts\\ARIALN.TTF",
    questListSize = 14,
    titleSize = 14,
    textSize = 12,
    titleFlags = "",
    textFlags = ""
}

-- Saved variables
QuestLogFontsDB = QuestLogFontsDB or {}

local function LoadSettings()
    if QuestLogFontsDB.enabled ~= nil then
        fontsEnabled = QuestLogFontsDB.enabled
    end
    
    -- Load font settings
    if QuestLogFontsDB.settings then
        for key, value in pairs(QuestLogFontsDB.settings) do
            if fontSettings[key] ~= nil then
                fontSettings[key] = value
            end
        end
    end
end

local function SaveSettings()
    QuestLogFontsDB.enabled = fontsEnabled
    QuestLogFontsDB.settings = fontSettings
end

local function ChangeQuestLogFonts()
    -- Don't apply fonts if disabled
    if not fontsEnabled then
        return
    end
    
    -- Use saved font settings
    local newFont = fontSettings.font
    local questListSize = fontSettings.questListSize
    local titleSize = fontSettings.titleSize
    local textSize = fontSettings.textSize
    local titleFlags = fontSettings.titleFlags
    local textFlags = fontSettings.textFlags
    
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

-- Main slash command handler
SLASH_QUESTFONTS1 = "/questfonts"
SlashCmdList["QUESTFONTS"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end
    
    if #args == 0 or args[1] == "help" then
        print("Quest Font Commands:")
        print("  /questfonts on - Enable quest log fonts")
        print("  /questfonts off - Disable quest log fonts")
        print("  /questfonts toggle - Toggle fonts on/off")
        print("  /questfonts apply - Apply current font settings")
        print("  /questfonts status - Show current settings")
        print("")
        print("Font Settings:")
        print("  /questfonts font <name> - Set font (frizqt, arialn, morpheus, skurri, custom)")
        print("  /questfonts questsize <size> - Set quest list size (left side)")
        print("  /questfonts titlesize <size> - Set title size")  
        print("  /questfonts textsize <size> - Set text/description size")
        print("  /questfonts titleflags <flags> - Set title flags (outline, thickoutline, monochrome, none)")
        print("  /questfonts textflags <flags> - Set text flags")
        print("")
        print("Examples:")
        print("  /questfonts font morpheus")
        print("  /questfonts questsize 18")
        print("  /questfonts titleflags outline")
        
    elseif args[1] == "on" then
        fontsEnabled = true
        SaveSettings()
        ChangeQuestLogFonts()
        print("Quest log fonts ENABLED")
        
    elseif args[1] == "off" then
        fontsEnabled = false
        SaveSettings()
        print("Quest log fonts DISABLED (requires UI reload to fully reset fonts)")
        
    elseif args[1] == "toggle" then
        fontsEnabled = not fontsEnabled
        SaveSettings()
        if fontsEnabled then
            ChangeQuestLogFonts()
            print("Quest log fonts ENABLED")
        else
            print("Quest log fonts DISABLED (requires UI reload to fully reset fonts)")
        end
        
    elseif args[1] == "apply" then
        ChangeQuestLogFonts()
        print("Applied current font settings")
        
    elseif args[1] == "status" then
        print("Quest Fonts Status: " .. (fontsEnabled and "ENABLED" or "DISABLED"))
        print("Font: " .. fontSettings.font)
        print("Quest List Size: " .. fontSettings.questListSize)
        print("Title Size: " .. fontSettings.titleSize)
        print("Text Size: " .. fontSettings.textSize)
        print("Title Flags: " .. (fontSettings.titleFlags == "" and "none" or fontSettings.titleFlags))
        print("Text Flags: " .. (fontSettings.textFlags == "" and "none" or fontSettings.textFlags))
        
    elseif args[1] == "font" and args[2] then
        local fontMap = {
            frizqt = "Fonts\\FRIZQT__.TTF",
            arialn = "Fonts\\ARIALN.TTF", 
            morpheus = "Fonts\\MORPHEUS.TTF",
            skurri = "Fonts\\skurri.ttf",
            custom = "Fonts\\custom.ttf"
        }
        
        if fontMap[args[2]] then
            fontSettings.font = fontMap[args[2]]
            SaveSettings()
            print("Font set to: " .. args[2])
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Available fonts: frizqt, arialn, morpheus, skurri, custom(if installed)")
        end
        
    elseif args[1] == "questsize" and args[2] then
        local size = tonumber(args[2])
        if size and size > 0 and size <= 50 then
            fontSettings.questListSize = size
            SaveSettings()
            print("Quest list size set to: " .. size)
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Size must be a number between 1 and 50")
        end
        
    elseif args[1] == "titlesize" and args[2] then
        local size = tonumber(args[2])
        if size and size > 0 and size <= 50 then
            fontSettings.titleSize = size
            SaveSettings()
            print("Title size set to: " .. size)
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Size must be a number between 1 and 50")
        end
        
    elseif args[1] == "textsize" and args[2] then
        local size = tonumber(args[2])
        if size and size > 0 and size <= 50 then
            fontSettings.textSize = size
            SaveSettings()
            print("Text size set to: " .. size)
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Size must be a number between 1 and 50")
        end
        
    elseif args[1] == "titleflags" and args[2] then
        local flagMap = {
            none = "",
            outline = "OUTLINE",
            thickoutline = "THICKOUTLINE",
            monochrome = "MONOCHROME"
        }
        
        if flagMap[args[2]] ~= nil then
            fontSettings.titleFlags = flagMap[args[2]]
            SaveSettings()
            print("Title flags set to: " .. (args[2] == "none" and "none" or args[2]))
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Available flags: outline, thickoutline, monochrome, none")
        end
        
    elseif args[1] == "textflags" and args[2] then
        local flagMap = {
            none = "",
            outline = "OUTLINE", 
            thickoutline = "THICKOUTLINE",
            monochrome = "MONOCHROME"
        }
        
        if flagMap[args[2]] ~= nil then
            fontSettings.textFlags = flagMap[args[2]]
            SaveSettings()
            print("Text flags set to: " .. (args[2] == "none" and "none" or args[2]))
            if fontsEnabled then ChangeQuestLogFonts() end
        else
            print("Available flags: outline, thickoutline, monochrome, none")
        end
        
    else
        print("Unknown command. Use '/questfonts help' for usage.")
    end
end

-- Legacy commands for compatibility
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
            LoadSettings()  -- Load saved settings
            -- Only apply fonts if enabled
            if fontsEnabled then
                C_Timer.After(1, ChangeQuestLogFonts)
            end
        end
    elseif event == "QUEST_LOG_UPDATE" then
        ChangeQuestLogFonts()  -- Will check if enabled inside function
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