---@class Addon
local Addon = select(2, ...)


Addon.CubicInOut = function(x)
    return x < 0.5
        and 4 * x^3
         or 1 - (-2 * x + 2)^3 / 2;
end

