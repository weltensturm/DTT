---@class Addon
local Addon = select(2, ...)

local Scripts = {}
Addon.Scripts = Scripts


local Module = CreateFrame("Frame")
Module:RegisterEvent("ADDON_LOADED")


function Scripts.ExecuteScript(script)
    local func = assert(loadstring('return function(Addon) ' .. script.code .. '\n end', 'Scripts/' .. script.name))
    func()(Addon)
end


function Scripts.NewScript()
    local index = 0
    local name = 'New script'
    while Scripts.HasScript(name) do
        index = index + 1
        name = 'New script ' .. index
    end
    table.insert(
        DTTSavedVariablesAccount.scripts,
        {
            name = name,
            code = '',
            code_original = ''
        }
    )
    DTTSavedVariablesCharacter.scripts[name] = { enabled = false }
    return name
end


function Scripts.CopyScript(script, settings)
    local index = 1
    local name = script.name .. ' ' .. index
    while Scripts.HasScript(name) do
        index = index + 1
        name = script.name .. ' ' .. index
    end
    local newScript = {
        name = name,
        code = script.code,
        code_original = script.code
    }
    table.insert(DTTSavedVariablesAccount.scripts, newScript)
    DTTSavedVariablesCharacter.scripts[name] = { enabled = settings.enabled }
    return name, newScript
end


function Scripts.HasScript(name)
    for _, script in pairs(DTTSavedVariablesAccount.scripts) do
        if script.name == name then
            return true
        end
    end
end


function Scripts.DeleteScript(script)
    for i, v in ipairs(DTTSavedVariablesAccount.scripts) do
        if v.name == script.name then
            table.remove(DTTSavedVariablesAccount.scripts, i)
            break
        end
    end
    DTTSavedVariablesCharacter.scripts[script.name] = nil
end


Module:HookScript('OnEvent', function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "Scripts" then

        if not DTTSavedVariablesAccount then
            DTTSavedVariablesAccount = {}
        end
        if not DTTSavedVariablesCharacter then
            DTTSavedVariablesCharacter = {}
        end

        local account = DTTSavedVariablesAccount
        local character = DTTSavedVariablesCharacter

        account.scripts = account.scripts or {}
        character.scripts = character.scripts or {}

        for _, script in pairs(account.scripts) do
            if not character.scripts[script.name] then
                character.scripts[script.name] = { enabled = false }
            end
            if character.scripts[script.name].enabled then
                Scripts.ExecuteScript(script)
            end
        end
    end
end)

