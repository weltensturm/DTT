---@class Addon
local Addon = select(2, ...)

local Style = Addon.LQT.Style


Addon.BubbleScript = setmetatable(
    {},
    {
        __index = function(bubble, ev)
            if not rawget(bubble, ev) then

                bubble[ev] = Style {
                    function(widget, parent)
                        local caller = debugstack(4, 99, 99)

                        if widget:HasScript(ev) then
                            widget:HookScript(ev, function(self, ...)
                                if parent:GetScript(ev) then
                                    parent:GetScript(ev)(parent, ...)
                                else
                                    assert(false, 'Cannot call parent.' .. ev .. '\nElement instantiated at:\n' .. caller)
                                end
                            end)
                        elseif widget[ev] then
                            hooksecurefunc(widget[ev], function(self, ...)
                                parent[ev](parent, ...)
                            end)
                        else
                            assert(false, 'Cannot bubble ' .. ev)
                        end
                    end
                }

            end
            return rawget(bubble, ev)
        end
    }
)

