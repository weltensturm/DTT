---@class Addon
local Addon = select(2, ...)

local LQT = Addon.LQT
local Script = LQT.Script
local PARENT = LQT.PARENT
local Style = LQT.Style
local Button = LQT.Button
local Texture = LQT.Texture
local FontString = LQT.FontString


Addon.StyledButton = Button {
    Style:SetSize(20, 20),

    [Script.OnEnter] = function(self)
        self.hoverBg:Show()
    end,

    [Script.OnLeave] = function(self)
        self.hoverBg:Hide()
    end,

    SetText = function(self, ...)
        self.Text:SetText(...)
    end,

    SetFont = function(self, font, size, flags)
        self.Text:SetFont(font, size, flags)
        if self.textSized then
            self:ToTextSize()
        end
    end,

    ToTextSize = function(self)
        self.Text:ClearAllPoints()
        self.Text:SetPoint('LEFT', self, 'LEFT')
        self.Text:SetWidth(0)
        self:SetSize(self.Text:GetSize())
        self.textSized = true
    end,

    Text = FontString
        :SetFont('Fonts/FRIZQT__.ttf', 12)
        :AllPoints(PARENT),

    hoverBg = Texture
        -- :ColorTexture(0.3, 0.3, 0.3)
        :Texture 'Interface/BUTTONS/UI-Listbox-Highlight2'
        :BlendMode 'ADD'
        :VertexColor(1,1,1,0.1)
        :Hide()
        :AllPoints(PARENT)
}

