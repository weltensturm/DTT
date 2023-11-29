---@class Addon
local Addon = select(2, ...)

Addon.Nameplates = Addon.Nameplates or {}

local LQT = Addon.LQT
local query = LQT.query
local Override = LQT.Override
local Event = LQT.Event
local SELF = LQT.SELF
local PARENT = LQT.PARENT
local Frame = LQT.Frame
local FontString = LQT.FontString
local Style = LQT.Style
local Texture = LQT.Texture


local CheckBox = Addon.CheckBox


local load


local _, db = SilverUI.Storage {
    name = 'Nameplates',
    character = {
        enabled = true,
        allCombat = true,
        EnemySolid = 'Interface/AddOns/silver-ui/art/hp-sharp-solid',
        Enemy = 'Interface/AddOns/silver-ui/art/hp-sharp',
        FriendSolid = 'Interface/AddOns/silver-ui/art/hp-round-solid',
        Friend = 'Interface/AddOns/silver-ui/art/hp-round'
    },
    onload = function(_, db)
        if db.enabled then
            load()
        end
    end
}


SilverUI.Settings 'Nameplates' {

    Frame:Size(4, 4),

    FontString
        :Font('Fonts/FRIZQT__.ttf', 16, '')
        :TextColor(1, 0.8196, 0)
        :Text 'Nameplates',

    CheckBox
        :Label 'Enable'
        :Get(function(self) return db.enabled end)
        :Set(function(self, value) db.enabled = value end),

    CheckBox
        :Label 'Toggle all plates in combat'
        :Get(function(self) return db.allCombat end)
        :Set(function(self, value) db.allCombat = value end),
}



local StyleNameplate = Style {

    ['.UnitFrame'] = Style
        :Alpha(0)
        :Hide(),

    SilverUINamePlate = Frame
        :AllPoints(PARENT)
        :FlattensRenderLayers(true)
        :IsFrameBuffer(true)
    {

        SetEventUnit = function(self, unit)
            self.unit = unit
            self:UpdateAlpha()
            for frame in query(self, '.Frame') do
                if frame.SetEventUnit then
                    frame:SetEventUnit(unit)
                end
            end
        end,

        UpdateAlpha = function(self)
            if UnitIsUnit(self.unit, 'target') then
                self:SetAlpha(1)
            else
                self:SetAlpha(0.7)
            end
        end,
        [Event.PLAYER_TARGET_CHANGED] = SELF.UpdateAlpha,

        Background = Texture
            :AllPoints(PARENT)
            :ColorTexture(0, 0, 0, 0),

        -- Health = Addon.Nameplates.FrameHealthDiamond,
        Health = Addon.Nameplates.HealthScaledBar
            .BOTTOM:BOTTOM()
            :Size(128, 16),

        HealthLoss = Addon.Nameplates.HealthLoss
            :AllPoints(PARENT.Health),

        Name = Addon.Nameplates.FrameUnitName
            .TOP:TOP()
            :Size(200, 10),

        Target = Addon.Nameplates.FrameTarget
            .BOTTOMLEFT:TOPLEFT(PARENT.Health.Bar, 2, 0)
            .BOTTOMRIGHT:TOPRIGHT(PARENT.Health.Bar, -2, 0)
            :Height(24),

        CastBar = Addon.Nameplates.FrameCastBar
            :AllPoints(PARENT.Health)
            :FrameLevel(4),

        Auras = Addon.Nameplates.Auras
            :AllPoints(PARENT.Health),

        Absorb = Addon.Units.Shield
            :AllPoints(PARENT.Health)
            :FrameLevel(4),

        -- Bg = Texture
        --     :ColorTexture(0, 0, 0, 0.5)
        --     :AllPoints()

    }

}


load = function()

    SetCVar('nameplateOverlapV', 0.5)

    hooksecurefunc(
        NamePlateDriverFrame, 'UpdateNamePlateOptions',
        function()
            C_NamePlate.SetNamePlateFriendlySize(70, 20)
            C_NamePlate.SetNamePlateEnemySize(70, 20)
        end
    )

    Frame {
        [Event.NAME_PLATE_UNIT_ADDED] = function(self, unit)
            ---@type any
            local plate = C_NamePlate.GetNamePlateForUnit(unit)
            if UnitNameplateShowsWidgetsOnly and UnitNameplateShowsWidgetsOnly(unit) then
                if plate.SilverUINamePlate then
                    plate.SilverUINamePlate:Hide()
                end
                plate.UnitFrame:Show()
                plate.UnitFrame:SetAlpha(1)
                plate.UnitFrame.WidgetContainer:SetScale(0.75)
                return
            else
                plate.UnitFrame:Hide()
                plate.UnitFrame:SetAlpha(0)
            end
            if not plate.SilverUINamePlate then
                StyleNameplate(plate)
            end
            plate.SilverUINamePlate:Show()
            plate.SilverUINamePlate:SetEventUnit(unit)
        end
    }
    .new()

    if db.allCombat then
        Frame {
            [Event.PLAYER_REGEN_DISABLED] = function() SetCVar("nameplateShowAll", 1) end,
            [Event.PLAYER_REGEN_ENABLED] = function() SetCVar("nameplateShowAll", 0) end,
        }
        .new()
    end

    
end

